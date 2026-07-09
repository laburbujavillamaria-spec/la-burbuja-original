$htmlPath = "C:\Users\mili_\Downloads\Nueva carpeta\index.html"
$cardsDir = "C:\Users\mili_\Downloads\Nueva carpeta\gen_out5"
$html = [System.IO.File]::ReadAllText($htmlPath)

$map = @{
  "cat-alcohol" = "Alcohol.txt"
  "cat-auto" = "Auto.txt"
  "cat-baldes" = "Baldes.txt"
  "cat-cepillos" = "Cepillos de ba"
  "cat-esponjas" = "Esponjas.txt"
  "cat-insecticidas" = "Insecticidas.txt"
  "cat-limpiavidrios" = "limpia vidrios.txt"
  "cat-palas" = "Palas de residuos.txt"
  "cat-papel" = "Papel higi"
  "cat-rociadores" = "Rociadores.txt"
  "cat-secadores" = "Secadores de piso.txt"
  "cat-tachos" = "Tachos de residuos.txt"
}

foreach ($id in $map.Keys) {
  $cards = ""
  $pattern = $map[$id]

  # Find matching file by prefix
  $file = Get-ChildItem -LiteralPath $cardsDir -Filter "$pattern*" | Select-Object -First 1
  if ($file -eq $null) {
    Write-Host "ERROR: No file matching '$pattern' for $id"
    continue
  }
  $cards = [System.IO.File]::ReadAllText($file.FullName)

  # Find section by id
  $sectionStart = "id=`"$id`""
  $pgMark = '<div class="products-grid">'
  $closeDiv = "</div>"

  $startIdx = $html.IndexOf($sectionStart)
  if ($startIdx -eq -1) { Write-Host "ERROR: $id not found!"; continue }

  $pgStart = $html.IndexOf($pgMark, $startIdx)
  if ($pgStart -eq -1) { Write-Host "ERROR: products-grid not found for $id!"; continue }

  # After products-grid opening, find next </div>
  $pgEnd = $html.IndexOf($closeDiv, $pgStart + $pgMark.Length)
  if ($pgEnd -eq -1) { Write-Host "ERROR: closing div not found for $id!"; continue }

  # Sanity check: verify content between is whitespace only
  $between = $html.Substring($pgStart + $pgMark.Length, $pgEnd - $pgStart - $pgMark.Length)
  if ($between.Trim() -ne "") {
    Write-Host "WARNING: $id products-grid is NOT empty - skipping"
    continue
  }

  $len = $pgEnd + $closeDiv.Length - $pgStart
  $oldFragment = $html.Substring($pgStart, $len)
  $newFragment = $pgMark + "`r`n" + $cards + "`r`n      </div>"

  $html = $html.Substring(0, $pgStart) + $newFragment + $html.Substring($pgStart + $len)
  Write-Host "OK $id"
}

[System.IO.File]::WriteAllText($htmlPath, $html)
Write-Host "Done!"
