from fastapi import APIRouter, UploadFile, File
import cv2
import numpy as np
from pyzbar.pyzbar import decode, ZBarSymbol

# api.py tarafından dahil edilen "router" nesnesi
router = APIRouter()

@router.post("/process-damaged-image")
async def process_damaged_image(file: UploadFile = File(...)):
    """
    Görüntü işleme ve bulanık/hasarlı QR düzeltme uç noktası.
    Flutter tarafındaki AIVisionService ile entegre çalışır.
    """
    contents = await file.read()
    image_data = np.frombuffer(contents, np.uint8)
    image = cv2.imdecode(image_data, cv2.IMREAD_COLOR)

    if image is None:
        return {
            "message": "Resim dosyası okunamıyor.",
            "filename": file.filename,
            "success": False,
            "decoded_data": None,
        }

    def try_decode(img):
        try:
            codes = decode(img, symbols=[ZBarSymbol.QRCODE])
            return codes
        except Exception:
            return []

    # İlk doğrudan deneme
    qr_codes = try_decode(image)

    # Eğer doğrudan okunmadıysa, çeşitli ön işleme adımlarını dene
    if not qr_codes:
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

        # CLAHE (contrast limited adaptive histogram equalization)
        try:
            clahe = cv2.createCLAHE(clipLimit=3.0, tileGridSize=(8, 8))
            gray_clahe = clahe.apply(gray)
        except Exception:
            gray_clahe = gray

        # Gürültü azaltma
        denoised = cv2.bilateralFilter(gray_clahe, 9, 75, 75)

        # Adaptif threshold
        try:
            thresh = cv2.adaptiveThreshold(
                denoised, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2
            )
        except Exception:
            _, thresh = cv2.threshold(denoised, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

        # Morphology to close gaps
        kernel = np.ones((3, 3), np.uint8)
        closed = cv2.morphologyEx(thresh, cv2.MORPH_CLOSE, kernel)

        qr_codes = try_decode(closed)

    # Eğer hâlâ yoksa, yeniden boyutlandırma ve tekrar dene
    if not qr_codes:
        h, w = image.shape[:2]
        for scale in [1.5, 2.0, 3.0]:
            resized = cv2.resize(image, (int(w * scale), int(h * scale)), interpolation=cv2.INTER_LINEAR)
            qr_codes = try_decode(resized)
            if qr_codes:
                break

    if not qr_codes:
        return {
            "message": "QR kodu bulunamadı veya okunamadı.",
            "filename": file.filename,
            "success": False,
            "decoded_data": None,
        }

    decoded_values = [qr.data.decode("utf-8", errors="replace") for qr in qr_codes]
    return {
        "message": "QR kodu başarıyla okundu.",
        "filename": file.filename,
        "success": True,
        "decoded_data": decoded_values[0],
        "decoded_values": decoded_values,
    }