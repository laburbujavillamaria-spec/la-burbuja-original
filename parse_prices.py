import zipfile, re, shutil

docx_path = r'C:\Users\mili_\Downloads\Nueva carpeta\productos\Productos CON PRECIOS.docx'
copy_path = r'C:\Users\mili_\Downloads\Nueva carpeta\temp_prices.docx'
shutil.copy2(docx_path, copy_path)

with zipfile.ZipFile(copy_path) as z:
    xml = z.read('word/document.xml').decode('utf-8')

texts = re.findall(r'<w:t[^>]*>([^<]+)</w:t>', xml)
full_text = ' '.join(texts)
full_text = re.sub(r'\s+', ' ', full_text).strip()

entries = [x.strip() for x in re.split(r'(?=\s*\-\s*\$)', full_text) if '$' in x]

prices = {}
for e in entries:
    m = re.search(r'\$([\d.]+)\s*$', e)
    if m:
        price = m.group(1)
        before = re.sub(r'\s*-\s*\$[\d.]+\s*$', '', e).strip()
        m2 = re.match(r'^([A-Z][A-Z0-9][A-Z0-9\s,./()\'-]+?)(?:\s+[*]?\s*[a-z])', before)
        if m2:
            name = m2.group(1).strip()
            prices[name] = price

for k in sorted(prices.keys()):
    print(f'{k} => ${prices[k]}')
