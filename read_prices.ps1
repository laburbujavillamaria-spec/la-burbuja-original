$word = New-Object -ComObject Word.Application
$word.Visible = $false
$docPath = "C:\Users\mili_\Downloads\Nueva carpeta\productos\Productos CON PRECIOS.docx"
$doc = $word.Documents.Open($docPath)
$text = $doc.Content.Text
$doc.Close()
$word.Quit()
Write-Host $text
