"""Alinha em 4 bytes os arquivos não comprimidos de um APK (equivalente ao zipalign -p 4)."""
import sys, zipfile

src, dst = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(src) as zin, open(dst, 'wb') as f, zipfile.ZipFile(f, 'w') as zout:
    for info in zin.infolist():
        data = zin.read(info)
        new = zipfile.ZipInfo(info.filename, date_time=info.date_time)
        new.compress_type = info.compress_type
        new.external_attr = info.external_attr
        extra = b''
        if info.compress_type == zipfile.ZIP_STORED:
            align = 4096 if info.filename.endswith('.so') else 4
            start = f.tell() + 30 + len(info.filename.encode())
            extra = b'\0' * ((align - start % align) % align)
        new.extra = extra
        zout.writestr(new, data)
with zipfile.ZipFile(dst) as z:
    for i in z.infolist():
        if i.compress_type == zipfile.ZIP_STORED:
            off = i.header_offset + 30 + len(i.filename.encode()) + len(i.extra)
            assert off % 4 == 0, i.filename
print('alinhado:', dst)
