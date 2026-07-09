$htmlPath = "C:\Users\mili_\Downloads\Nueva carpeta\index.html"
$cardsPath = "C:\Users\mili_\Downloads\Nueva carpeta\gen_cepillos_output.txt"
$html = [System.IO.File]::ReadAllText($htmlPath)
$newCards = [System.IO.File]::ReadAllText($cardsPath)

$id = "cat-cepillos"
$pgMark = '<div class="products-grid">'
$closeDiv = "</div>"

$startIdx = $html.IndexOf("id=`"$id`"")
$pgStart = $html.IndexOf($pgMark, $startIdx)

# Find the matching closing </div> by tracking depth
$gridContentStart = $pgStart + $pgMark.Length
$depth = 1
$i = $gridContentStart
while ($depth -gt 0 -and $i -lt $html.Length) {
  $nextOpen = $html.IndexOf('<div ', $i)
  $nextClose = $html.IndexOf($closeDiv, $i)
  if ($nextClose -eq -1) { break }
  if ($nextOpen -ne -1 -and $nextOpen -lt $nextClose) {
    $depth++
    $i = $nextOpen + 5
  } else {
    $depth--
    $i = $nextClose + 6
  }
}
$gridEnd = $i

$oldFragment = $html.Substring($pgStart, $gridEnd - $pgStart)
$newFragment = $pgMark + "`r`n" + $newCards + "`r`n      </div>"

$html = $html.Substring(0, $pgStart) + $newFragment + $html.Substring($gridEnd)
[System.IO.File]::WriteAllText($htmlPath, $html)
Write-Host "Replaced Cepillos cards"
