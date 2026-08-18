import sys
p='c:/src/QRKOD Proje/qr_app/lib/screens/enhanced_qr_scanner_screen.dart'
with open(p,encoding='utf-8') as f:
    s=f.read()
counts={c:s.count(c) for c in '(){}[]'}
print(counts)
# report first mismatch
pairs=[('(',')'),('{','}'),('[',']')]
for a,b in pairs:
    if counts[a]!=counts[b]:
        print('Mismatch',a,counts[a],b,counts[b])

# find line of first imbalance by scanning
stack=[]
lineno=1
for i,ch in enumerate(s):
    if ch=='\n':
        lineno+=1
    if ch in '({[':
        stack.append((ch,lineno,i))
    elif ch in ')}]':
        if not stack:
            print('Unmatched closing',ch,'at line',lineno)
            break
        opening,ol,oi=stack.pop()
        pairs_map={')':'(',']':'[','}':'{'}
        if pairs_map[ch]!=opening:
            print('Mismatched',opening,'opened at',ol,'but closed by',ch,'at',lineno)
            print('Current stack snapshot (top last):')
            for it in stack:
                print(it)
            break
else:
    if stack:
        opening,ol,oi=stack[-1]
        print('Unclosed',opening,'opened at line',ol)
    else:
        print('All balanced')
