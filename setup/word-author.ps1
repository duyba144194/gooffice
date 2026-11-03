# Author hard-case documents using real MS Word/Excel COM (v2 - clean strings)
$ErrorActionPreference = 'Continue'
Add-Type -AssemblyName System.Drawing

$png = 'C:\Users\NAM\GoOffice\qa\assets\mark.png'
New-Item -ItemType Directory -Force -Path (Split-Path $png) | Out-Null
$b = New-Object System.Drawing.Bitmap(120,120)
$g = [System.Drawing.Graphics]::FromImage($b)
$g.Clear([System.Drawing.Color]::Transparent)
$br = New-Object System.Drawing.Drawing2D.LinearGradientBrush((New-Object System.Drawing.Rectangle(0,0,120,120)), [System.Drawing.Color]::FromArgb(255,0,212,130), [System.Drawing.Color]::FromArgb(255,0,140,84), 45)
$g.FillRectangle($br, 4, 4, 112, 112)
$g.FillRectangle([System.Drawing.Brushes]::White, 28, 40, 64, 8)
$g.FillRectangle([System.Drawing.Brushes]::White, 28, 56, 64, 8)
$g.Dispose()
$b.Save($png, [System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()

$cr = [string][char]13 + [string][char]10
$word = New-Object -ComObject Word.Application
$word.Visible = $false; $word.DisplayAlerts = 0
try {
    $doc = $word.Documents.Add()
    $sel = $word.Selection
    $sel.Style = $doc.Styles.Item('Heading 1')
    $sel.TypeText('Kiem thu hinh noi + chu thich - GoOffice QA - Đà Nẵng ệ ơ ư ạ ế')
    $sel.TypeParagraph()
    $sel.Style = $doc.Styles.Item('Normal')
    $sel.TypeText('Đoạn này neo hình nổi bên phải: Đà Nẵng, Hà Nội — ệ ơ ư ạ ế.')
    $sel.TypeParagraph()
    $shape = $doc.Shapes.AddPicture($png, $false, $true, $sel.Range)
    $shape.WrapFormat.Type = 0
    $shape.Width = 96; $shape.Height = 96
    $sel.TypeText('Văn bản cuộn quanh hình nổi (wrap square).')
    $rng = $doc.Paragraphs.Item(3).Range
    $null = $doc.Comments.Add($rng, 'Chú thích QA: kiểm tra roundtrip — ệ ơ ư ạ')
    $sel.EndKey(6) | Out-Null
    $sel.TypeParagraph()
    $sel.InsertBreak(7)
    $sel.TypeText('Trang 2 sau ngắt trang rõ ràng — Ệ Ơ Ư Ạ Ế.')
    $doc.SaveAs2('C:\Users\NAM\GoOffice\qa\docs\test-word-hard.docx', 16)
    $doc.Close($false)
    Write-Output 'WORD-HARD-OK'

    $doc2 = $word.Documents.Add()
    $doc2.Content.Text = 'Tai lieu co macro VBA that.'
    $vbaCode = 'Sub AutoOpen()' + $cr + '  ThisDocument.Content.Text = ThisDocument.Content.Text + "[VBA ran]"' + $cr + 'End Sub'
    try {
        $vb = $doc2.VBProject
        $mod = $vb.VBComponents.Add(1)
        $mod.CodeModule.AddFromString($vbaCode)
        $doc2.SaveAs2('C:\Users\NAM\GoOffice\qa\docs\test-vba.docm', 13)
        Write-Output 'VBA-DOCM-OK'
    } catch {
        Write-Output ('VBA-ACCESS-BLOCKED: ' + $_.Exception.Message)
        $doc2.SaveAs2('C:\Users\NAM\GoOffice\qa\docs\test-vba.docm', 13)
        Write-Output 'DOCM-SAVED-WITHOUT-MACRO'
    }
    $doc2.Close($false)
} finally {
    $word.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
}

if (Test-Path 'C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE') {
    $xl = New-Object -ComObject Excel.Application
    $xl.Visible = $false; $xl.DisplayAlerts = $false
    try {
        $wb = $xl.Workbooks.Add()
        $ws = $wb.Worksheets.Item(1)
        $ws.Cells.Item(1,1) = 'Họ tên'
        $ws.Cells.Item(1,2) = 'Điểm'
        $ws.Cells.Item(2,1) = 'Nguyễn Văn Ắt'
        $ws.Cells.Item(2,2) = 9.5
        $xlCode = 'Private Sub Workbook_Open()' + $cr + '  Sheet1.Range("D1").Value = "[VBA ran]"' + $cr + 'End Sub'
        try {
            $vb2 = $wb.VBProject
            $mod2 = $vb2.VBComponents.Add(1)
            $mod2.CodeModule.AddFromString($xlCode)
        } catch {
            Write-Output ('XL-VBA-ACCESS-BLOCKED: ' + $_.Exception.Message)
        }
        $null = $wb.SaveAs('C:\Users\NAM\GoOffice\qa\docs\test-vba.xlsm', 52)
        $wb.Close($false)
        Write-Output 'VBA-XLSM-OK'
    } finally {
        $xl.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null
    }
} else {
    Write-Output 'EXCEL-NOT-FOUND'
}
Write-Output 'AUTHOR-DONE'
