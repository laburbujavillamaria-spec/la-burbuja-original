$src = "C:\Users\mili_\Downloads\Nueva carpeta\productos\Productos CON PRECIOS.docx"
$dst = "C:\Users\mili_\Downloads\Nueva carpeta\temp_prices.docx"
Copy-Item -LiteralPath $src -Destination $dst -Force

Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
$zip = [System.IO.Compression.ZipFile]::OpenRead($dst)
$entry = $zip.GetEntry('word/document.xml')
$reader = New-Object System.IO.StreamReader($entry.Open())
$xml = $reader.ReadToEnd()
$reader.Close()
$zip.Dispose()

# Extract text from <w:t> tags
$texts = [regex]::Matches($xml, '<w:t[^>]*>([^<]+)</w:t>') | ForEach-Object { $_.Groups[1].Value }
$fullText = ($texts -join " ") -replace '\s+', ' '
$fullText = $fullText.Trim()

# Parse: each product has " - $PRICE" at the end
# Split on " - $" pattern (dash-space-dollar)
$separator = " - `$"
$entries = $fullText -split "(?=\Q$separator\E)"
$entries = $entries | Where-Object { $_ -match '\$[\d.]+' }

$priceMap = @{}
foreach ($entry in $entries) {
  $entry = $entry.Trim()
  # Extract price: the last $NUMBERS in the entry
  if ($entry -match '\$(\d[\d.]*)\s*$') {
    $price = $matches[1]
    # Text before the " - $PRICE" suffix
    $idx = $entry.LastIndexOf(" - `$$price")
    if ($idx -ge 0) {
      $beforePrice = $entry.Substring(0, $idx).Trim()
      # Product name is the uppercase segment before lowercased description
      # Look for pattern: UPPERCASE WORDS + separator + description
      if ($beforePrice -match '^([A-Z][A-Z0-9][A-Z0-9\s,./()\-\047]+?)\s+[*]?\s*[a-z]') {
        $prodName = $matches[1].Trim()
        $priceMap[$prodName] = $price
      }
    }
  }
}

$priceMap.GetEnumerator() | Sort-Object Name | ForEach-Object {
  Write-Host "$($_.Name) => `$$($_.Value)"
}
