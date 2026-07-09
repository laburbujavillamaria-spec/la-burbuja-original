$text = Get-Content -LiteralPath "C:\Users\mili_\Downloads\Nueva carpeta\raw_text.txt" -Encoding UTF8 -Raw

# Remove header
$text = $text -replace '^Productos encontrados y precios\s+', ''

$arrow = [char]0x2192
$entries = $text -split " $arrow "

$priceMap = @{}
foreach ($entry in $entries) {
  $entry = $entry.Trim()
  if ($entry -eq '') { continue }

  # Extract product name: the first entry doesn't have an arrow prefix
  # Format: name-only (first entry) or "description - $PRICE" (rest)
  if ($entry -match '^(.*?)\s+[-]\s+\$(\d[\d.]*)\s*$') {
    $desc = $matches[1].Trim()
    $price = $matches[2]
    # Product name is in the previous entry... but we need to handle this differently
  }
}

# Better approach: the first entry is "Productos encontrados y precios LAVANDINA X5LT"
# which is actually the header + first product name.
# Then each subsequent entry after " → " is: "Description - $PRICE PRODUCT_NAME"
# Actually no - each " → " separates product name (before) from description+price (after)

# Let me rebuild: split differently
# Each product entry: "PRODUCT_NAME → Description — $PRICE"
# So splitting by " → " gives alternating: [product1, desc1, product2, desc2, ...]
# Wait, that's not right either. Let me look at the structure again.

# Actually the text is: "PROD1 → DESC1 - $PRICE1 PROD2 → DESC2 - $PRICE2 ..."
# Each → separates a product name (before) from its description (after)
# After the description+price, the next product name begins (after a space)

# So I need to: split by →, then each right-side piece = "DESC - $PRICE NEXT_PROD"
# and each left-side piece = "PREV_DESC - $PRICE PROD_NAME" (except first)

# Let me just use a different approach
$text2 = $text.Trim()
$arrowStr = " $arrow "
$idx = $text2.IndexOf($arrowStr)
while ($idx -ge 0) {
  # Before the arrow: product name
  $beforeEnd = $idx
  # Find where the product name starts (after previous price)
  $prevPrice = $text2.LastIndexOf(' - $', $idx)
  $nameStart = if ($prevPrice -ge 0) { $prevPrice + 1 } else { 0 }
  # But we also need to skip past the previous price number
  if ($prevPrice -ge 0) {
    $priceNumStart = $prevPrice + 4
    while ($priceNumStart -lt $idx -and $text2[$priceNumStart] -match '[\d.]') { $priceNumStart++ }
    $nameStart = $priceNumStart
  }
  $prodName = $text2.Substring($nameStart, $beforeEnd - $nameStart).Trim()

  # After the arrow: description - $PRICE
  $afterStart = $idx + $arrowStr.Length
  $nextArrow = $text2.IndexOf($arrowStr, $afterStart)
  $descEnd = if ($nextArrow -ge 0) { $nextArrow } else { $text2.Length }
  $descPart = $text2.Substring($afterStart, $descEnd - $afterStart).Trim()

  # Extract price from description
  if ($descPart -match '\-\s*\$(\d[\d.]*)\s*$') {
    $price = $matches[1]
  } else { $price = '' }

  if ($prodName -ne '' -and $price -ne '') {
    $priceMap[$prodName] = $price
  }

  $idx = $nextArrow
}

# Output
$priceMap.GetEnumerator() | Sort-Object Name | ForEach-Object {
  Write-Host "$($_.Name) => $($_.Value)"
}
