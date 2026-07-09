$text = Get-Content -LiteralPath "C:\Users\mili_\Downloads\Nueva carpeta\raw_text.txt" -Encoding UTF8 -Raw
$subIdx = $text.IndexOf([char]0x001A)
Write-Host "First U+001A at index: $subIdx"
if ($subIdx -ge 0) {
  $ctx = $text.Substring([Math]::Max(0, $subIdx - 10), 30)
  Write-Host "Context: '$ctx'"
  # Count occurrences
  $count = 0
  for ($i = 0; $i -lt $text.Length; $i++) {
    if ($text[$i] -eq [char]0x001A) { $count++ }
  }
  Write-Host "Total occurrences: $count"
} else {
  Write-Host "No U+001A found"
  # Show what's between product name and description
  $sample = "LAVANDINA X5LT"
  $idx = $text.IndexOf($sample)
  if ($idx -ge 0) {
    $after = $text.Substring($idx + $sample.Length, 20)
    Write-Host "After '$sample': '$after'"
    for ($i = 0; $i -lt $after.Length; $i++) {
      $c = [int][char]$after[$i]
      Write-Host "  char $i: U+$('{0:X4}' -f $c) = [$c]"
    }
  }
}
