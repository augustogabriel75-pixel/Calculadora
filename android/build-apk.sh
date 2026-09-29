#!/usr/bin/env bash
# Gera o APK instalável da calculadora VetClin a partir do ../index.html.
# Não precisa do Android SDK: usa o aapt2 e o framework que vêm no apktool (Maven Central),
# o smali para gerar o classes.dex e o apksig para assinar.
#
# Uso:  KS_PASS='sua-senha' ./build-apk.sh
# Variáveis opcionais: KEYSTORE (padrão ~/.vetclin/vetclin-release.p12), VERSION_CODE, VERSION_NAME
set -euo pipefail
cd "$(dirname "$0")"

T=.tools
B=build
KEYSTORE=${KEYSTORE:-$HOME/.vetclin/vetclin-release.p12}
KS_PASS=${KS_PASS:?Defina KS_PASS com a senha do keystore}
ALIAS=vetclin
VERSION_CODE=${VERSION_CODE:-1}
VERSION_NAME=${VERSION_NAME:-1.0}
OUT=../dist/VetClin-Precificacao.apk

mkdir -p "$T" "$B" ../dist

# 1. Ferramentas
if [ ! -x "$T/aapt2" ]; then
  curl -fsSL -o "$T/apktool-lib.jar" https://repo.maven.apache.org/maven2/org/apktool/apktool-lib/3.0.3/apktool-lib-3.0.3.jar
  (cd "$T" && unzip -oqj apktool-lib.jar prebuilt/linux/aapt2 prebuilt/android-framework.jar && chmod +x aapt2)
fi
[ -d "$T/lib" ] || (cd tools/deps && gradle -q copyDeps --no-daemon)
CP=$(ls "$T"/lib/*.jar | tr '\n' ':')

# 2. Conteúdo web, com as fontes embutidas para funcionar sem internet
rm -rf "$B"/*
mkdir -p "$B/assets/fonts"
cp fonts/*.woff2 fonts/fonts.css "$B/assets/fonts/"
python3 - "$B/assets/index.html" <<'PY'
import re, sys
html = open('../index.html', encoding='utf-8').read()
html = re.sub(r'<link rel="preconnect"[^>]*>\n', '', html)
html, n = re.subn(r'<link rel="stylesheet" href="https://fonts\.googleapis\.com[^>]*>', '<link rel="stylesheet" href="fonts/fonts.css">', html)
assert n == 1, 'link do Google Fonts não encontrado no index.html'
open(sys.argv[1], 'w', encoding='utf-8').write(html)
PY

# 3. Recursos + manifesto
"$T/aapt2" compile --dir res -o "$B/res.zip"
"$T/aapt2" link -o "$B/base.apk" -I "$T/android-framework.jar" --manifest AndroidManifest.xml \
  -A "$B/assets" --min-sdk-version 24 --target-sdk-version 34 \
  --version-code "$VERSION_CODE" --version-name "$VERSION_NAME" "$B/res.zip"

# 4. Código (MainActivity) -> classes.dex
java -cp "$CP" org.jf.smali.Main assemble --api 24 -o "$B/classes.dex" smali
python3 -c "import zipfile,sys; z=zipfile.ZipFile(sys.argv[1],'a',zipfile.ZIP_DEFLATED); z.write(sys.argv[2],'classes.dex'); z.close()" "$B/base.apk" "$B/classes.dex"

# 5. Alinhamento e assinatura (esquema v2; minSdk 24 dispensa o v1)
python3 tools/zipalign.py "$B/base.apk" "$B/aligned.apk"
if [ ! -f "$KEYSTORE" ]; then
  mkdir -p "$(dirname "$KEYSTORE")"
  keytool -genkeypair -keystore "$KEYSTORE" -storetype PKCS12 -storepass "$KS_PASS" -keypass "$KS_PASS" \
    -alias "$ALIAS" -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=VetClin, O=VetClin, C=BR"
  echo "Keystore novo criado em $KEYSTORE. Guarde-o: atualizações do app precisam da mesma chave."
fi
java --add-exports java.base/sun.security.x509=ALL-UNNAMED --add-exports java.base/sun.security.pkcs=ALL-UNNAMED --add-exports java.base/sun.security.util=ALL-UNNAMED \
  -cp "$CP" tools/Sign.java "$KEYSTORE" "$KS_PASS" "$ALIAS" "$B/aligned.apk" "$OUT"
echo "APK pronto: $(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT")"
