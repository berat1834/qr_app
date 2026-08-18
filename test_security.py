"""
Security Analysis Endpoint'ini Test Et
"""
import requests
import json

backend_url = "http://localhost:8000/api/v1"

# Test URL'leri
test_urls = [
    ("https://google.com", "Güvenli (Google)"),
    ("https://example.com", "Örnek domain"),
    ("http://malware.site", "Potansiyel tehlikeli"),
    ("https://phishing-bank-login.xyz", "Phishing benzeri URL"),
]

print("🔒 Güvenlik Analiz Endpoint Testleri\n")
print("=" * 60)

for url, description in test_urls:
    print(f"\n📍 Test: {description}")
    print(f"   URL: {url}")
    
    try:
        response = requests.post(
            f"{backend_url}/analyze-url",
            json={"url": url},
            timeout=10
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"   ✅ Status: {response.status_code}")
            print(f"   🎯 Tehdit Seviyesi: {result.get('threat_level')}")
            print(f"   📊 Phishing Skoru: {result.get('phishing_score', 0):.2f}")
            print(f"   🛡️  Güvenli mi: {result.get('is_safe')}")
            
            risk_factors = result.get('risk_factors', [])
            if risk_factors:
                print(f"   ⚠️  Risk Faktörleri:")
                for factor in risk_factors:
                    print(f"      - {factor}")
        else:
            print(f"   ❌ Hata: Status {response.status_code}")
            print(f"   📄 Response: {response.text}")
    except Exception as e:
        print(f"   ❌ Hata: {e}")

print("\n" + "=" * 60)
print("\n✅ Güvenlik Analiz Testleri Tamamlandı")
