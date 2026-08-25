$html = Get-Content 'C:\Users\mili_\Downloads\Nueva carpeta\index.html' -Raw -Encoding UTF8
$pdfFile = Get-Content 'C:\Users\mili_\.local\share\opencode\tool-output\tool_038f7c5c4001GYZ8EJF2iJeZP6' -Raw -Encoding UTF8

# Extract HTML products (excluding liquidos)
$liquidosStart = $html.IndexOf('id="cat-liquidos"')
$liquidosEnd = $html.IndexOf('id="cat-escobillones"')
$htmlNoLiquidos = $html.Substring(0, $liquidosStart) + $html.Substring($liquidosEnd)

$nameRegex = [regex]'product-card-name[^>]*>([^<]+)</div>'
$nameMatches = $nameRegex.Matches($htmlNoLiquidos)

$htProducts = @{}
foreach ($m in $nameMatches) {
    $name = $m.Groups[1].Value.Trim()
    $pos = $m.Index + $m.Length
    $remaining = $htmlNoLiquidos.Substring($pos, [Math]::Min(800, $htmlNoLiquidos.Length - $pos))
    
    $priceMatch = [regex]::Match($remaining, 'product-card-price[^>]*>\$([0-9.]+)</div>')
    if (-not $priceMatch.Success) {
        $priceMatch = [regex]::Match($remaining, 'unit-price[^>]*>\$([0-9.]+)</span>')
    }
    if ($priceMatch.Success) {
        $priceStr = $priceMatch.Groups[1].Value.Replace('.', '')
        $price = [int]$priceStr
        $htProducts[$name.ToLower()] = @{ Name = $name; Price = $price }
    }
}

# Extract PDF products (pages 2+), skip asterisk items
$pdfLines = $pdfFile -split "`n"
$pdfProducts = @{}
$currentLine = ""
foreach ($line in $pdfLines) {
    $trimmed = $line.Trim()
    if ($trimmed -match '^\| (.+) \| (\d+) \|$') {
        $prodName = $matches[1].Trim()
        $prodPrice = [int]$matches[2]
        
        # Skip page headers
        if ($prodName -eq 'Product' -or $prodName -eq '---') { continue }
        # Skip asterisk items
        if ($prodName -match '^\*') { continue }
        # Skip zero-price items
        if ($prodPrice -eq 0) { continue }
        
        $pdfProducts[$prodName.ToLower()] = @{ Name = $prodName; Price = $prodPrice }
    }
}

Write-Output "HTML products (non-liquidos): $($htProducts.Count)"
Write-Output "PDF products (pages 2+, no asterisk): $($pdfProducts.Count)"
Write-Output ""

# Find matches with different prices
$diffs = @()
$matchCount = 0
foreach ($key in $htProducts.Keys) {
    if ($pdfProducts.ContainsKey($key)) {
        $matchCount++
        $htmlPrice = $htProducts[$key].Price
        $pdfPrice = $pdfProducts[$key].Price
        if ($htmlPrice -ne $pdfPrice) {
            $diff = $htmlPrice - $pdfPrice
            $diffs += [PSCustomObject]@{
                Product = $htProducts[$key].Name
                HTMLPrice = $htmlPrice
                PDFPrice = $pdfPrice
                Difference = $diff
            }
        }
    }
}

Write-Output "Exact matches found: $matchCount"
Write-Output "Price differences found: $($diffs.Count)"
Write-Output ""

if ($diffs.Count -gt 0) {
    Write-Output "=== PRICE DIFFERENCES ==="
    Write-Output ("{0,-70} {1,10} {2,10} {3,10}" -f "PRODUCT", "HTML $", "PDF $", "DIFF $")
    Write-Output ("{0,-70} {1,10} {2,10} {3,10}" -f ("-" * 70), ("-" * 10), ("-" * 10), ("-" * 10))
    foreach ($d in ($diffs | Sort-Object { [Math]::Abs($_.Difference) } -Descending)) {
        $sign = if ($d.Difference -gt 0) { "+" } else { "" }
        Write-Output ("{0,-70} {1,10:N0} {2,10:N0} {3,10}" -f $d.Product, $d.HTMLPrice, $d.PDFPrice, "$sign$($d.Difference)")
    }
}
