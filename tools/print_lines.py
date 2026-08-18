p='c:/src/QRKOD Proje/qr_app/lib/screens/enhanced_qr_scanner_screen.dart'
with open(p,encoding='utf-8') as f:
    lines=f.readlines()
for i in range(190,201):
    print(f"{i+1:04}: {lines[i].rstrip()}")
print('---')
for i in range(400,506):
    print(f"{i+1:04}: {lines[i].rstrip()}")
