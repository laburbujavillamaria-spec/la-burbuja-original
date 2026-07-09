$text = Get-Content -LiteralPath "C:\Users\mili_\Downloads\Nueva carpeta\raw_text.txt" -Encoding UTF8 -Raw

# Remove header
$text = $text -replace '^Productos encontrados y precios\s+', ''

$arrow = [char]0x2192
$emDash = [char]0x2014

# Build the price map
$priceMap = @{}

# Find each product: from start or after previous price, up to the arrow
$searchPos = 0
while ($true) {
  # Find the arrow that separates product name from description
  $arrowIdx = $text.IndexOf($arrow, $searchPos)
  if ($arrowIdx -lt 0) { break }

  # Product name = text from $searchPos to $arrowIdx, trimmed
  $prodName = $text.Substring($searchPos, $arrowIdx - $searchPos).Trim()

  # After arrow: description until price separator
  $afterArrow = $arrowIdx + 1
  $emDashIdx = $text.IndexOf($emDash, $afterArrow)
  if ($emDashIdx -lt 0) { break }

  # Description = between arrow and em-dash
  $desc = $text.Substring($afterArrow, $emDashIdx - $afterArrow).Trim()

  # Price = after em-dash until next product name (space followed by uppercase)
  $priceStart = $emDashIdx + 1
  # Skip past " $" and number
  $dollarIdx = $text.IndexOf('$', $priceStart)
  if ($dollarIdx -lt 0) { break }

  # Find end of price number
  $numEnd = $dollarIdx + 1
  while ($numEnd -lt $text.Length -and $text[$numEnd] -match '[\d.]') { $numEnd++ }
  $price = $text.Substring($dollarIdx + 1, $numEnd - $dollarIdx - 1)

  # Update search position: after the price number
  $searchPos = $numEnd

  if ($prodName -ne '' -and $price -ne '') {
    $priceMap[$prodName] = $price
  }
}

foreach ($key in ($priceMap.Keys | Sort-Object)) {
  Write-Host "$key => $($priceMap[$key])"
}
