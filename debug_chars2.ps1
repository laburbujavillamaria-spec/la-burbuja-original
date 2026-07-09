$text = Get-Content -LiteralPath 'C:\Users\mili_\Downloads\Nueva carpeta\raw_text.txt' -Encoding UTF8 -Raw

# Look for non-ASCII characters around product names
for ($i = 0; $i -lt $text.Length; $i++) {
  $c = [int][char]$text[$i]
  if ($c -gt 127 -and $c -lt 300) {
    Write-Host "Found U+$('{0:X4}' -f $c) at position $i"
    # Show context
    $start = [Math]::Max(0, $i - 20)
    $len = [Math]::Min(41, $text.Length - $start)
    $context = $text.Substring($start, $len)
    Write-Host "  Context: ...$context..."
  }
}
