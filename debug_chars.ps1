$text = Get-Content -LiteralPath 'C:\Users\mili_\Downloads\Nueva carpeta\raw_text.txt' -Encoding UTF8 -Raw
Write-Host 'Chars around arrow:'
$idx = $text.IndexOf('X5LT')
$idx2 = $text.IndexOf(' ', $idx + 1)
$idx3 = $text.IndexOf(' ', $idx2 + 1)
$slice = $text.Substring($idx3, 10)
for ($i = 0; $i -lt $slice.Length; $i++) {
  $c = $slice[$i]
  Write-Host ('  char {0}: U+{1:X4} = [{2}]' -f $i, [int][char]$c, $c)
}
