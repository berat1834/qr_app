"""
Offline Queue Sync Testini Simüle Et
"""
import asyncio
import os
from pathlib import Path
import json
from datetime import datetime

# Test edilecek görsel
test_image = Path("qr_test_assets/barcode_number_qr.png")
if not test_image.exists():
    print(f"❌ Test görseli {test_image} bulunamadı")
    exit(1)

# Simülasyon: Backend ulaşılamıyor
print("🔌 Simülasyon: Backend 8000 portunda yanıt vermiyor (ağ hatası)")
print("📋 Offline Queue Flow'u Test Ediyor...\n")

# Adım 1: Görsel kaydedilir
app_dir = Path("test_offline_queue")
app_dir.mkdir(exist_ok=True)
saved_image = app_dir / f"queued_scan_{int(datetime.now().timestamp() * 1000)}.png"

# Görsel kopyala
import shutil
shutil.copy(test_image, saved_image)
print(f"✅ Adım 1: Görsel kuyruğa kaydedildi: {saved_image}")

# Adım 2: Metadata SharedPreferences'a yazılır
queue_metadata = {
    'imagePath': str(saved_image),
    'timestamp': datetime.now().isoformat(),
    'note': 'Queued due to AI backend unreachable'
}

queue_file = app_dir / "offline_scan_queue.json"
queue_data = []
if queue_file.exists():
    with open(queue_file, 'r') as f:
        queue_data = json.load(f)

queue_data.append(queue_metadata)
with open(queue_file, 'w') as f:
    json.dump(queue_data, f, indent=2)

print(f"✅ Adım 2: Queue metadata kaydedildi: {queue_file}")
print(f"   Kuyrukta {len(queue_data)} görsel var")

# Adım 3: Ağ geri geldiğinde sync işlemi
print(f"\n📡 Ağ geri geldi! Sync başlıyor...\n")

import requests

# Kuyruk verileri oku
with open(queue_file, 'r') as f:
    queue_data = json.load(f)

synced_count = 0
for i, item in enumerate(queue_data, 1):
    image_path = Path(item['imagePath'])
    
    print(f"🔄 [{i}/{len(queue_data)}] Senkronize Ediliyor: {image_path.name}")
    
    try:
        with open(image_path, 'rb') as f:
            files = {'file': f}
            response = requests.post(
                "http://localhost:8000/api/v1/process-damaged-image",
                files=files,
                timeout=10
            )
        
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                print(f"   ✅ Başarılı: {result.get('decoded_data')}")
                synced_count += 1
            else:
                print(f"   ⚠️  QR Okunamadı")
        else:
            print(f"   ❌ Hata: Status {response.status_code}")
    except Exception as e:
        print(f"   ❌ Hata: {e}")

# Sync başarılı olduktan sonra kuyruk temizle
queue_data_new = queue_data[synced_count:]
if queue_data_new:
    with open(queue_file, 'w') as f:
        json.dump(queue_data_new, f, indent=2)
    print(f"\n📋 Sırada hala {len(queue_data_new)} görsel kaldı")
else:
    queue_file.unlink()
    print(f"\n✅ Kuyruk tamamen temizlendi!")

print(f"\n📊 Sonuç: {synced_count}/{len(queue_data)} başarıyla senkronize edildi")

# Temizle
import shutil
shutil.rmtree(app_dir)
print("🧹 Test verisi temizlendi")
