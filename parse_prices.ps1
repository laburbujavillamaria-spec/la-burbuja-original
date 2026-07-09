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

# Extract text preserving structure - paragraphs are separated by <w:p> tags
$text = $xml -replace '<w:p[^>]*>', "`n"  # newline per paragraph
$text = $text -replace '<[^>]+>', ' '      # strip remaining tags
$text = $text -replace '\s+', ' '          # collapse whitespace
$text = $text.Trim()

# Split by lines and extract product -> price
$lines = $text -split "`n"
$priceMap = @{}

foreach ($line in $lines) {
  $line = $line.Trim()
  if ($line -eq "") { continue }
  # Pattern: PRODUCT NAME * description - $PRICE
  if ($line -match '^(.+?)\s+[*]?\s*.+?\s+-\s*\$(\d[\d.]*)') {
    $prodName = $matches[1].Trim().ToUpperInvariant()
    $price = $matches[2]
    # Remove trailing * or special chars from product name
    $prodName = $prodName -replace '\s*\*+\s*$', ''
    $prodName = $prodName.Trim()
    $priceMap[$prodName] = $price
  }
}

# Output as key-value pairs
$priceMap.GetEnumerator() | Sort-Object Name | ForEach-Object {
  Write-Host "$($_.Name) => `$$($_.Value)"
}
