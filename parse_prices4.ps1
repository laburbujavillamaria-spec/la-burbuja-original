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

# Extract all <w:t> text and join with newlines per paragraph
$text = [regex]::Matches($xml, '<w:t[^>]*>([^<]+)</w:t>') | ForEach-Object { $_.Groups[1].Value }
$fullText = $text -join " "
$fullText = $fullText -replace '\s+', ' '

# Split by price patterns: find all "$NUMBERS"
$entries = [regex]::Split($fullText, '(?=\$[\d.]+)') | Where-Object { $_ -match '\$[\d.]+' }

$priceMap = @{}
foreach ($entry in $entries) {
  $entry = $entry.Trim()
  # Extract price
  if ($entry -match '\$(\d[\d.]*)') {
    $price = $matches[1]
    # Text before the price, before the dash
    $beforePrice = $entry -replace '\s*-\s*\$[\d.]+.*$', ''
    $beforePrice = $beforePrice.Trim()
    # Take first word as product name clue, but better: take everything before trailing description
    # The pattern is: PRODUCT NAME [sep] Description
    # Remove trailing description which starts with lowercase or *
    if ($beforePrice -match '^([A-Z][A-Z0-9][A-Z0-9\s,./()\-\047]+?)\s+\*?\s*[a-z]') {
      $prodName = $matches[1].Trim()
      $priceMap[$prodName] = $price
    }
  }
}

$priceMap.GetEnumerator() | Sort-Object Name | ForEach-Object {
  Write-Host "$($_.Name) => `$$($_.Value)"
}
