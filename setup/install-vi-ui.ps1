# Copy Vietnamese .mo files into installed GoOffice + set ooLocale=vi in user profile
# Run elevated (admin)

$ErrorActionPreference = 'Stop'
Write-Output "=== 1. Copy Vietnamese .mo files ==="
$src = "C:\Users\NAM\GoOffice\build-linux-x64\instdir\program\resource\vi\LC_MESSAGES"
$dst = "C:\Program Files\GoOffice\program\resource\vi\LC_MESSAGES"
if (-not (Test-Path $dst)) {
    New-Item -ItemType Directory -Path $dst -Force | Out-Null
    Write-Output "Created: $dst"
}
Copy-Item "$src\*.mo" $dst -Force
$count = (Get-ChildItem $dst -Filter '*.mo').Count
Write-Output "Copied $count .mo files to $dst"

Write-Output ""
Write-Output "=== 2. Set ooLocale=vi in GoOffice user profile ==="
# Kill running GoOffice first
Get-Process -Name "soffice*" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Output "Stopping GoOffice process..."
    Stop-Process -Name "soffice*" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

$xcu = "$env:APPDATA\GoOffice\4\user\registrymodifications.xcu"
if (Test-Path $xcu) {
    $content = Get-Content $xcu -Raw -Encoding UTF8
    $item = '<item oor:path="/org.openoffice.Setup/L10N"><prop oor:name="ooLocale" oor:op="fuse"><value>vi</value></prop></item>'
    $item2 = '<item oor:path="/org.openoffice.Setup/L10N"><prop oor:name="ooSetupSystemLocale" oor:op="fuse"><value>vi-VN</value></prop></item>'
    if ($content -notmatch 'ooLocale') {
        # Insert before closing tag
        $content = $content -replace '</oor:items>', "  $item`r`n  $item2`r`n</oor:items>"
        [System.IO.File]::WriteAllText($xcu, $content, [System.Text.Encoding]::UTF8)
        Write-Output "Added ooLocale=vi + ooSetupSystemLocale=vi-VN to profile"
    } elseif ($content -match '<value>vi</value>') {
        Write-Output "ooLocale=vi already set"
    } else {
        Write-Output "ooLocale exists but not vi - replacing"
        $content = $content -replace '<item oor:path="/org.openoffice.Setup/L10N"><prop oor:name="ooLocale"[^>]*>.*?</item>', $item
        [System.IO.File]::WriteAllText($xcu, $content, [System.Text.Encoding]::UTF8)
    }
} else {
    Write-Output "Profile xcu not found at: $xcu"
    Write-Output "Profile will be created on first run with defaults - will set share-level default instead"
}

Write-Output ""
Write-Output "=== DONE ==="
Write-Output "Open GoOffice now - UI should be in Vietnamese"
