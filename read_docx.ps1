Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
$zip = [System.IO.Compression.ZipFile]::OpenRead('C:\Users\mili_\Downloads\Nueva carpeta\productos\Productos CON PRECIOS.docx')
$entry = $zip.GetEntry('word/document.xml')
$stream = $entry.Open()
$reader = New-Object System.IO.StreamReader($stream)
$xml = $reader.ReadToEnd()
$reader.Close()
$stream.Close()
$zip.Dispose()

# Extract text from XML by stripping tags
$text = $xml -replace '<[^>]+>', ' '
$text = $text -replace '\s+', ' '
$text = $text.Trim()
Write-Host $text
