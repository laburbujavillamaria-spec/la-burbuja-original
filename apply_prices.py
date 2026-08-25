import re

# Read the PDF data
with open(r'C:\Users\mili_\.local\share\opencode\tool-output\tool_038c88e44001WyQNEHNsWM65jC', 'r', encoding='utf-8', errors='replace') as f:
    pdf_lines = f.readlines()

# Parse PDF
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
            pdf_products[current_name.strip().lower()] = int(line)
        current_name = None
    else:
        current_name = line

# Read HTML
with open(r'C:\Users\mili_\Downloads\Nueva carpeta\index.html', 'r', encoding='utf-8') as f:
    html = f.read()

# Build list of changes
changes = []
cards = re.split(r'<div\s+class="product-card"', html)
for card in cards[1:]:
    name_match = re.search(r'class="product-card-name">(.*?)</div>', card)
    if not name_match:
        continue
    name = re.sub(r'<[^>]+>', '', name_match.group(1)).strip()
    name_lower = name.lower()
    
    price = None
    price_match = re.search(r'class="product-card-price">\$([\d\.]+)</div>', card)
    if price_match:
        price = price_match.group(1)
    else:
        unit_match = re.search(r'class="unit-price">\$([\d\.]+)</span>', card)
        if unit_match:
            price = unit_match.group(1)
    
    if price and name_lower in pdf_products:
        price_clean = price.replace('.', '').replace(',', '').strip()
        web_price = int(price_clean)
        pdf_price = pdf_products[name_lower]
        if web_price != pdf_price:
            changes.append((name, price, web_price, pdf_price))

# Apply changes
updated = 0
for name, old_price_str, web_price, pdf_price in changes:
    # Format new price with dots as thousands separator
    new_price = f"${pdf_price:,}".replace(",", ".")
    old_price = f"${web_price:,}".replace(",", ".")
    
    # Replace in HTML - handle both product-card-price and unit-price
    # For product-card-price
    old_pattern = f'class="product-card-price">{old_price}</div>'
    new_pattern = f'class="product-card-price">{new_price}</div>'
    if old_pattern in html:
        html = html.replace(old_pattern, new_pattern)
        updated += 1
        print(f"UPDATED (card-price): {name}: {old_price} -> {new_price}")
        continue
    
    # For unit-price
    old_unit = f'class="unit-price">{old_price}</span>'
    new_unit = f'class="unit-price">{new_price}</span>'
    if old_unit in html:
        # Only replace the first occurrence for this product
        idx = html.find(old_unit)
        if idx != -1:
            html = html[:idx] + new_unit + html[idx + len(old_unit):]
            updated += 1
            print(f"UPDATED (unit-price): {name}: {old_price} -> {new_price}")
            continue
    
    # Try with different price format
    print(f"NOT FOUND: {name} (old: {old_price}, new: {new_price})")

# Write back
with open(r'C:\Users\mili_\Downloads\Nueva carpeta\index.html', 'w', encoding='utf-8') as f:
    f.write(html)

print(f"\nTotal updates applied: {updated}")
