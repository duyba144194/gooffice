Write-Output "=== Check Locale Directory ==="
$viPath = "C:\Program Files\GoOffice\share\locale\vi"
if (Test-Path $viPath) {
    $files = Get-ChildItem $viPath -Recurse -Directory -ErrorAction SilentlyContinue
    Write-Output "locale/vi found at: $viPath"
    Write-Output "Subdirectories: $($files.Count)"
    foreach ($f in $files | Select-Object -First 10) {
        Write-Output "  - $($f.Name)"
    }
} else {
    Write-Output "locale/vi NOT found at: $viPath"
}

Write-Output ""
Write-Output "=== Check GoOffice Installation Type ==="
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GoOffice" 2>$null | Select-String -Pattern "DisplayVersion\|DisplayLanguage\|InstallLocation"

Write-Output ""
Write-Output "=== Check User Profile Settings ==="
$up = "$env:USERPROFILE\AppData\Roaming\GoOffice\4\user"
if (Test-Path $up) {
    Write-Output "GoOffice profile exists at: $up"
    Get-ChildItem $up -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
} else {
    Write-Output "GoOffice profile does NOT exist at: $up"
    Write-Output "Trying LibreOffice profile..."
    $libreUp = "$env:USERPROFILE\AppData\Roaming\LibreOffice\4\user"
    if (Test-Path $libreUp) {
        Write-Output "LibreOffice profile exists at: $libreUp"
        Get-ChildItem $libreUp -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
    } else {
        Write-Output "No LibreOffice profile either"
    }
}

Write-Output ""
Write-Output "=== Check for langpack installation ==="
$langpack = Get-ChildItem "C:\Program Files\GoOffice\program\langpacks" -Directory -ErrorAction SilentlyContinue
if ($langpack) {
    Write-Output "Found langpack directory: $($langpack.Name)"
} else {
    Write-Output "No langpack directory found (GoOffice doesn't use separate langpack folder)"
}

Write-Output ""
Write-Output "=== Check GoOffice installed programs (Uninstall Registry) ==="
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" 2>$null | Where-Object { $_ -match "GoOffice|libreoffice" } | ForEach-Object { "  Found: $_" }
