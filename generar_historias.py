"""Genera 5 historias de Instagram (1080x1920) para La Burbuja.
Inspiradas en el diseno de referencia (Dhona) pero con la identidad de La Burbuja.
Paso 4 omitido segun indicacion del usuario.
"""
import math
import os
import pathlib

from PIL import Image, ImageDraw, ImageFilter, ImageFont

OUT = pathlib.Path(r'C:\Users\mili_\Downloads\Nueva carpeta\instagram-stories')
OUT.mkdir(parents=True, exist_ok=True)

W, H = 1080, 1920
F = r'C:\Windows\Fonts'
SERIF_B = os.path.join(F, 'georgiab.ttf')
SERIF_R = os.path.join(F, 'georgia.ttf')
SANS = os.path.join(F, 'segoeui.ttf')
SANS_SB = os.path.join(F, 'seguisb.ttf')
SANS_B = os.path.join(F, 'segoeuib.ttf')
SYM = os.path.join(F, 'seguisym.ttf')

NAVY = (26, 58, 107)
NAVY_SOFT = (44, 90, 158)
TEAL = (77, 200, 216)
TEAL_DK = (44, 150, 172)
BODY = (92, 112, 136)
WHITE = (255, 255, 255)
EYEBROW = (44, 120, 150)
LOGO = pathlib.Path(r'C:\Users\mili_\Downloads\Nueva carpeta\la_burbuja-02.png')
SITE = 'laburbujavm.vercel.app'


def fnt(path, size):
    return ImageFont.truetype(path, size)


def ls_width(draw, text, font, spacing):
    if not text:
        return 0
    w = sum(draw.textlength(c, font=font) for c in text)
    return w + spacing * (len(text) - 1)


def draw_ls(draw, xy, text, font, fill, spacing=0, anchor='lt'):
    """Dibuja texto con tracking (letter-spacing) alineado por línea base.

    Importante: al dibujar letra por letra hay que usar la misma línea base para
    todas, porque cada glifo tiene una caja distinta (las letras acentuadas son
    más altas y quedaban desfasadas hacia abajo).
    """
    if not text:
        return 0
    total = ls_width(draw, text, font, spacing)
    x, y = xy
    asc, _desc = font.getmetrics()
    bb = font.getbbox(text)          # relativo al origen 'la' (ascender)
    y_asc = y - bb[1]                # ascender para que el tope visual caiga en y
    baseline = y_asc + asc
    if anchor[0] == 'm':
        x -= total / 2
    elif anchor[0] == 'r':
        x -= total
    for c in text:
        draw.text((x, baseline), c, font=font, fill=fill, anchor='ls')
        x += draw.textlength(c, font=font) + spacing
    return total


def wrap(text, font, draw, maxw):
    words = text.split()
    lines, cur = [], ''
    for wd in words:
        test = (cur + ' ' + wd).strip()
        if draw.textlength(test, font=font) <= maxw or not cur:
            cur = test
        else:
            lines.append(cur)
            cur = wd
    if cur:
        lines.append(cur)
    return lines


def para(draw, x, y, text, font, fill, maxw, lh, align='l'):
    for ln in wrap(text, font, draw, maxw):
        xx = x
        if align == 'm':
            xx = x + (maxw - draw.textlength(ln, font=font)) / 2
        elif align == 'r':
            xx = x + maxw - draw.textlength(ln, font=font)
        draw.text((xx, y), ln, font=font, fill=fill)
        y += lh
    return y


# ---------------------------------------------------------------- fondo
def background():
    base = Image.new('RGB', (W, H), (255, 255, 255))
    top = (233, 244, 249)
    bot = (246, 252, 250)
    d = ImageDraw.Draw(base)
    for y in range(H):
        t = y / (H - 1)
        c = tuple(int(top[i] + (bot[i] - top[i]) * t) for i in range(3))
        d.line([(0, y), (W, y)], fill=c)
    blobs = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    bd = ImageDraw.Draw(blobs)
    bd.ellipse([-260, -300, 720, 620], fill=(77, 200, 216, 90))
    bd.ellipse([420, 1180, 1420, 2180], fill=(120, 214, 190, 95))
    bd.ellipse([-300, 900, 420, 1700], fill=(160, 205, 235, 80))
    blobs = blobs.filter(ImageFilter.GaussianBlur(170))
    base = Image.alpha_composite(base.convert('RGBA'), blobs)
    # marca de agua gigante
    wm = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    wd = ImageDraw.Draw(wm)
    f = fnt(SERIF_B, 235)
    draw_ls(wd, (W / 2, H - 330), 'BURBUJA', f, (255, 255, 255, 95), spacing=8, anchor='mt')
    wm = wm.filter(ImageFilter.GaussianBlur(1.2))
    base = Image.alpha_composite(base, wm)
    return base


def logo(img, height, cx, cy):
    lg = Image.open(LOGO).convert('RGBA')
    lg = lg.crop(lg.getbbox())
    w = int(lg.width * height / lg.height)
    lg = lg.resize((w, height), Image.LANCZOS)
    img.alpha_composite(lg, (int(cx - w / 2), int(cy - height / 2)))


# ---------------------------------------------------------------- iconos
def ic_cursor(d, cx, cy, s, col):
    p = [(cx - .22 * s, cy - .30 * s), (cx + .26 * s, cy + .02 * s),
         (cx + .02 * s, cy + .06 * s), (cx + .14 * s, cy + .30 * s),
         (cx + .00 * s, cy + .20 * s), (cx - .10 * s, cy + .34 * s),
         (cx - .22 * s, cy - .30 * s)]
    d.polygon(p, fill=col)
    for (ox, oy, r) in ((.34, -.30, .10), (-.34, .04, .07), (.30, .30, .06)):
        d.ellipse([cx + ox * s - r * s, cy + oy * s - r * s,
                   cx + ox * s + r * s, cy + oy * s + r * s], fill=col)


def ic_chat(d, cx, cy, s, col):
    w, h = .60 * s, .46 * s
    d.rounded_rectangle([cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2],
                        radius=.16 * s, outline=col, width=max(3, int(.055 * s)))
    d.polygon([(cx - .18 * s, cy + h / 2 - .02 * s),
               (cx - .02 * s, cy + h / 2 - .02 * s),
               (cx - .16 * s, cy + h / 2 + .18 * s)], fill=col)


def ic_card(d, cx, cy, s, col):
    w, h = .64 * s, .46 * s
    d.rounded_rectangle([cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2],
                        radius=.07 * s, outline=col, width=max(3, int(.055 * s)))
    d.rectangle([cx - w / 2, cy - h / 2 + .13 * s, cx + w / 2, cy - h / 2 + .20 * s], fill=col)
    d.ellipse([cx - w / 2 + .07 * s, cy + h / 2 - .14 * s,
               cx - w / 2 + .15 * s, cy + h / 2 - .06 * s], fill=col)


def ic_link(d, cx, cy, s, col):
    f = fnt(SYM, int(s * 1.05))
    d.text((cx, cy), '\U0001F517', font=f, fill=col, anchor='mm')


ICONOS = {'elegir': ic_cursor, 'chat': ic_chat, 'pago': ic_card, 'link': ic_link}


def circle_icon(img, cx, cy, d_px, kind, bg=TEAL_DK, fg=WHITE):
    d = ImageDraw.Draw(img)
    d.ellipse([cx - d_px / 2, cy - d_px / 2, cx + d_px / 2, cy + d_px / 2], fill=bg)
    ICONOS[kind](d, cx, cy, d_px * .60, fg)


# ---------------------------------------------------------------- piezas
def rounded_card(img, box, radius, fill=(255, 255, 255, 242), border=(255, 255, 255, 255),
                 shadow=True, blur=26, sh_alpha=42, sh_off=8):
    x0, y0, x1, y1 = box
    if shadow:
        sh = Image.new('RGBA', img.size, (0, 0, 0, 0))
        sd = ImageDraw.Draw(sh)
        sd.rounded_rectangle([x0, y0 + sh_off, x1, y1 + sh_off], radius=radius,
                             fill=(26, 58, 107, sh_alpha))
        sh = sh.filter(ImageFilter.GaussianBlur(blur))
        img.alpha_composite(sh)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle(box, radius=radius, fill=fill, outline=border, width=2)


def pill(d, x, y, text, font, padx=34, pady=20, fill=(255, 255, 255, 240),
         fcol=NAVY_SOFT, border=None, radius=None):
    tw = d.textlength(text, font=font)
    h = font.size + pady * 2
    w = tw + padx * 2
    r = radius if radius is not None else h / 2
    d.rounded_rectangle([x, y, x + w, y + h], radius=r, fill=fill,
                        outline=border, width=2 if border else 0)
    d.text((x + w / 2, y + h / 2), text, font=font, fill=fcol, anchor='mm')
    return w, h


def pill_rows(d, y, textos, font, maxw=980, padx=30, pady=19, gap=26, rowgap=22):
    """Distribuye pills en filas centradas que no superen maxw."""
    widths = [d.textlength(t, font=font) + padx * 2 for t in textos]
    rows, cur, curw = [], [], 0
    for t, w in zip(textos, widths):
        add = w if not cur else gap + w
        if cur and curw + add > maxw:
            rows.append((cur, curw))
            cur, curw = [(t, w)], w
        else:
            cur.append((t, w))
            curw += add
    if cur:
        rows.append((cur, curw))
    for items, totalw in rows:
        x = (W - totalw) / 2
        for t, w in items:
            pill(d, x, y, t, font, padx=padx, pady=pady)
            x += w + gap
        y += font.size + pady * 2 + rowgap
    return y


def site_chip(img, cy, w=520):
    d = ImageDraw.Draw(img)
    f = fnt(SANS_B, 40)
    tw = d.textlength(SITE, font=f)
    w = int(tw + 150)
    x = (W - w) / 2
    h = 104
    rounded_card(img, [x, cy - h / 2, x + w, cy + h / 2], radius=h / 2,
                 fill=(255, 255, 255, 250), blur=20, sh_alpha=32)
    ICONOS['link'](d, x + 66, cy, 54, TEAL_DK)
    d.text((x + 112, cy), SITE, font=f, fill=NAVY, anchor='lm')


def step_card(img, x0, y, x1, num, titulo, texto, kind):
    d = ImageDraw.Draw(img)
    f_lbl = fnt(SANS_B, 33)
    f_tit = fnt(SERIF_B, 62)
    f_txt = fnt(SANS, 37)
    pad = 46
    icon_d = 116
    tx = x0 + pad + icon_d + 42
    tw = x1 - pad - tx
    tl = wrap(titulo, f_tit, d, tw)
    bl = wrap(texto, f_txt, d, tw)
    lh = 54
    h = pad * 2 + 44 + len(tl) * 72 + len(bl) * lh
    rounded_card(img, [x0, y, x1, y + h], radius=46)
    cy = y + pad + 46 + 8
    circle_icon(img, x0 + pad + icon_d / 2, cy + 8, icon_d, kind)
    ty = y + pad + 4
    draw_ls(d, (tx, ty), num, f_lbl, TEAL_DK, spacing=5, anchor='lt')
    ty += 52
    for ln in tl:
        d.text((tx, ty), ln, font=f_tit, fill=NAVY)
        ty += 72
    ty += 6
    for ln in bl:
        d.text((tx, ty), ln, font=f_txt, fill=BODY)
        ty += lh
    return y + h


def qa_card(img, x0, y, x1, pregunta, respuesta):
    d = ImageDraw.Draw(img)
    f_q = fnt(SANS_B, 41)
    f_r = fnt(SANS, 35)
    pad = 46
    tw = x1 - x0 - pad * 2
    ql = wrap(pregunta, f_q, d, tw)
    rl = wrap(respuesta, f_r, d, tw)
    h = pad * 2 + len(ql) * 54 + len(rl) * 50
    rounded_card(img, [x0, y, x1, y + h], radius=42)
    ty = y + pad
    for ln in ql:
        d.text((x0 + pad, ty), ln, font=f_q, fill=NAVY)
        ty += 54
    ty += 4
    for ln in rl:
        d.text((x0 + pad, ty), ln, font=f_r, fill=BODY)
        ty += 50
    return y + h


# ---------------------------------------------------------------- historias
def h1_novedad():
    img = background()
    d = ImageDraw.Draw(img)
    logo(img, 235, W / 2, 300)
    y = 470
    y += 34
    draw_ls(d, (W / 2, y), '¡NOVEDAD!', fnt(SANS_B, 40), EYEBROW, spacing=8, anchor='mt')
    y += 78
    f_h = fnt(SERIF_B, 100)
    for ln in wrap('Ya abrimos nuestra tienda online', f_h, d, W - 150):
        d.text((W / 2, y), ln, font=f_h, fill=NAVY, anchor='ma')
        y += 116
    y += 18
    y = para(d, 120, y, 'Elegí tus productos y combos, armá tu pedido y seguimos por WhatsApp.',
             fnt(SANS, 42), BODY, W - 240, 60, align='m')
    y += 54
    fb = fnt(SANS_B, 36)
    y = pill_rows(d, y, ('Envío gratis desde $30.000', 'Pedido por WhatsApp',
                         'Combos y aromas', 'Villa María y Córdoba'), fb, maxw=1000)
    return img


def h2_guia():
    img = background()
    d = ImageDraw.Draw(img)
    logo(img, 210, W / 2, 285)
    y = 445
    draw_ls(d, (W / 2, y), 'GUÍA RÁPIDA', fnt(SANS_B, 38), EYEBROW, spacing=9, anchor='mt')
    y += 76
    f_h = fnt(SERIF_B, 108)
    d.text((W / 2, y), 'Cómo comprar', font=f_h, fill=NAVY, anchor='ma')
    y += 140
    y = para(d, 130, y, 'Armás tu pedido en la tienda y seguimos por WhatsApp. Simple y sin vueltas.',
             fnt(SANS, 40), BODY, W - 260, 58, align='m')
    y += 90
    d_px = 150
    gap = 120
    total = 3 * d_px + 2 * gap
    x = (W - total) / 2 + d_px / 2
    for kind in ('elegir', 'chat', 'pago'):
        circle_icon(img, x, y + d_px / 2, d_px, kind)
        x += d_px + gap
    y += d_px + 130
    site_chip(img, min(y + 10, 1560))
    return img


def h3_paso12():
    img = background()
    d = ImageDraw.Draw(img)
    y = 250
    draw_ls(d, (W / 2, y), 'CÓMO COMPRAR', fnt(SANS_B, 38), EYEBROW, spacing=9, anchor='mt')
    y += 74
    f_h = fnt(SERIF_B, 96)
    for ln in wrap('Primero, armá tu pedido', f_h, d, W - 160):
        d.text((W / 2, y), ln, font=f_h, fill=NAVY, anchor='ma')
        y += 112
    y += 46
    x0, x1 = 70, W - 70
    y = step_card(img, x0, y, x1, 'PASO 1', 'Elegí tus productos',
                  'Mirá el catálogo, entrá a cada producto para ver fotos y descripción, elegí el aroma y sumalo a tu pedido.',
                  'elegir')
    y += 40
    y = step_card(img, x0, y, x1, 'PASO 2', 'Enviá tu pedido',
                  'Revisás todo en el «Carrito», ponés tus datos y tocás «Consultar pedido por WhatsApp». El mensaje se arma solo.',
                  'chat')
    return img


def h4_paso3():
    img = background()
    d = ImageDraw.Draw(img)
    y = 250
    draw_ls(d, (W / 2, y), 'CÓMO COMPRAR', fnt(SANS_B, 38), EYEBROW, spacing=9, anchor='mt')
    y += 74
    f_h = fnt(SERIF_B, 96)
    for ln in wrap('Después, lo coordinamos', f_h, d, W - 160):
        d.text((W / 2, y), ln, font=f_h, fill=NAVY, anchor='ma')
        y += 112
    y += 50
    x0, x1 = 70, W - 70
    y = step_card(img, x0, y, x1, 'PASO 3', 'Coordinamos el pago',
                  'Te respondemos por WhatsApp y acordamos cómo pagar: transferencia, efectivo u otra forma.',
                  'pago')
    y += 60
    fb = fnt(SANS_B, 38)
    d.text((W / 2, y), 'Escribinos y te ayudamos a cerrar el pedido', font=fb, fill=NAVY_SOFT, anchor='ma')
    return img


def h5_dudas():
    img = background()
    d = ImageDraw.Draw(img)
    y = 235
    draw_ls(d, (W / 2, y), 'CÓMO COMPRAR', fnt(SANS_B, 38), EYEBROW, spacing=9, anchor='mt')
    y += 72
    f_h = fnt(SERIF_B, 96)
    d.text((W / 2, y), 'Dudas frecuentes', font=f_h, fill=NAVY, anchor='ma')
    y += 140
    x0, x1 = 70, W - 70
    y = qa_card(img, x0, y, x1, '¿Pago al hacer el pedido?',
                'No. Primero enviás tu pedido y, cuando lo confirmamos por WhatsApp, coordinamos el pago.')
    y += 32
    y = qa_card(img, x0, y, x1, '¿Puedo elegir el aroma después?',
                'Sí. En los productos con aromas hay una opción «Decidir después» y lo charlamos por WhatsApp.')
    y += 32
    y = qa_card(img, x0, y, x1, '¿Tengo que tener cuenta?',
                'No hace falta. Solo tu nombre y tus datos de contacto para armar el pedido.')
    return img


def main():
    stories = [
        ('01-novedad-tienda-online.png', h1_novedad),
        ('02-guia-rapida-como-comprar.png', h2_guia),
        ('03-paso-1-y-2-arma-tu-pedido.png', h3_paso12),
        ('04-paso-3-coordinamos-el-pago.png', h4_paso3),
        ('05-dudas-frecuentes.png', h5_dudas),
    ]
    for name, fn in stories:
        img = fn().convert('RGB')
        path = OUT / name
        img.save(path, 'PNG', optimize=True)
        print(f'OK {path.name} {img.size} {path.stat().st_size // 1024}KB')


if __name__ == '__main__':
    main()
