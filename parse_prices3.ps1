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

# Split by <w:p> tags to get paragraphs
$paragraphs = [regex]::Split($xml, '<w:p[ >]') | Where-Object { $_ -match '<w:t' }

$priceMap = @{}

foreach ($para in $paragraphs) {
  # Extract text from <w:t> tags within this paragraph
  $textParts = [regex]::Matches($para, '<w:t[^>]*>([^<]+)</w:t>') | ForEach-Object { $_.Groups[1].Value }
  $line = ($textParts -join '').Trim()
  if ($line -eq "") { continue }

  # Try to match pattern: PRODUCT_NAME ... - $PRICE
  if ($line -match '\-\s*\$(\d[\d.]*)\s*$') {
    $price = $matches[1]
    # Everything before the price is the product info
    $beforePrice = $line -replace '\s*\-\s*\$' + [regex]::Escape($price) + '\s*$', ''
    # Take the first word group (uppercase product name) as key
    if ($beforePrice -match '^([A-Z][A-ZÁÉÍÓÚÑ0-9][A-ZÁÉÍÓÚÑ0-9\s,./()\-]+?)') {
      $prodName = $matches[1].Trim()
      $priceMap[$prodName] = $price
    }
  }
}

$priceMap.GetEnumerator() | Sort-Object Name | ForEach-Object {
  Write-Host "$($_.Name) => `$$($_.Value)"
}
