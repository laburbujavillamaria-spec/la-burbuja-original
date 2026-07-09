$text = Get-Content -LiteralPath "C:\Users\mili_\Downloads\Nueva carpeta\raw_text.txt" -Encoding UTF8 -Raw
$dollarIdx = $text.IndexOf('$6600')
if ($dollarIdx -ge 0) {
  $before = $text.Substring($dollarIdx - 10, 15)
  Write-Host "Context before '\$6600': '$before'"
  for ($i = 0; $i -lt $before.Length; $i++) {
    $c = [int][char]$before[$i]
    Write-Host "  $i: U+$('{0:X4}' -f $c)"
  }
}
