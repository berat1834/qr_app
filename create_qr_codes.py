import qrcode
from PIL import Image, ImageDraw, ImageFont
import os

def create_test_qr_codes():
    """Test için çeşitli QR kodları oluşturur"""
    
    # QR kod ayarları
    qr_settings = {
        'version': 1,
        'error_correction': qrcode.constants.ERROR_CORRECT_L,
        'box_size': 10,
        'border': 4,
    }
    
    # Test verileri
    test_data = [
        {
            'data': 'Merhaba Flutter! Bu galerideki bir QR kod 🚀',
            'filename': 'test_message_qr.png',
            'title': 'Test Mesajı'
        },
        {
            'data': 'https://flutter.dev',
            'filename': 'flutter_website_qr.png',
            'title': 'Flutter Website'
        },
        {
            'data': 'WIFI:T:WPA;S:TestNetwork;P:12345678;;',
            'filename': 'wifi_qr.png',
            'title': 'WiFi Bilgisi'
        },
        {
            'data': 'tel:+905551234567',
            'filename': 'phone_qr.png',
            'title': 'Telefon Numarası'
        },
        {
            'data': 'mailto:test@example.com?subject=QR Test&body=Bu bir QR test mailidir',
            'filename': 'email_qr.png',
            'title': 'Email Gönder'
        }
    ]
    
    # Her QR kod için resim oluştur
    for item in test_data:
        # QR kod oluştur
        qr = qrcode.QRCode(**qr_settings)
        qr.add_data(item['data'])
        qr.make(fit=True)
        
        # QR kod resmini oluştur
        qr_img = qr.make_image(fill_color="black", back_color="white")
        
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
        except:
            font = ImageFont.load_default()
            
        # Başlık metnini ortala
        text_bbox = draw.textbbox((0, 0), item['title'], font=font)
        text_width = text_bbox[2] - text_bbox[0]
        text_x = (img_width - text_width) // 2
        
        draw.text((text_x, 10), item['title'], fill='black', font=font)
        
        # Dosya olarak kaydet
        final_img.save(item['filename'])
        print(f"✅ {item['filename']} oluşturuldu")

if __name__ == "__main__":
    create_test_qr_codes()
    print("\n🎯 Tüm QR kodları oluşturuldu!")
    print("Bu dosyaları emülatöre göndermek için adb komutlarını kullanabilirsiniz.")