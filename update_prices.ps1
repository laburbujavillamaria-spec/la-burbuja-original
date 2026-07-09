# Step 1: Read docx and extract prices
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
$fullText = ($text -join ' ') -replace '\s+', ' '
$fullText = $fullText.Trim()
$fullText = $fullText -replace '^Productos encontrados y precios\s+', ''

$arrow = [char]0x2192
$priceMap = @{}
$searchPos = 0

while ($true) {
  $arrowIdx = $fullText.IndexOf($arrow, $searchPos)
  if ($arrowIdx -lt 0) { break }

  $prodName = $fullText.Substring($searchPos, $arrowIdx - $searchPos).Trim()
  $afterArrow = $arrowIdx + 1
  $emDash = [char]0x2014
  $emDashIdx = $fullText.IndexOf($emDash, $afterArrow)
  if ($emDashIdx -lt 0) { break }

  $priceStart = $emDashIdx + 1
  $dollarIdx = $fullText.IndexOf('$', $priceStart)
  if ($dollarIdx -lt 0) { break }

  $numEnd = $dollarIdx + 1
  while ($numEnd -lt $fullText.Length -and $fullText[$numEnd] -match '[\d.]') { $numEnd++ }
  $price = $fullText.Substring($dollarIdx + 1, $numEnd - $dollarIdx - 1)

  $searchPos = $numEnd
  if ($prodName -ne '' -and $price -ne '') {
    $priceMap[$prodName] = $price
  }
}

# Helper: format price with thousands separator
function Format-Price([string]$p) {
  $num = [int]::Parse($p)
  return '$' + $num.ToString('N0', [System.Globalization.CultureInfo]::GetCultureInfo('es-AR')).Replace('.', '.')
}

# Step 2: Read HTML and update prices
$htmlPath = "C:\Users\mili_\Downloads\Nueva carpeta\index.html"
$html = [System.IO.File]::ReadAllText($htmlPath)
$changed = 0
$notFound = @()

foreach ($name in $priceMap.Keys) {
  $price = $priceMap[$name]
  $formatted = Format-Price $price
  # Find the product card by its name div
  $namePattern = 'product-card-name">' + [regex]::Escape($name) + '</div>'
  $match = [regex]::Match($html, $namePattern)
  if ($match.Success) {
    # After the name div, find the price div
    $afterName = $match.Index + $match.Length
    $pricePattern = '<div class="product-card-price">[^<]*</div>'
    $priceMatch = [regex]::Match($html, $pricePattern, $afterName)
    if ($priceMatch.Success -and $priceMatch.Index -lt $afterName + 200) {
      $oldPriceDiv = $priceMatch.Value
      $newPriceDiv = '<div class="product-card-price">' + $formatted + '</div>'
      $html = $html.Substring(0, $priceMatch.Index) + $newPriceDiv + $html.Substring($priceMatch.Index + $priceMatch.Length)
      $changed++
    } else {
      Write-Host "WARNING: Price div not found near '$name'"
    }
  } else {
    $notFound += $name
  }
}

[System.IO.File]::WriteAllText($htmlPath, $html)
Write-Host "Updated $changed prices"
if ($notFound.Count -gt 0) {
  Write-Host "Not found in HTML ($($notFound.Count)):"
  $notFound | ForEach-Object { Write-Host "  - '$_'" }
}
