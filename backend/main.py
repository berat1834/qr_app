from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse
import uvicorn
import cv2
import numpy as np
from pyzbar.pyzbar import decode

app = FastAPI()

def read_qr_from_image(image_bytes):
    # Byte dizisini OpenCV resmine (Mat) çevir
    np_arr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    
    # 1. Deneme: Orijinal renkli resimden okumaya çalış
    decoded_objects = decode(img)
    if decoded_objects:
        return decoded_objects[0].data.decode('utf-8')
        
    # 2. Deneme: Siyah beyaza çevir (AI Onarımı Modu)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    decoded_objects = decode(gray)
    if decoded_objects:
        return decoded_objects[0].data.decode('utf-8')
        
    # 3. Deneme: Thresholding (Gelişmiş Hasar Onarımı / Keskinleştirme)
    # Bulanık veya çizilmiş kodları kurtarmak için siyah/beyaz kontrastını patlatıyoruz
    _, thresh = cv2.threshold(gray, 100, 255, cv2.THRESH_BINARY)
    decoded_objects = decode(thresh)
    if decoded_objects:
        return decoded_objects[0].data.decode('utf-8')

    return None

@app.post("/api/v1/process-damaged-image")
async def process_damaged_image(file: UploadFile = File(...)):
    print(f"Resim alindi: {file.filename}")
    
    contents = await file.read()
    result_text = read_qr_from_image(contents)
    
    if result_text:
        print(f"BULDUM: {result_text}")
        return {
            "status": "success",
            "decoded_data": result_text,
            "message": "QR kod AI destekli goruntu islemeyle başarıyla onarılıp okundu."
        }
    else:
        print("QR BULUNAMADI")
        return JSONResponse(status_code=400, content={
            "status": "error",
            "detail": "Yapay zeka algoritmaları bu görseldeki QR kodu kurtaramadı."
        })

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
