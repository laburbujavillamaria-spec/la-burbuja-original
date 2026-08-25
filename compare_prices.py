import re

# Read the PDF data
with open(r'C:\Users\mili_\.local\share\opencode\tool-output\tool_038c88e44001WyQNEHNsWM65jC', 'r', encoding='utf-8', errors='replace') as f:
    pdf_lines = f.readlines()

# Parse PDF: extract product names and prices
pdf_products = {}
current_name = None
for line in pdf_lines:
    line = line.strip()
    if line.startswith('--- Page') or 'fitz' in line.lower():
        continue
    if not line:
        continue
    if re.match(r'^\d+$', line):
        if current_name and int(line) > 0:
            name_lower = current_name.strip().lower()
            pdf_products[name_lower] = int(line)
        current_name = None
    else:
        current_name = line

# Now read the index.html
with open(r'C:\Users\mili_\Downloads\Nueva carpeta\index.html', 'r', encoding='utf-8') as f:
    html = f.read()

# Extract products - handle both patterns:
# Pattern 1: product-card-name + product-card-price
# Pattern 2: product-card-name + unit-row with unit-price (first unit only for simplicity)
web_products = {}

# Find all product-card blocks
# Split by product-card div
cards = re.split(r'<div\s+class="product-card"', html)
for card in cards[1:]:  # skip first split (before first card)
    # Extract name
    name_match = re.search(r'class="product-card-name">(.*?)</div>', card)
    if not name_match:
        continue
    name = re.sub(r'<[^>]+>', '', name_match.group(1)).strip()
    name_lower = name.lower()
    
    # Extract price - try product-card-price first, then unit-price
    price = None
    price_match = re.search(r'class="product-card-price">\$([\d\.]+)</div>', card)
    if price_match:
        price = price_match.group(1)
    else:
        # Try unit-price (first occurrence)
        unit_match = re.search(r'class="unit-price">\$([\d\.]+)</span>', card)
        if unit_match:
            price = unit_match.group(1)
    
    if price:
        price_clean = price.replace('.', '').replace(',', '').strip()
        try:
            price_num = int(price_clean)
            if price_num > 0:
                web_products[name_lower] = price_num
        except:
            pass

print(f"PDF products (non-zero): {len(pdf_products)}")
print(f"Web products: {len(web_products)}")
print()

# Compare
changes = []
for name, pdf_price in pdf_products.items():
    if name in web_products:
        web_price = web_products[name]
        if pdf_price != web_price:
            diff = pdf_price - web_price
            pct = round((diff / web_price) * 100, 1) if web_price > 0 else 0
            direction = "HIGHER" if diff > 0 else "LOWER"
            changes.append((name, web_price, pdf_price, diff, pct, direction))

changes.sort(key=lambda x: abs(x[3]), reverse=True)

higher = [c for c in changes if c[5] == "HIGHER"]
lower = [c for c in changes if c[5] == "LOWER"]

print(f"Total products with price differences: {len(changes)}")
print(f"  - PDF HIGHER than website (needs updating): {len(higher)}")
print(f"  - PDF LOWER than website: {len(lower)}")
print()

print("=== PRODUCTS WHERE PDF PRICE IS HIGHER (WEBSITE NEEDS UPDATING) ===")
for name, web_p, pdf_p, diff, pct, direction in higher:
    print(f"  {name[:65]:<67} Web: ${web_p:>7,}  PDF: ${pdf_p:>7,}  (+{diff:,}, +{pct}%)")

print()
print("=== PRODUCTS WHERE PDF PRICE IS LOWER ===")
for name, web_p, pdf_p, diff, pct, direction in lower:
    print(f"  {name[:65]:<67} Web: ${web_p:>7,}  PDF: ${pdf_p:>7,}  ({diff:,}, {pct}%)")
