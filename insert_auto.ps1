$file = "C:\Users\mili_\Downloads\Nueva carpeta\index.html"
$lines = [System.IO.File]::ReadAllLines($file)

$waSvg = '<svg width="9" height="9" viewBox="0 0 24 24" fill="currentColor"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/></svg>'

$files = @(
  "aromatizador cuadrado square full car.jpeg",
  "aromatizante de ambientes aer power.jpeg",
  "caritas saphirus.jpeg",
  "Cera full car brillo express rosa x1lt.jpeg",
  "Desengrasante para motores walker x1lt.jpeg",
  "Esponja de lavado laffite.jpeg",
  "Esponja de microfibra laffitte.jpeg",
  "Gamuza sintetica laffitte paño chamois tamaño normal.jpeg",
  "gamuza sintetica laffitte paño chamois tamaño XL.jpeg",
  "Glade autosport aparato.jpeg",
  "Glade autosport repuesto.jpeg",
  "glade sensations aparato para auto.jpeg",
  "Laffitte Pulido perfecto.jpeg",
  "Limpia tapizados full car x1lt.jpeg",
  "Manopla de microfibra economica.jpeg",
  "manopla de microfibra laffitte XL.jpeg",
  "Manopla de microfibra laffitte.jpeg",
  "Microfibra media naranja lava autos.jpeg",
  "microfibra vidrios media naranja.jpeg",
  "paño de microfibra full car rojo 60x40cm.jpeg",
  "paño de microfibra laffitte vidrios 30x35cm.jpeg",
  "Paño de microfibra tipo wafle laffitte 40x60 cm.jpeg",
  "Paño lupa walker.jpeg",
  "paño lupa.jpeg",
  "perfume colgante para auto wild wood.jpeg",
  "Pino aromatizante full car.jpeg",
  "Pino walker.jpeg",
  "Renovador de caucho full car x1lt.jpeg",
  "saphirus perfume para auto colgante ambar.jpeg",
  "Saphirus sensaciones.jpeg",
  "Shampoo para hidrolavadora silisur x1lt.jpeg",
  "Shampoo walker x1lt.jpeg",
  "silicona full car emulsión de silicona x1lt (Hidratador de plásticos).jpeg",
  "Silicona para exterior walker x1lt.jpeg",
  "Silicona para interior walker x1lt.jpeg",
  "Walker auto sport aparato.jpeg",
  "Walker auto sport repuesto.jpeg"
)

$cards = New-Object System.Collections.Generic.List[string]
foreach ($f in $files) {
  $name = $f -replace '\.jpeg$', ''
  $src = "productos/Auto/" + ($f -replace ' ', '%20')
  $nameUpper = $name.ToUpper()
  $waText = ($name -replace ' ', '%20')
  $card = '<div class="product-card"><img class="product-card-img" src="' + $src + '" alt="' + $nameUpper + '"><div class="product-card-name">' + $nameUpper + '</div><div class="product-card-price"></div><div class="product-card-actions"><div class="qty-controls"><button class="qty-btn qty-minus" onclick="event.stopPropagation(); updateQty(this, -1)">&#8722;</button><span class="qty-value">1</span><button class="qty-btn qty-plus" onclick="event.stopPropagation(); updateQty(this, 1)">+</button></div><button class="btn-add-cart" onclick="addToCart(this, ''' + $nameUpper + ''')"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="M12 5v14M5 12h14"/></svg> Agregar al carrito</button></div><a href="https://wa.me/5493534012349?text=Hola!%20Consulto%20por%20' + $waText + '" class="product-card-wa" target="_blank" rel="noopener">' + $waSvg + '</a></div>'
  $cards.Add($card)
}

$newLines = [System.Collections.Generic.List[string]]::new()
$inAuto = $false
$inserted = 0

for ($i = 0; $i -lt $lines.Count; $i++) {
  $line = $lines[$i]

  if ($line -match 'id="cat-auto"') {
    $inAuto = $true
  }

  if ($inAuto -and $line.Trim() -eq '<div class="products-grid">') {
    $newLines.Add($line)
    foreach ($c in $cards) {
      $newLines.Add($c)
    }
    $inserted = $cards.Count
    $inAuto = $false
    continue
  }

  $newLines.Add($line)
}

$content = [string]::Join("`n", $newLines)
$content = $content.Replace('<div class="cat-name">Auto</div><div class="cat-count">0 productos</div>', '<div class="cat-name">Auto</div><div class="cat-count">37 productos</div>')

[System.IO.File]::WriteAllText($file, $content)

Write-Host "Inserted $inserted product cards into cat-auto"
