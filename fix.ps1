$path = "C:\Users\mili_\Downloads\Nueva carpeta\index.html"
$content = [System.IO.File]::ReadAllText($path)

# 1) Remove DETERGENTE INCOLORO product card
# Find the boundary between DETERGENTE CONCENTRADO and DESODORANTE
$oldDetInc = '<div class="product-card"><img class="product-card-img" src="productos/Liquidos/DETERGENTE INCOLORO X5LT.jpg"'
$idx = $content.IndexOf($oldDetInc)
if ($idx -ge 0) {
    # Find the start of this card (previous <div class="product-card">)
    $cardStart = $content.LastIndexOf('<div class="product-card">', $idx)
    # Find the end (the Consultar</a></div> that closes this card)
    $afterStart = $cardStart
    $depth = 0
    $pos = $afterStart
    while ($pos -lt $content.Length) {
        $openI = $content.IndexOf('<div', $pos)
        $closeI = $content.IndexOf('</div>', $pos)
        if ($openI -ge 0 -and ($closeI -lt 0 -or $openI -lt $closeI)) {
            $depth++
            $pos = $openI + 4
        } elseif ($closeI -ge 0) {
            $depth--
            if ($depth -eq 0) {
                $cardEnd = $closeI + 6
                break
            }
            $pos = $closeI + 6
        } else { break }
    }
    $fullCard = $content.Substring($cardStart, $cardEnd - $cardStart)
    Write-Output "Removing DETERGENTE INCOLORO card ($($fullCard.Length) chars)"
    # Remove the card and the following newline
    $content = $content.Remove($cardStart, $cardEnd - $cardStart)
}

# 2) Replace BOLSA FORCE FLEX 45X60 (has onerror)
$old45 = '<div class="product-card"><img class="product-card-img" src="productos/bolsas/BOLSA%20FORCE%20FLEX%2045X60.jpeg"'
$new45 = '<div class="product-card"><img class="product-card-img" src="productos/bolsas/bolsas%20de%20residuos%2045x60%20x30%20unidades%20green%20plast.jpeg" alt="BOLSAS DE RESIDUOS 45x60 x30"><div class="product-card-name">BOLSAS DE RESIDUOS 45x60 x30</div>'
$content = $content.Replace($old45, $new45)

# 3) Replace remaining "BOLSA FORCE FLEX" in the name/alt fields for 45X60
$content = $content.Replace('alt="BOLSA FORCE FLEX 45X60"', 'alt="BOLSAS DE RESIDUOS 45x60 x30"')
$content = $content.Replace('"BOLSA FORCE FLEX 45X60"', '"BOLSAS DE RESIDUOS 45x60 x30"')
$content = $content.Replace('BOLSA%20FORCE%20FLEX%2045X60', 'BOLSAS%20DE%20RESIDUOS%2045x60%20x30')

# 4) Replace BOLSA FORCE FLEX 60X90
$old60 = 'productos/bolsas/BOLSA%20FORCE%20FLEX%2060X90.jpeg'
$new60 = 'productos/bolsas/bolsas%20de%20residuos%2060x90%20x10%20unidades%20green%20plast.jpeg'
$content = $content.Replace($old60, $new60)
$content = $content.Replace('alt="BOLSA FORCE FLEX 60X90"', 'alt="BOLSAS DE RESIDUOS 60x90 x10"')
$content = $content.Replace('"BOLSA FORCE FLEX 60X90"', '"BOLSAS DE RESIDUOS 60x90 x10"')
$content = $content.Replace('BOLSA%20FORCE%20FLEX%2060X90', 'BOLSAS%20DE%20RESIDUOS%2060x90%20x10')

# 5) Replace BOLSA FORCE FLEX 80X110
$old80 = 'productos/bolsas/BOLSA%20FORCE%20FLEX%2080X110.jpeg'
$new80 = 'productos/bolsas/bolsas%20de%20residuos%20green%20plast%2080x110%20x10unid.jpeg'
$content = $content.Replace($old80, $new80)
$content = $content.Replace('alt="BOLSA FORCE FLEX 80X110"', 'alt="BOLSAS DE RESIDUOS 80x110 x10"')
$content = $content.Replace('"BOLSA FORCE FLEX 80X110"', '"BOLSAS DE RESIDUOS 80x110 x10"')
$content = $content.Replace('BOLSA%20FORCE%20FLEX%2080X110', 'BOLSAS%20DE%20RESIDUOS%2080x110%20x10')

# 6) Replace BOLSAS FORCE FLEX 90X120
$old90 = 'productos/bolsas/BOLSAS%20FORCE%20FLEX%2090X120.jpeg'
$new90 = 'productos/bolsas/bolsas%20de%20residuos%2090x120%20x10%20unidades.jpeg'
$content = $content.Replace($old90, $new90)
$content = $content.Replace('alt="BOLSAS FORCE FLEX 90X120"', 'alt="BOLSAS DE RESIDUOS 90x120 x10"')
$content = $content.Replace('"BOLSAS FORCE FLEX 90X120"', '"BOLSAS DE RESIDUOS 90x120 x10"')
$content = $content.Replace('BOLSAS%20FORCE%20FLEX%2090X120', 'BOLSAS%20DE%20RESIDUOS%2090x120%20x10')

# 7) Fix Silicona full car hidratador src
$oldSil = 'productos/Auto/Silicona%20full%20car%20hidratador%20de%20plasticos%20multiuso%20x1lt.jpeg'
$newSil = 'productos/Auto/silicona%20full%20car%20emulsi%C3%B3n%20de%20silicona%20x1lt%20(Hidratador%20de%20pl%C3%A1sticos).jpeg'
$content = $content.Replace($oldSil, $newSil)

# Write back
[System.IO.File]::WriteAllText($path, $content)
Write-Output "All fixes applied successfully."
