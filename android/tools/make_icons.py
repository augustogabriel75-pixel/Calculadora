"""Gera os ícones do app (pata branca sobre verde VetClin) em todas as densidades."""
import os
from PIL import Image, ImageDraw

TEAL = (13, 107, 89, 255)
WHITE = (255, 255, 255, 255)
PAW = [(20, 25.5, 7, 5.8), (11.5, 17.5, 2.8, 3.6), (17, 12.2, 2.8, 3.8), (23, 12.2, 2.8, 3.8), (28.5, 17.5, 2.8, 3.6)]
DENS = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
SS = 4  # superamostragem

def paw(draw, cx, cy, scale):
    for x, y, rx, ry in PAW:
        x, y = cx + (x - 20) * scale, cy + (y - 20) * scale
        draw.ellipse([x - rx * scale, y - ry * scale, x + rx * scale, y + ry * scale], fill=WHITE)

def legacy(px):
    s = px * SS
    im = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.rounded_rectangle([s * .04, s * .04, s * .96, s * .96], radius=s * .22, fill=TEAL)
    paw(d, s / 2, s / 2 + s * .01, s / 40 * .92)
    return im.resize((px, px), Image.LANCZOS)

def foreground(px):
    s = px * SS
    im = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    paw(ImageDraw.Draw(im), s / 2, s / 2 + s * .01, s / 40 * .5)
    return im.resize((px, px), Image.LANCZOS)

root = os.path.join(os.path.dirname(__file__), '..', 'res')
for name, f in DENS.items():
    out = os.path.join(root, 'mipmap-' + name)
    os.makedirs(out, exist_ok=True)
    legacy(round(48 * f)).save(os.path.join(out, 'ic_launcher.png'))
    foreground(round(108 * f)).save(os.path.join(out, 'ic_launcher_foreground.png'))
legacy(512).save(os.path.join(root, '..', 'icon-512.png'))
print('ícones gerados')
