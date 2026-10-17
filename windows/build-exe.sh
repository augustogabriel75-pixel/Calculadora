#!/usr/bin/env bash
# Gera dist/VetClin-Preco-de-Venda.exe (Windows 10/11, 64 bits) a partir do ../index.html.
# Precisa só do Go (compila para Windows a partir do Linux, macOS ou Windows).
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p app ../dist
python3 - <<'PY'
html = open('../index.html', encoding='utf-8').read()
alvo = "<script>\n'use strict';"
assert html.count(alvo) == 1
open('app/index.html', 'w', encoding='utf-8').write(html.replace(alvo, "<script>window.VC_PLATFORM='windows'</script>\n" + alvo, 1))
from PIL import Image
im = Image.open('../android/icon-512.png').convert('RGBA')
for s in (16, 32, 48, 256):
    im.resize((s, s), Image.LANCZOS).save(f'icon-{s}.png')
PY
go run github.com/tc-hib/go-winres@v0.3.3 make --arch amd64 --in winres.json
GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -trimpath -ldflags "-H windowsgui -s -w" -o ../dist/VetClin-Preco-de-Venda.exe .
rm -f icon-*.png
echo "EXE pronto: $(cd ../dist && pwd)/VetClin-Preco-de-Venda.exe"
