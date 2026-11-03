# Generate GoOffice app-mark assets at all required sizes:
#  - Linux hicolor PNGs + scalable SVG
#  - macOS main.iconset PNGs (iconutil on CI assembles main.icns)
Add-Type -AssemblyName System.Drawing
$cr = 13

function New-RoundRect([float]$x,[float]$y,[float]$w,[float]$h,[float]$r) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = 2*$r
    $p.AddArc($x,$y,$d,$d,180,90); $p.AddArc($x+$w-$d,$y,$d,$d,270,90)
    $p.AddArc($x+$w-$d,$y+$h-$d,$d,$d,0,90); $p.AddArc($x,$y+$h-$d,$d,$d,90,90)
    $p.CloseFigure(); return $p
}

function Render([int]$S) {
    $bmp = New-Object System.Drawing.Bitmap($S,$S)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode='AntiAlias'; $g.InterpolationMode='HighQualityBicubic'
    $g.Clear([System.Drawing.Color]::Transparent)
    $pad = [Math]::Max(1,[Math]::Round($S*0.055)); $size = $S - 2*$pad
    $r = [Math]::Round($S*0.21)
    $rect = New-Object System.Drawing.Rectangle($pad,$pad,$size,$size)
    $gp = New-RoundRect $pad $pad $size $size $r
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect,
        [System.Drawing.Color]::FromArgb(255,0,212,130),
        [System.Drawing.Color]::FromArgb(255,0,140,84), 45)
    $g.FillPath($brush,$gp)
    $lw = [Math]::Max(1,[Math]::Round($S*0.055))
    $x0 = [Math]::Round($S*0.235)
    $g.FillRectangle([System.Drawing.Brushes]::White, $x0, ($S*0.31), ($S*0.53), $lw)
    $g.FillRectangle([System.Drawing.Brushes]::White, $x0, ($S*0.31+$lw*1.7), ($S*0.53), $lw)
    $g.FillRectangle([System.Drawing.Brushes]::White, $x0, ($S*0.31+$lw*3.4), ($S*0.33), $lw)
    $g.Dispose(); return $bmp
}

# Linux hicolor sizes
$hicol = 'C:\Users\NAM\GoOffice\src\core\sysui\desktop\icons\hicolor'
foreach ($s in @(16,24,32,48,64,128,256)) {
    $img = Render $s
    $dir = "$hicol\${s}x$s\apps"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $img.Save("$dir\startcenter.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $img.Dispose()
    Write-Output "linux ${s}x$s"
}
# scalable SVG (vector mark)
$svg = @'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 256">
  <defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#00d482"/><stop offset="1" stop-color="#008c54"/>
  </linearGradient></defs>
  <rect x="14" y="14" width="228" height="228" rx="54" fill="url(#g)"/>
  <rect x="60" y="79" width="136" height="14" rx="7" fill="#ffffff"/>
  <rect x="60" y="112" width="136" height="14" rx="7" fill="#ffffff"/>
  <rect x="60" y="145" width="85" height="14" rx="7" fill="#ffffff"/>
</svg>
'@
[System.IO.File]::WriteAllText("$hicol\scalable\apps\startcenter.svg", $svg)
Write-Output "linux scalable svg"

# macOS main.iconset sizes
$mac = 'C:\Users\NAM\GoOffice\src\core\sysui\desktop\icons\macos\app-launcher\main.iconset'
foreach ($pair in @(@('16x16',16),@('16x16@2x',32),@('32x32',32),@('32x32@2x',64),
                    @('128x128',128),@('128x128@2x',256),@('256x256',256),
                    @('256x256@2x',512),@('512x512',512),@('512x512@2x',1024))) {
    $name = $pair[0]; $s = $pair[1]
    $img = Render $s
    $img.Save("$mac\icon_$name.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $img.Dispose()
    Write-Output "macos icon_$name.png"
}
Write-Output ASSETS-DONE
