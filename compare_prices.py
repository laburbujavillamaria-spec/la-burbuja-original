import fitz
import re

# === 1. EXTRACT PDF PRODUCTS ===
doc = fitz.open(r"C:\Users\mili_\Desktop\Lista_de_precios_04-09-26.pdf")
pdf_text = ""
for page in doc:
    pdf_text += page.get_text() + "\n"
doc.close()

# Parse PDF: product name line followed by $price line
pdf_products = {}
lines = [l.strip() for l in pdf_text.split('\n') if l.strip()]
i = 0
while i < len(lines) - 1:
    name_line = lines[i]
    price_line = lines[i + 1].replace(',', '')
    
    price_match = re.match(r'^\$?([\d\.]+)$', price_line)
    if price_match:
        # Argentine format: . is thousands separator
        price_str = price_match.group(1).replace('.', '').replace(',', '')
        price_val = int(price_str) if price_str else 0
        
        # Skip products with * or ... or price is 0
        if '*' in name_line or '...' in name_line or '..' in name_line or price_val == 0:
            i += 2
            continue
        
        name_normalized = re.sub(r'\s+', ' ', name_line.lower().strip())
        pdf_products[name_normalized] = price_val
        i += 2
    else:
        i += 1

print(f"=== PDF PRODUCTS EXTRACTED: {len(pdf_products)} ===\n")

# === 2. READ HTML ===
html_path = r"C:\Users\mili_\Downloads\Nueva carpeta\index.html"
with open(html_path, 'r', encoding='utf-8') as f:
    html_content = f.read()

# === 3. COMPARE ALL PRODUCT CARDS ===
card_pattern = re.compile(r'<div\s+class="product-card"[^>]*>.*?(?=<div\s+class="product-card"[^>]*>|$)', re.DOTALL)
cards = list(card_pattern.finditer(html_content))

print(f"Product cards found in HTML: {len(cards)}")
print()

# Comparison results
higher_than_web = []  # PDF price > web price (needs increase)
lower_than_web = []   # PDF price < web price (web is higher)
no_match = []         # Not found in PDF
exact_match = []      # Same price
skipped = []          # Skipped due to * or ...

for card_match in cards:
    card_text = card_match.group(0)
    
    name_match = re.search(r'class="product-card-name"[^>]*>(.*?)</div>', card_text)
    if not name_match:
        continue
    
    raw_name = name_match.group(1)
    name_clean = re.sub(r'<[^>]+>', '', raw_name).strip()
    name_normalized = re.sub(r'\s+', ' ', name_clean.lower())
    
    # Skip check
    if '*' in name_clean or '...' in name_clean or '..' in name_clean:
        skipped.append(name_clean)
        continue
    
    if name_normalized not in pdf_products:
        no_match.append(name_clean)
        continue
    
    pdf_price = pdf_products[name_normalized]
    
    # Extract web price
    price_match = re.search(r'class="product-card-price">\$([\d\.]+)</div>', card_text)
    unit_match = None
    if not price_match:
        unit_match = re.search(r'class="unit-price">\$([\d\.]+)</span>', card_text)
    
    if price_match:
        web_price = int(float(price_match.group(1).replace('.', '').replace(',', '')))
    elif unit_match:
        web_price = int(float(unit_match.group(1).replace('.', '').replace(',', '')))
    else:
        no_match.append(name_clean + " (no price found)")
        continue
    
    diff = pdf_price - web_price
    pct = round((diff / web_price) * 100, 1) if web_price > 0 else 0
    
    if diff > 0:
        higher_than_web.append((name_clean, web_price, pdf_price, diff, pct))
    elif diff < 0:
        lower_than_web.append((name_clean, web_price, pdf_price, diff, pct))
    else:
        exact_match.append(name_clean)

# Sort by absolute difference
higher_than_web.sort(key=lambda x: abs(x[3]), reverse=True)
lower_than_web.sort(key=lambda x: abs(x[3]), reverse=True)

# === 4. REPORT ===
print("=" * 90)
print("RESUMEN DE COMPARACION DE PRECIOS")
print("=" * 90)
print(f"\nTotal tarjetas de productos encontradas: {len(cards)}")
print(f"Productos sin match en PDF:               {len(no_match)}")
print(f"Productos con * o ... (saltados):         {len(skipped)}")
print(f"Precios exactos (sin cambios):            {len(exact_match)}")
print(f"PDF MAYOR que web (subir precio):         {len(higher_than_web)}")
print(f"PDF MENOR que web (web esta mas alto):    {len(lower_than_web)}")

if higher_than_web:
    print(f"\n{'='*90}")
    print("PRODUCTOS DONDE EL PDF TIENE PRECIO MAYOR (DEBE SUBIR)")
    print(f"{'='*90}")
    print(f"{'Producto':<62} {'Web':>8} {'PDF':>8} {'Dif':>8} {'%':>7}")
    print("-" * 90)
    for name, web_p, pdf_p, diff, pct in higher_than_web:
        print(f"  {name[:60]:<60} ${web_p:>6,} ${pdf_p:>6,} +${diff:>5,} +{pct}%")

if lower_than_web:
    print(f"\n{'='*90}")
    print("PRODUCTOS DONDE EL PDF TIENE PRECIO MENOR (WEB ESTA MAS ALTO)")
    print(f"{'='*90}")
    print(f"{'Producto':<62} {'Web':>8} {'PDF':>8} {'Dif':>8} {'%':>7}")
    print("-" * 90)
    for name, web_p, pdf_p, diff, pct in lower_than_web:
        print(f"  {name[:60]:<60} ${web_p:>6,} ${pdf_p:>6,} -${abs(diff):>5,} {pct}%")

if no_match:
    print(f"\n{'='*90}")
    print(f"PRODUCTOS EN WEB SIN ENCONTRAR EN PDF ({len(no_match)}):")
    print(f"{'='*90}")
    for name in no_match[:30]:
        print(f"  - {name[:60]}")
    if len(no_match) > 30:
        print(f"  ... y {len(no_match) - 30} mas")

print(f"\n{'='*90}")
print("NOTA: No se modifico ningun archivo. Esto es solo un informe.")
print("Si estas de acuerdo, se podrian aplicar los cambios de los productos")
print("donde el PDF tiene precio MAYOR al de la web.")
print(f"{'='*90}")
