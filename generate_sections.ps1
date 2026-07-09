$outputFile = "C:\Users\mili_\Downloads\Nueva carpeta\generated_sections.txt"
$productosDir = "C:\Users\mili_\Downloads\Nueva carpeta\productos"
$script:waNum = "5493534012349"

# Helper to find a subfolder by prefix (handles encoding issues)
function Get-FolderByPrefix($prefix) {
    return (Get-ChildItem -LiteralPath $productosDir | Where-Object { $_.PSIsContainer -and $_.Name -like "$prefix*" }).FullName
}

# URL-encode a string preserving safe path chars
function Get-UrlEncoded($text) {
    $result = ''
    foreach ($ch in $text.ToCharArray()) {
        $c = [string]$ch
        if ($c -match '^[a-zA-Z0-9\-._~/$]$') {
            $result += $c
        } elseif ($c -eq ' ') {
            $result += '%20'
        } else {
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($c)
            foreach ($b in $bytes) { $result += '%{0:X2}' -f $b }
        }
    }
    return $result
}

# Get subfolder name (relative path from productos dir) by prefix
function Get-SubfolderName($prefix) {
    return (Get-ChildItem -LiteralPath $productosDir | Where-Object { $_.PSIsContainer -and $_.Name -like "$prefix*" }).Name
}

# Product card with image
function New-ImgCard($file, $subfolder) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($file)
    $relPath = "productos/$subfolder/$file"
    $urlPath = Get-UrlEncoded $relPath
    $encName = Get-UrlEncoded $name
    return "<div class=""product-card""><img class=""product-card-img"" src=""$urlPath"" alt=""$name""><div class=""product-card-name"">$name</div><div class=""product-card-actions""><div class=""qty-controls""><button class=""qty-btn qty-minus"" onclick=""event.stopPropagation(); updateQty(this, -1)"">−</button><span class=""qty-value"">1</span><button class=""qty-btn qty-plus"" onclick=""event.stopPropagation(); updateQty(this, 1)"">+</button></div><button class=""btn-add-cart"" onclick=""addToCart(this, '$name')""><svg width=""13"" height=""13"" viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" stroke-width=""3""><path d=""M12 5v14M5 12h14""/></svg> Agregar al carrito</button></div><a href=""https://wa.me/$($script:waNum)?text=Hola!%20Consulto%20por%20$encName"" class=""product-card-wa"" target=""_blank"" rel=""noopener""><svg width=""9"" height=""9"" viewBox=""0 0 24 24"" fill=""currentColor""><path d=""M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z""/></svg> Consultar</a></div>"
}

# Basic product card (no image)
function New-BasicCard($name, $tag) {
    $encName = Get-UrlEncoded $name
    return "<div class=""product-card""><div class=""product-card-name"">$name</div><span class=""product-card-tag"">$tag</span><div class=""product-card-actions""><div class=""qty-controls""><button class=""qty-btn qty-minus"" onclick=""event.stopPropagation(); updateQty(this, -1)"">−</button><span class=""qty-value"">1</span><button class=""qty-btn qty-plus"" onclick=""event.stopPropagation(); updateQty(this, 1)"">+</button></div><button class=""btn-add-cart"" onclick=""addToCart(this, '$name')""><svg width=""13"" height=""13"" viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" stroke-width=""3""><path d=""M12 5v14M5 12h14""/></svg> Agregar al carrito</button></div><a href=""https://wa.me/$($script:waNum)?text=Hola!%20Consulto%20por%20$encName"" class=""product-card-wa"" target=""_blank"" rel=""noopener""><svg width=""9"" height=""9"" viewBox=""0 0 24 24"" fill=""currentColor""><path d=""M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z""/></svg> Consultar</a></div>"
}

# Category header template
function New-CatHeader($id, $icon, $title, $desc, $encText) {
    return @" 
    <div class="product-category" id="$id">
      <div class="category-header">
        <span class="category-icon">$icon</span>
        <div>
          <h2 class="category-title">$title</h2>
          <p class="category-desc">$desc</p>
        </div>
        <a href="https://wa.me/$($script:waNum)?text=Hola!%20Quiero%20consultar%20sobre%20$encText." class="category-wa-btn" target="_blank" rel="noopener">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.82 11.82 0 00-3.48-8.413z"/></svg>
          Consultar
        </a>
      </div>
"@
}

$sb = New-Object System.Text.StringBuilder

# ============================================================
# 1. CAT-ESPONJAS (New - full section with images)
# ============================================================
$folder = Get-FolderByPrefix "Esponjas"
$subName = Get-SubfolderName "Esponjas"
[void]$sb.AppendLine("<!-- ===== ESPONJAS Y ABRASIVOS (generated) ===== -->")
[void]$sb.Append((New-CatHeader -id "cat-esponjas" -icon "https://api.iconify.design/fluent-emoji-high-contrast/sponge.svg" -title "Esponjas y abrasivos" -desc "Esponjas, fibras y limpiadores abrasivos" -encText "Esponjas%20y%20abrasivos"))
Get-ChildItem -LiteralPath $folder | Where-Object { -not $_.PSIsContainer } | ForEach-Object {
    $fname = $_.Name
    if ($fname -notlike "WhatsApp*" -and $fname -notlike "IMG-20*") {
        [void]$sb.AppendLine("        " + (New-ImgCard -file $fname -subfolder $subName))
    }
}
[void]$sb.AppendLine("      </div>
    </div>")

# ============================================================
# 2. CAT-ESCOBILLONES (Products to add - from Cepillos de baño)
# ============================================================
$folder = Get-FolderByPrefix "Cepillos"
$subName = Get-SubfolderName "Cepillos"
[void]$sb.AppendLine("")
[void]$sb.AppendLine("<!-- ===== ESCOBILLONES - Cards to add from Cepillos de baño, Sopapas (generated) ===== -->")
Get-ChildItem -LiteralPath $folder | Where-Object { -not $_.PSIsContainer } | ForEach-Object {
    $fname = $_.Name
    if ($fname -notlike "WhatsApp*" -and $fname -notlike "IMG-20*") {
        [void]$sb.AppendLine((New-ImgCard -file $fname -subfolder $subName))
    }
}

# ============================================================
# 3. CAT-PALAS (Products to add - from Palas de residuos, Secadores de piso, limpia vidrios)
# ============================================================
[void]$sb.AppendLine("")
[void]$sb.AppendLine("<!-- ===== PALAS Y SECADORES - Cards to add (generated) ===== -->")

# Palas de residuos
$folder = Get-FolderByPrefix "Palas"
$subName = Get-SubfolderName "Palas"
Get-ChildItem -LiteralPath $folder | Where-Object { -not $_.PSIsContainer } | ForEach-Object {
    $fname = $_.Name
    if ($fname -notlike "WhatsApp*" -and $fname -notlike "IMG-20*") {
        [void]$sb.AppendLine((New-ImgCard -file $fname -subfolder $subName))
    }
}

# Secadores de piso
$folder = Get-FolderByPrefix "Secadores"
$subName = Get-SubfolderName "Secadores"
Get-ChildItem -LiteralPath $folder | Where-Object { -not $_.PSIsContainer } | ForEach-Object {
    $fname = $_.Name
    if ($fname -notlike "WhatsApp*" -and $fname -notlike "IMG-20*") {
        [void]$sb.AppendLine((New-ImgCard -file $fname -subfolder $subName))
    }
}

# limpia vidrios
$folder = Get-FolderByPrefix "limpia"
$subName = Get-SubfolderName "limpia"
Get-ChildItem -LiteralPath $folder | Where-Object { -not $_.PSIsContainer } | ForEach-Object {
    $fname = $_.Name
    if ($fname -notlike "WhatsApp*" -and $fname -notlike "IMG-20*") {
        [void]$sb.AppendLine((New-ImgCard -file $fname -subfolder $subName))
    }
}

# ============================================================
# 4. CAT-TACHOS (New - basic cards, no images)
# ============================================================
$tachos = @(
    "Tacho 10 L tapa vaivén",
    "Tacho 20 L pedal",
    "Tacho 30 L rectangular",
    "Tacho baño 5 L",
    "Balde plástico 10 L",
    "Balde con escurridor",
    "Balde profesional 15 L",
    "Tacho cocina inox 10 L",
    "Tacho oficina pequeño",
    "Balde apilable 12 L",
    "Tacho 50 L tapa",
    "Contenedor clasificación"
)
[void]$sb.AppendLine("")
[void]$sb.AppendLine("<!-- ===== TACHOS Y BALDES (generated) ===== -->")
[void]$sb.Append((New-CatHeader -id "cat-tachos" -icon "https://cdn.jsdelivr.net/gh/Templarian/MaterialDesign@master/svg/trash-can.svg" -title "Tachos y baldes" -desc "Tachos de basura, baldes y accesorios" -encText "Tachos%20y%20baldes"))
foreach ($p in $tachos) {
    [void]$sb.AppendLine("        " + (New-BasicCard -name $p -tag "Contenedor"))
}
[void]$sb.AppendLine("      </div>
    </div>")

# ============================================================
# 5. CAT-MICROFIBRA (New - basic cards, no images)
# ============================================================
$microfibra = @(
    "Paño microfibra colores",
    "Paño microfibra blanco",
    "Paño microfibra amarillo",
    "Paño microfibra azul",
    "Paño microfibra rojo",
    "Paño microfibra verde",
    "Paño microfibra gris",
    "Paño microfibra naranja",
    "Paño microfibra negro",
    "Paño microfibra violeta",
    "Paño microfibra celeste",
    "Paño microfibra rosa",
    "Paño microfibra beige",
    "Paño microfibra mostaza",
    "Paño microfibra lila",
    "Paño microfibra marrón",
    "Paño microfibra bordo",
    "Paño microfibra salmón",
    "Paño microfibra turquesa",
    "Paño limpieza pesada",
    "Paño para vidrios",
    "Paño multiuso",
    "Paño absorbente",
    "Paño suede",
    "Paño gamuza sintética",
    "Paño microfibra x10",
    "Paño microfibra x25",
    "Paño microfibra x50",
    "Paño microfibra x100",
    "Paño microfibra x200"
)
[void]$sb.AppendLine("")
[void]$sb.AppendLine("<!-- ===== MICROFIBRA (generated) ===== -->")
[void]$sb.Append((New-CatHeader -id "cat-microfibra" -icon "https://cdn.jsdelivr.net/gh/Templarian/MaterialDesign@master/svg/microfibre.svg" -title "Microfibra" -desc "Paños de microfibra y limpieza" -encText "Microfibra"))
foreach ($p in $microfibra) {
    [void]$sb.AppendLine("        " + (New-BasicCard -name $p -tag "Microfibra"))
}
[void]$sb.AppendLine("      </div>
    </div>")

# ============================================================
# 6. CAT-AROMATIZANTES (New - basic cards, no images)
# ============================================================
$aromas = @(
    "Vela aromática soja",
    "Difusor bamboo 200ml",
    "Difusor caña 250ml",
    "Difusor mimbre 150ml",
    "Tableta cera caliente",
    "Aromatizante textil",
    "Repuesto vela soja",
    "Set vela + difusor",
    "Vela cítrica",
    "Vela lavanda"
)
[void]$sb.AppendLine("")
[void]$sb.AppendLine("<!-- ===== AROMATIZANTES (generated) ===== -->")
[void]$sb.Append((New-CatHeader -id "cat-aromatizantes" -icon "https://api.iconify.design/cbi/essential-oil-diffuser-alt.svg" -title "Aromatizantes" -desc "Velas, difusores y ambientadores" -encText "Aromatizantes"))
foreach ($p in $aromas) {
    [void]$sb.AppendLine("        " + (New-BasicCard -name $p -tag "Aroma"))
}
[void]$sb.AppendLine("      </div>
    </div>")

# Write output
[System.IO.File]::WriteAllText($outputFile, $sb.ToString(), [System.Text.Encoding]::UTF8)

Write-Host "Done! Generated sections saved to $outputFile"
Write-Host "Total size: $($sb.Length) characters"
