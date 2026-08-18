path='c:/src/QRKOD Proje/qr_app/lib/screens/enhanced_qr_scanner_screen.dart'
with open(path,encoding='utf-8') as f:
    lines=f.readlines()
start=194
end=497
balance=0
for i in range(start,end):
    line=lines[i]
    for ch in line:
        if ch=='(':
            balance+=1
        elif ch==')':
            balance-=1
    if '(' in line or ')' in line:
        print(f"{i+1:04}: bal={balance} | {line.rstrip()}")
print('Final balance:',balance)
