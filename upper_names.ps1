$htmlPath = "C:\Users\mili_\Downloads\Nueva carpeta\index.html"
$html = [System.IO.File]::ReadAllText($htmlPath)

function UrlEncode([string]$s) {
  $bytes = [System.Text.Encoding]::UTF8.GetBytes($s)
  $result = ""
  foreach ($b in $bytes) {
    $c = [char]$b
    if (($b -ge 0x41 -and $b -le 0x5A) -or ($b -ge 0x61 -and $b -le 0x7A) -or ($b -ge 0x30 -and $b -le 0x39) -or $c -eq '-' -or $c -eq '_' -or $c -eq '.' -or $c -eq '~') {
      $result += $c
    } else {
      $result += "%{0:X2}" -f $b
    }
  }
  return $result
}

# 1. alt attributes
$html = [regex]::Replace($html, 'alt="([^"]*)"', {
  param($m)
  'alt="' + $m.Groups[1].Value.ToUpperInvariant() + '"'
})

# 2. product-card-name content
$html = [regex]::Replace($html, '<div class="product-card-name">([^<]*)</div>', {
  param($m)
  '<div class="product-card-name">' + $m.Groups[1].Value.ToUpperInvariant() + '</div>'
})

# 3. addToCart name
$html = [regex]::Replace($html, "addToCart\(this, '([^']*)'\)", {
  param($m)
  "addToCart(this, '" + $m.Groups[1].Value.ToUpperInvariant() + "')"
})

# 4. WhatsApp URL text - decode, uppercase product name part, re-encode
$html = [regex]::Replace($html, '(text=Hola!%20Consulto%20por%20)([^"]*)', {
  param($m)
  $prefix = $m.Groups[1].Value
  $encoded = $m.Groups[2].Value
  $decoded = [uri]::UnescapeDataString($encoded)
  $decoded = $decoded.ToUpperInvariant()
  $reEncoded = [uri]::EscapeUriString($decoded)
  $prefix + $reEncoded
})

[System.IO.File]::WriteAllText($htmlPath, $html)
Write-Host "Done - all product names uppercased"
