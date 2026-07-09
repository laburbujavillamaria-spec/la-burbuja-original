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

$text = [regex]::Matches($xml, '<w:t[^>]*>([^<]+)</w:t>') | ForEach-Object { $_.Groups[1].Value }
$fullText = ($text -join " ") -replace '\s+', ' '

# Split by " - $" pattern (dash-space-dollar which precedes each price)
$parts = $fullText -split '(?=\s*\-\s*\$)' | Where-Object { $_ -match '\$' }

$priceMap = @{}
foreach ($part in $parts) {
  $part = $part.Trim()
  if ($part -match '\$(\d[\d.]*)\s*$') {
    $price = $matches[1]
    $beforePrice = $part -replace '\s*-\s*\$[\d.]+\s*$', ''
    $beforePrice = $beforePrice.Trim()
    # Take the first segment (product name) which is fully uppercase
    $prodName = ($beforePrice -split '\s+[]?\s*\*?\s*[a-z]')[0]
    $prodName = $prodName.Trim()
    if ($prodName -ne '') {
      $priceMap[$prodName] = $price
    }
  }
}

$priceMap.GetEnumerator() | Sort-Object Name | ForEach-Object {
  Write-Host "$($_.Name) => `$$($_.Value)"
}
