# Convert test docx to PDF via Microsoft Word COM (for render comparison)
$ErrorActionPreference = 'Stop'
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
try {
    $doc = $word.Documents.Open('C:\Users\NAM\GoOffice\qa\docs\test-hard.docx', $false, $true)  # ReadOnly
    $doc.SaveAs2('C:\Users\NAM\GoOffice\qa\roundtrip\word-reference.pdf', 17)  # wdFormatPDF
    $doc.Close($false)
    Write-Output 'WORD-PDF-OK'
} finally {
    $word.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
}
