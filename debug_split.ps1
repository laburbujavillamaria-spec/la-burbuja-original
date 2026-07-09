$text = Get-Content -LiteralPath "C:\Users\mili_\Downloads\Nueva carpeta\raw_text.txt" -Encoding UTF8 -Raw

# Remove the header
$text = $text -replace '^Productos encontrados y precios\s+', ''

# Debug: write individual pieces
$text | Out-File "C:\Users\mili_\Downloads\Nueva carpeta\debug1.txt" -Encoding UTF8

# Try splitting after each price pattern
$parts = $text -split '(?<=\$[\d.]+)\s+(?=[A-Z])'
$parts | Out-File "C:\Users\mili_\Downloads\Nueva carpeta\debug_parts.txt" -Encoding UTF8
Write-Host "Number of parts: $($parts.Count)"

# Also try splitting by arrow directly
$byArrow = $text -split ' -> '
$byArrow | Out-File "C:\Users\mili_\Downloads\Nueva carpeta\debug_arrow.txt" -Encoding UTF8
Write-Host "Arrow parts: $($byArrow.Count)"
