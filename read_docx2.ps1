$src = "C:\Users\mili_\Downloads\Nueva carpeta\productos\Productos CON PRECIOS.docx"
$dst = "C:\Users\mili_\Downloads\Nueva carpeta\temp_prices.docx"
Copy-Item -LiteralPath $src -Destination $dst -Force

Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
$zip = [System.IO.Compression.ZipFile]::OpenRead($dst)
$entry = $zip.GetEntry('word/document.xml')
$stream = $entry.Open()
$reader = New-Object System.IO.StreamReader($stream)
$xml = $reader.ReadToEnd()
$reader.Close()
$stream.Close()
$zip.Dispose()

$text = $xml -replace '<[^>]+>', ' '
$text = $text -replace '\s+', ' '
$text = $text.Trim()
Write-Host $text
