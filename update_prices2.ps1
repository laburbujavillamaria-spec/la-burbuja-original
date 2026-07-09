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

Write-Host "Found $($priceMap.Count) prices"

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
  # Find the product card by its name: <div class="product-card-name">NAME</div>
  $searchFor = '<div class="product-card-name">' + $name + '</div>'
  $nameIdx = $html.IndexOf($searchFor, [System.StringComparison]::Ordinal)
  if ($nameIdx -ge 0) {
    $afterNameStart = $nameIdx + $searchFor.Length
    # Find the next product-card-price div after this name
    $priceSearchFor = '<div class="product-card-price">'
    $priceIdx = $html.IndexOf($priceSearchFor, $afterNameStart, [System.StringComparison]::Ordinal)
    if ($priceIdx -ge 0 -and $priceIdx -lt $afterNameStart + 500) {
      $afterPriceStart = $priceIdx + $priceSearchFor.Length
      $closeIdx = $html.IndexOf('</div>', $afterPriceStart, [System.StringComparison]::Ordinal)
      if ($closeIdx -ge 0 -and $closeIdx -lt $afterPriceStart + 100) {
        # Replace the content between <div class="product-card-price"> and </div>
        $oldContent = $html.Substring($afterPriceStart, $closeIdx - $afterPriceStart)
        $html = $html.Substring(0, $afterPriceStart) + $formatted + $html.Substring($closeIdx)
        $changed++
      }
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
