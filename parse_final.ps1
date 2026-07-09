$text = Get-Content -LiteralPath "C:\Users\mili_\Downloads\Nueva carpeta\raw_text.txt" -Encoding UTF8 -Raw

# Remove header
$text = $text -replace '^Productos encontrados y precios\s+', ''

# Split by looking for " - $" which ends each price
# Strategy: scan for all " - $" occurrences, extract the price and preceding text
$results = @()

$searchFrom = 0
while ($true) {
  $dollarIdx = $text.IndexOf(' - $', $searchFrom)
  if ($dollarIdx -lt 0) { break }

  # Start of number = dollarIdx + 4
  $numStart = $dollarIdx + 4

  # Find end of number
  $numEnd = $numStart
  while ($numEnd -lt $text.Length -and $text[$numEnd] -match '[\d.]') { $numEnd++ }

  $price = $text.Substring($numStart, $numEnd - $numStart)

  # The product name ends at a sequence that leads into description.
  # From the raw text: "PRODUCT_NAME \x1a Description"
  # We need to find where PRODUCT_NAME ends - it ends at the first U+001A char before $dollarIdx
  $nameEnd = $text.LastIndexOf([char]0x001A, $dollarIdx)
  if ($nameEnd -ge 0) {
    $nameStart = $text.LastIndexOf(' ', $nameEnd - 2) + 1
    if ($nameStart -gt $text.Substring(0, $nameEnd - 1).LastIndexOf(' - $')) {
      # This is after the previous price - correct name
    }
    $prodName = $text.Substring($nameStart, $nameEnd - $nameStart).Trim()
    # Clean up any leading junk
    if ($prodName -match '([A-Z][A-Z0-9].+)') {
      $prodName = $matches[1]
    }
    $results += [PSCustomObject]@{ Name = $prodName; Price = $price }
  }

  $searchFrom = $dollarIdx + 1
  if ($searchFrom -ge $text.Length) { break }
}

foreach ($r in $results) {
  Write-Host "$($r.Name) => `$$($r.Price)"
}
