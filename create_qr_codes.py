import qrcode
from PIL import Image, ImageDraw, ImageFont
import os


def create_test_qr_codes():
    """Test için çeşitli QR kodları oluşturur"""

    output_dir = 'qr_test_assets'
    os.makedirs(output_dir, exist_ok=True)

    # QR kod ayarları
    qr_settings = {
        'version': None,
        'error_correction': qrcode.constants.ERROR_CORRECT_L,
        'box_size': 10,
        'border': 4,
    }

    # Test verileri
    test_data = [
        {
            'data': 'Merhaba Flutter! Bu galerideki bir QR kod',
            'filename': 'test_message_qr.png',
            'title': 'Test Mesaji',
        },
        {
            'data': 'https://flutter.dev',
            'filename': 'flutter_website_qr.png',
            'title': 'Flutter Website',
        },
        {
            'data': 'WIFI:T:WPA;S:TestNetwork;P:12345678;;',
            'filename': 'wifi_qr.png',
            'title': 'WiFi Bilgisi',
        },
        {
            'data': 'tel:+905551234567',
            'filename': 'phone_qr.png',
            'title': 'Telefon Numarasi',
        },
        {
            'data': 'mailto:test@example.com?subject=QR Test&body=Bu bir QR test mailidir',
            'filename': 'email_qr.png',
            'title': 'Email Gonder',
        },
        {
            'data': 'SMSTO:+905551112233:Merhaba, test mesajidir',
            'filename': 'sms_qr.png',
            'title': 'SMS',
        },
        {
            'data': 'geo:41.0082,28.9784?q=Istanbul',
            'filename': 'location_qr.png',
            'title': 'Konum',
        },
        {
            'data': 'BEGIN:VCARD\nVERSION:3.0\nN:Yilmaz;Berat\nFN:Berat Yilmaz\nORG:QR App\nTITLE:Mobile Developer\nTEL;TYPE=CELL:+905551112233\nEMAIL:berat@example.com\nEND:VCARD',
            'filename': 'vcard_qr.png',
            'title': 'vCard',
        },
        {
            'data': 'MATMSG:TO:test@example.com;SUB:QR Test;BODY:Bu bir test mailidir;;',
            'filename': 'matmsg_email_qr.png',
            'title': 'MATMSG Email',
        },
        {
            'data': 'BEGIN:VEVENT\nSUMMARY:QR Test Toplantisi\nDTSTART:20260414T100000Z\nDTEND:20260414T110000Z\nLOCATION:Istanbul\nEND:VEVENT',
            'filename': 'event_qr.png',
            'title': 'Etkinlik',
        },
        {
            'data': 'https://www.google.com/search?q=qr+scanner+test',
            'filename': 'search_url_qr.png',
            'title': 'Arama URL',
        },
        {
            'data': '8690504000001',
            'filename': 'barcode_number_qr.png',
            'title': 'Barkod Numarasi',
        },
        {
            'data': 'otpauth://totp/QRApp:test@example.com?secret=JBSWY3DPEHPK3PXP&issuer=QRApp',
            'filename': 'totp_qr.png',
            'title': 'TOTP',
        },
        {
            'data': 'BEGIN:WIFI\nT:WPA2\nS:OfficeNet\nP:OfficePass123\nH:false\nEND:WIFI',
            'filename': 'wifi_alt_qr.png',
            'title': 'WiFi Alt',
        },
        {
            'data': 'Uzun metin testi: QR okuyucu performans testi icin daha uzun bir metin. Satir1. Satir2. Satir3. Satir4. Satir5.',
            'filename': 'long_text_qr.png',
            'title': 'Uzun Metin',
        },
    ]

    # Her QR kod için resim oluştur
    for item in test_data:
        # QR kod oluştur
        qr = qrcode.QRCode(**qr_settings)
        qr.add_data(item['data'])
        qr.make(fit=True)

        # QR kod resmini oluştur
        qr_img = qr.make_image(fill_color="black", back_color="white")
        if hasattr(qr_img, 'get_image'):
            qr_img = qr_img.get_image()
        qr_img = qr_img.convert('RGB')

        # Başlık eklemek için daha büyük resim oluştur
        img_width = qr_img.size[0]
        img_height = qr_img.size[1] + 60  # Başlık için yer

        final_img = Image.new('RGB', (img_width, img_height), 'white')

        # QR kodu yapıştır
        final_img.paste(qr_img, (0, 50))

        # Başlık ekle
        draw = ImageDraw.Draw(final_img)
        try:
            font = ImageFont.truetype("arial.ttf", 16)
        except Exception:
            font = ImageFont.load_default()

        # Başlık metnini ortala
        text_bbox = draw.textbbox((0, 0), item['title'], font=font)
        text_width = text_bbox[2] - text_bbox[0]
        text_x = (img_width - text_width) // 2

        draw.text((text_x, 10), item['title'], fill='black', font=font)

        # Dosya olarak kaydet
        output_file = os.path.join(output_dir, item['filename'])
        final_img.save(output_file)
        print(f"[OK] {output_file} olusturuldu")


if __name__ == "__main__":
    create_test_qr_codes()
    print("\nTum QR kodlari olusturuldu")
    print("Cikti klasoru: qr_test_assets")