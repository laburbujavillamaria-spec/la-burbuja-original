$html = Get-Content 'C:\Users\mili_\Downloads\Nueva carpeta\index.html' -Raw -Encoding UTF8

# Find cat-liquidos section boundaries
$liquidosStart = $html.IndexOf('id="cat-liquidos"')
$liquidosEnd = $html.IndexOf('id="cat-escobillones"')

# Remove the liquidos section entirely
$htmlNoLiquidos = $html.Substring(0, $liquidosStart) + $html.Substring($liquidosEnd)

# Extract all product cards - get name first, then find nearest price after it
$nameRegex = [regex]'product-card-name[^>]*>([^<]+)</div>'
$nameMatches = $nameRegex.Matches($htmlNoLiquidos)

foreach ($m in $nameMatches) {
    $name = $m.Groups[1].Value.Trim()
    $pos = $m.Index + $m.Length
    $remaining = $htmlNoLiquidos.Substring($pos, [Math]::Min(800, $htmlNoLiquidos.Length - $pos))
    
    # Try product-card-price first
    $priceMatch = [regex]::Match($remaining, 'product-card-price[^>]*>\$([0-9.]+)</div>')
    if ($priceMatch.Success) {
        Write-Output ("{0}|{1}" -f $name, $priceMatch.Groups[1].Value)
    } else {
        # Try unit-price
        $unitMatch = [regex]::Match($remaining, 'unit-price[^>]*>\$([0-9.]+)</span>')
        if ($unitMatch.Success) {
            Write-Output ("{0}|{1}" -f $name, $unitMatch.Groups[1].Value)
        }
    }
}
