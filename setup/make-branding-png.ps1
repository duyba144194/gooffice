# Generate GoOffice branding PNGs: intro.png (644x199), intro-highres.png (1288x398), transparent donate placeholders
param([string]$OutDir = "C:\Users\NAM\Desktop\office\branding")
Add-Type -AssemblyName System.Drawing

$W = 1288; $H = 398
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'
$g.TextRenderingHint = 'AntiAliasGridFit'
$g.InterpolationMode = 'HighQualityBicubic'

# background gradient (dark slate)
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, `
    [System.Drawing.Color]::FromArgb(255, 11, 18, 32), `
    [System.Drawing.Color]::FromArgb(255, 30, 43, 69), 90)
$g.FillRectangle($bgBrush, $rect)

# emerald glow behind the mark
$glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$glowPath.AddEllipse(40, 40, 560, 320)
$pthBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
$pthBrush.CenterColor = [System.Drawing.Color]::FromArgb(64, 0, 179, 107)
$pthBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 0, 179, 107))
$g.FillPath($pthBrush, $glowPath)

# rounded-rect helper
function New-RoundRect([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = 2 * $r
    $p.AddArc($x, $y, $d, $d, 180, 90)
    $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $p.CloseFigure()
    return $p
}

# mark: rounded square with emerald gradient
$mx = 110.0; $my = 133.0; $ms = 132.0; $mr = 30.0
$markPath = New-RoundRect $mx $my $ms $ms $mr
$markRect = New-Object System.Drawing.Rectangle($mx, $my, $ms, $ms)
$markBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($markRect, `
    [System.Drawing.Color]::FromArgb(255, 0, 212, 130), `
    [System.Drawing.Color]::FromArgb(255, 0, 158, 96), 45)
$g.FillPath($markBrush, $markPath)

# document lines on the mark
$white92 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 255, 255, 255))
$white75 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(190, 255, 255, 255))
$white58 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(148, 255, 255, 255))
$g.FillRectangle($white92, ($mx + 34), ($my + 38), 64, 9)
$g.FillRectangle($white75, ($mx + 34), ($my + 57), 64, 9)
$g.FillRectangle($white58, ($mx + 34), ($my + 76), 40, 9)
# chevron
$chev = @(
    (New-Object System.Drawing.PointF(($mx + 62), ($my + 66))),
    (New-Object System.Drawing.PointF(($mx + 86), ($my + 82))),
    (New-Object System.Drawing.PointF(($mx + 62), ($my + 98)))
)
$g.FillPolygon($white92, $chev)

# wordmark
$fontW = New-Object System.Drawing.Font('Segoe UI', 84, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$goBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 62, 224, 143))
$offBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 241, 245, 249))
$goSize = $g.MeasureString('Go', $fontW)
$offSize = $g.MeasureString('Office', $fontW)
$tx = 300.0; $ty = 138.0
$g.DrawString('Go', $fontW, $goBrush, $tx, $ty)
$g.DrawString('Office', $fontW, $offBrush, ($tx + $goSize.Width - 6), $ty)

# tagline
$fontT = New-Object System.Drawing.Font('Segoe UI', 30, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$tagBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 148, 163, 184))
$g.DrawString('The open office suite', $fontT, $tagBrush, 302, 252)

# bottom accent line
$accRect = New-Object System.Drawing.Rectangle(0, ($H - 8), $W, 8)
$accBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($accRect, `
    [System.Drawing.Color]::FromArgb(255, 0, 179, 107), `
    [System.Drawing.Color]::FromArgb(160, 0, 179, 107), 0)
$g.FillRectangle($accBrush, $accRect)

$bmp.Save("$OutDir\intro-highres.png", [System.Drawing.Imaging.ImageFormat]::Png)

# downscale to 644x199 for intro.png
$bmp2 = New-Object System.Drawing.Bitmap(644, 199)
$g2 = [System.Drawing.Graphics]::FromImage($bmp2)
$g2.InterpolationMode = 'HighQualityBicubic'
$g2.SmoothingMode = 'AntiAlias'
$g2.DrawImage($bmp, 0, 0, 644, 199)
$bmp2.Save("$OutDir\intro.png", [System.Drawing.Imaging.ImageFormat]::Png)

# transparent placeholders for donate banners
foreach ($n in @('donate1.png', 'donate2.png')) {
    $d = New-Object System.Drawing.Bitmap(2, 2)
    $d.Save("$OutDir\$n", [System.Drawing.Imaging.ImageFormat]::Png)
    $d.Dispose()
}

$g.Dispose(); $g2.Dispose(); $bmp.Dispose(); $bmp2.Dispose()
Write-Output "BRANDING-PNG-DONE"
