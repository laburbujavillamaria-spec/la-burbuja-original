$text = Get-Content -LiteralPath "C:\Users\mili_\Downloads\Nueva carpeta\raw_text.txt" -Encoding UTF8 -Raw
$subChar = [char]0x001A
$subIdx = $text.IndexOf($subChar)
Write-Host "First U+001A at index: $subIdx"
if ($subIdx -ge 0) {
  $count = 0; for ($i = 0; $i -lt $text.Length; $i++) { if ($text[$i] -eq $subChar) { $count++ } }
  Write-Host "Total occurrences: $count"
} else {
  Write-Host "No U+001A found in <w:t> extracted text"
  # Check if there are any special separators
  $sample = "LAVANDINA X5LT"
  $idx = $text.IndexOf($sample)
  if ($idx -ge 0) {
    $after = $text.Substring($idx + $sample.Length, 15)
    Write-Host "After '$sample': '$after'"
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($after)
    $hex = ($bytes | ForEach-Object { '{0:X2}' -f $_ }) -join ' '
    Write-Host "Hex: $hex"
  }
}
