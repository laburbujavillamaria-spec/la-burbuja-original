$html = Get-Content "C:\Users\mili_\Downloads\Nueva carpeta\index.html" -Raw -Encoding UTF8
$siteUrl = "https://laburbujavm.vercel.app"
$outDir = "C:\Users\mili_\Downloads\Nueva carpeta\p"

# Remove old files first
Get-ChildItem "$outDir\*.html" -ErrorAction SilentlyContinue | Remove-Item

$cardPattern = [regex]'(?s)<div class="product-card">.*?<img class="product-card-img"[^>]*src="([^"]*)"[^>]*alt="([^"]*)".*?<div class="product-card-name">([^<]+)</div>'
$catIdPattern = [regex]'(?s)<div class="product-category" id="(cat-[^"]+)">(.*?)(?=<div class="product-category"|</main>)'
$catMatches = $catIdPattern.Matches($html)

$count = 0
foreach ($cm in $catMatches) {
    $catId = $cm.Groups[1].Value
    $catContent = $cm.Groups[2].Value
    $innerCards = $cardPattern.Matches($catContent)
    
    foreach ($m in $innerCards) {
        $imgSrc = $m.Groups[1].Value
        $name = $m.Groups[3].Value.Trim()
        
        # Extract first price
        $priceMatch = [regex]::Match($catContent.Substring([Math]::Max(0, $m.Index), [Math]::Min(800, $catContent.Length - [Math]::Max(0, $m.Index))), '(?:<div class="product-card-price">|<span class="unit-price">)([^<]+)<')
        $price = if ($priceMatch.Success) { $priceMatch.Groups[1].Value.Trim() } else { "" }
        
        # Create slug
        $slug = $name.ToLower() -replace '[^a-z0-9]+', '-' -replace '^-|-$', ''
        if ([string]::IsNullOrEmpty($slug)) { $slug = "producto-$count" }
        
        # Build absolute image URL - don't double encode
        if ($imgSrc -match '^https?://') {
            $absImg = $imgSrc
        } elseif ($imgSrc -match '^/') {
            $absImg = "$siteUrl$imgSrc"
        } else {
            $absImg = "$siteUrl/$imgSrc"
        }
        
        # Decode then re-encode properly for og:image
        $absImgForOg = $absImg -replace '%25', '%'
        
        $pageTitle = "$name - La Burbuja"
        $escapedTitle = $pageTitle -replace '"', '&quot;'
        $escapedName = $name -replace '"', '&quot;' -replace '&', '&amp;'
        $escapedDesc = if ($price) { "Precio: $price - Encontra este y muchos mas productos de limpieza en La Burbuja." } else { "Encontra este y muchos mas productos de limpieza en La Burbuja." }
        $escapedDesc = $escapedDesc -replace '"', '&quot;'
        $pageUrl = "$siteUrl/p/$slug.html"
        $catUrl = "$siteUrl/#$catId"
        $productUrl = "$siteUrl/#p-$slug"
        
        $sb = New-Object System.Text.StringBuilder
        [void]$sb.AppendLine('<!DOCTYPE html>')
        [void]$sb.AppendLine('<html lang="es">')
        [void]$sb.AppendLine('<head>')
        [void]$sb.AppendLine('<meta charset="UTF-8">')
        [void]$sb.AppendLine("<title>$escapedTitle</title>")
        [void]$sb.AppendLine('<meta property="og:type" content="product">')
        [void]$sb.AppendLine("<meta property=`"og:title`" content=`"$escapedTitle`">")
        [void]$sb.AppendLine("<meta property=`"og:description`" content=`"$escapedDesc`">")
        [void]$sb.AppendLine("<meta property=`"og:image`" content=`"$absImgForOg`">")
        [void]$sb.AppendLine("<meta property=`"og:url`" content=`"$pageUrl`">")
        [void]$sb.AppendLine('<meta property="og:site_name" content="La Burbuja Articulos de Limpieza">')
        [void]$sb.AppendLine('<meta name="twitter:card" content="summary_large_image">')
        [void]$sb.AppendLine("<meta name=`"twitter:title`" content=`"$escapedTitle`">")
        [void]$sb.AppendLine("<meta name=`"twitter:description`" content=`"$escapedDesc`">")
        [void]$sb.AppendLine("<meta name=`"twitter:image`" content=`"$absImgForOg`">")
        [void]$sb.AppendLine("<meta http-equiv=`"refresh`" content=`"0;url=$productUrl`">")
        [void]$sb.AppendLine("<link rel=`"canonical`" href=`"$productUrl`">")
        [void]$sb.AppendLine('<style>body{font-family:sans-serif;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;background:#f0f8ff;color:#1A3A6B;text-align:center}a{color:#4DC8D8}img{max-width:200px;border-radius:12px;margin-bottom:16px;box-shadow:0 4px 16px rgba(0,0,0,.15)}</style>')
        [void]$sb.AppendLine('</head>')
        [void]$sb.AppendLine('<body>')
        [void]$sb.AppendLine('<div>')
        [void]$sb.AppendLine("<img src=`"$absImgForOg`" alt=`"$escapedName`">")
        [void]$sb.AppendLine("<h2>$escapedName</h2>")
        if ($price) { [void]$sb.AppendLine("<p><strong>$price</strong></p>") }
        [void]$sb.AppendLine("<p>Redirigiendo a <a href=`"$productUrl`">La Burbuja</a>...</p>")
        [void]$sb.AppendLine('</div>')
        [void]$sb.AppendLine('</body>')
        [void]$sb.AppendLine('</html>')
        
        $sb.ToString() | Out-File -FilePath "$outDir\$slug.html" -Encoding UTF8 -NoNewline
        $count++
    }
}

Write-Host "Generados $count archivos HTML"
