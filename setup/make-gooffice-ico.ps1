# Build GoOffice .ico — single 256x256 PNG entry (valid, minimal, modern Windows renders it everywhere)
Add-Type -AssemblyName System.Drawing

$out = 'C:\Users\NAM\GoOffice\setup\gooffice.ico'
$S = 256

function New-RoundRect([float]$x,[float]$y,[float]$w,[float]$h,[float]$r) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = 2*$r
    $p.AddArc($x,$y,$d,$d,180,90); $p.AddArc($x+$w-$d,$y,$d,$d,270,90)
    $p.AddArc($x+$w-$d,$y+$h-$d,$d,$d,0,90); $p.AddArc($x,$y+$h-$d,$d,$d,90,90)
    $p.CloseFigure(); return $p
}

$bmp = New-Object System.Drawing.Bitmap($S,$S)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode='AntiAlias'
$g.Clear([System.Drawing.Color]::Transparent)
$pad = 16; $size = $S-32; $r = 56
$rect = New-Object System.Drawing.Rectangle($pad,$pad,$size,$size)
$gp = New-RoundRect $pad $pad $size $size $r
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect,
    [System.Drawing.Color]::FromArgb(255,0,212,130),
    [System.Drawing.Color]::FromArgb(255,0,140,84), 45)
$g.FillPath($brush,$gp)
$g.FillRectangle([System.Drawing.Brushes]::White, 58, 74, 140, 14)
$g.FillRectangle([System.Drawing.Brushes]::White, 58, 104, 140, 14)
$g.FillRectangle([System.Drawing.Brushes]::White, 58, 134, 88, 14)
$g.Dispose()

$pngMs = New-Object System.IO.MemoryStream
$bmp.Save($pngMs, [System.Drawing.Imaging.ImageFormat]::Png)
$png = $pngMs.ToArray()
$bmp.Dispose()

$ms = New-Object System.IO.MemoryStream
$bw = New-Object System.IO.BinaryWriter($ms)
$bw.Write([UInt16]0); $bw.Write([UInt16]1); $bw.Write([UInt16]1)   # ICONDIR: 1 image
$bw.Write([byte]0); $bw.Write([byte]0)                             # 256x256 (0 = 256)
$bw.Write([byte]0); $bw.Write([byte]0)
$bw.Write([UInt16]1); $bw.Write([UInt16]32)
$bw.Write([UInt32]$png.Length); $bw.Write([UInt32]22)              # data offset = 6+16
$bw.Write($png)
$bw.Flush()
[System.IO.File]::WriteAllBytes($out, $ms.ToArray())
$bw.Dispose(); $ms.Dispose(); $pngMs.Dispose()
Write-Output ("ICO2-WRITTEN " + (Get-Item $out).Length)
