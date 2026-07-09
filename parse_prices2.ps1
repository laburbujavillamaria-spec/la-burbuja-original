$src = "C:\Users\mili_\Downloads\Nueva carpeta\productos\Productos CON PRECIOS.docx"
$dst = "C:\Users\mili_\Downloads\Nueva carpeta\temp_prices.docx"
Copy-Item -LiteralPath $src -Destination $dst -Force

Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
$zip = [System.IO.Compression.ZipFile]::OpenRead($dst)
$entry = $zip.GetEntry('word/document.xml')
$stream = $entry.Open()
$reader = New-Object System.IO.StreamReader($stream)
$xml = $reader.ReadToEnd()
$reader.Close()
$stream.Close()
$zip.Dispose()

# Extract text from <w:t> tags which contain the actual text in OOXML
$text = [regex]::Matches($xml, '<w:t[^>]*>([^<]+)</w:t>') | ForEach-Object { $_.Groups[1].Value }
$fullText = $text -join ' '
$fullText = $fullText -replace '\s+', ' '
$fullText = $fullText.Trim()

# Parse products: pattern is "PRODUCT NAME [*] Description - $PRICE"
# Split by known separators: uppercase product name followed by optional * then description then - $PRICE
$pattern = '([A-Z][A-ZÁÉÍÓÚÑ0-9][A-ZÁÉÍÓÚÑ0-9\s,./()]+?)\s+\*?\s*[A-Za-záéíóúñ][^$]+\s*-\s*\$([\d.]+)'
$matches = [regex]::Matches($fullText, $pattern)

$priceMap = @{}
foreach ($m in $matches) {
  $prodName = $m.Groups[1].Value.Trim()
  $price = $m.Groups[2].Value
  # Strip trailing special chars from product name
  $prodName = $prodName -replace '\s*\*+\s*$', ''
  $prodName = $prodName.Trim()
  $priceMap[$prodName] = $price
  Write-Host "$prodName => $$price"
}
