"""
Direkt backend QR detection'ını test et
"""
import requests
import os
from pathlib import Path

# QR test görselini bul
test_images_dir = Path("qr_test_assets")
if not test_images_dir.exists():
    print(f"❌ {test_images_dir} bulunamadı")
    exit(1)

image_files = list(test_images_dir.glob("*.jpg")) + list(test_images_dir.glob("*.png"))
if not image_files:
    print("❌ Test görseli bulunamadı")
    exit(1)

test_image = image_files[0]
print(f"📸 Test görseli: {test_image}")
print(f"📊 Dosya boyutu: {test_image.stat().st_size} bytes")

# Backend'e gönder
backend_url = "http://localhost:8000/api/v1/process-damaged-image"
print(f"\n🚀 {backend_url} çağrılıyor...")

try:
    with open(test_image, 'rb') as f:
        files = {'file': f}
        response = requests.post(backend_url, files=files, timeout=30)
    
    print(f"\n✅ Status: {response.status_code}")
    result = response.json()
    print(f"📄 Response: {result}")
    
    if result.get('success'):
        print(f"\n✅ QR Başarıyla Okundu: {result.get('decoded_data')}")
    else:
        print(f"\n❌ QR Okunamadı")
        print(f"💡 Debugging için backend logs kontrol et")
        
except Exception as e:
    print(f"\n❌ Hata: {e}")
