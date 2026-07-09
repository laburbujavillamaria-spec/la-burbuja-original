$text = Get-Content -LiteralPath "C:\Users\mili_\Downloads\Nueva carpeta\raw_text.txt" -Encoding UTF8 -Raw

# Remove the header "Productos encontrados y precios "
$text = $text -replace '^Productos encontrados y precios\s+', ''

# Split by " -> " which separates product entries (product name + description + price)
# Each entry: "PRODUCT_NAME -> Description -- $PRICE"
# The entries are separated by space between prices and next product names
# Actually the pattern is: between each " -- $PRICE " and the next uppercase product name,
# there's just a space

# Simpler: find all " -> " which separates product name from description
$entries = $text -split '(?<=\$[\d.]+)\s+(?=[A-Z])' | Where-Object { $_ -match '\$' }

$priceMap = @{}

foreach ($entry in $entries) {
  $entry = $entry.Trim()
  # Extract price: the last $NUMBERS
  if ($entry -match '\$(\d[\d.]*)\s*$') {
    $price = $matches[1]
  } else { continue }

  # Extract product name: everything before " -> " (arrow)
  if ($entry -match '^(.+?) -> ') {
    $prodName = $matches[1].Trim()
  } else { continue }

  $priceMap[$prodName] = $price
}

# Output as JSON
$priceMap | ConvertTo-Json | Out-File "C:\Users\mili_\Downloads\Nueva carpeta\prices.json" -Encoding UTF8

$priceMap.GetEnumerator() | Sort-Object Name | ForEach-Object {
  Write-Host "$($_.Name) => $($_.Value)"
}
