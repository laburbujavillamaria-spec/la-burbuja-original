$htmlPath = "C:\Users\mili_\Downloads\Nueva carpeta\index.html"
$cardsDir = "C:\Users\mili_\Downloads\Nueva carpeta\gen_out5"
$html = Get-Content -LiteralPath $htmlPath -Raw -Encoding UTF8

$map = @{
  "cat-alcohol" = "Alcohol.txt"
  "cat-auto" = "Auto.txt"
  "cat-baldes" = "Baldes.txt"
  "cat-cepillos" = "Cepillos de baño_ Sopapas.txt"
  "cat-esponjas" = "Esponjas.txt"
  "cat-insecticidas" = "Insecticidas.txt"
  "cat-limpiavidrios" = "limpia vidrios.txt"
  "cat-palas" = "Palas de residuos.txt"
  "cat-papel" = "Papel higiénico y rollo de cocina.txt"
  "cat-rociadores" = "Rociadores.txt"
  "cat-secadores" = "Secadores de piso.txt"
  "cat-tachos" = "Tachos de residuos.txt"
}

foreach ($id in $map.Keys) {
  $filePath = Join-Path $cardsDir $map[$id]
  $cards = Get-Content -LiteralPath $filePath -Raw -Encoding UTF8
  $search = "id=`"$id`">*<div class=`"products-grid`">`n      </div>"
  $replacePattern = '<div class="products-grid">' + "`n" + $cards + "`n      </div>"

  # Find the section start
  $sectionStart = "id=`"$id`""
  $startIdx = $html.IndexOf($sectionStart)
  if ($startIdx -eq -1) { Write-Host "ERROR: $id not found!"; continue }

  # Find products-grid opening
  $pgMark = '<div class="products-grid">'
  $pgStart = $html.IndexOf($pgMark, $startIdx)
  if ($pgStart -eq -1) { Write-Host "ERROR: products-grid not found for $id!"; continue }

  # Find the closing </div> of products-grid (the one immediately after)
  $closeDiv = "</div>"
  $pgEnd = $html.IndexOf($closeDiv, $pgStart + $pgMark.Length)
  if ($pgEnd -eq -1) { Write-Host "ERROR: closing div not found for $id!"; continue }

  # Verify this is indeed the empty products-grid pattern
  $between = $html.Substring($pgStart + $pgMark.Length, $pgEnd - $pgStart - $pgMark.Length)
  $betweenTrimmed = $between.Trim()
  if ($betweenTrimmed -ne "") { Write-Host "WARNING: $id products-grid is not empty! Content: [$betweenTrimmed]"; continue }

  # Replacement: from <div class="products-grid"> to the matching </div>
  $len = $pgEnd + $closeDiv.Length - $pgStart
  $oldFragment = $html.Substring($pgStart, $len)

  # New fragment: products-grid opening + \n + cards + \n + indented closing
  $newFragment = $pgMark + "`n" + $cards + "`n      </div>"

  $html = $html.Substring(0, $pgStart) + $newFragment + $html.Substring($pgStart + $len)
  Write-Ho st "Replaced $id"
}

Set-Content -LiteralPath $htmlPath -Value $html -Encoding UTF8
Write-Host "Done!"
