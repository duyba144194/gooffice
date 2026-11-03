Write-Output "=== GoOffice Installation Info ==="
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | ForEach-Object {
    try {
        $p = Get-ItemProperty $_.PSPath
        if ($p.DisplayName -match 'GoOffice') {
            Write-Output "DisplayName: $($p.DisplayName)"
            Write-Output "Version: $($p.DisplayVersion)"
            Write-Output "Location: $($p.InstallLocation)"
            Write-Output "Uninstall: $($p.UninstallString)"
        }
    } catch {}
}

Write-Output ""
Write-Output "=== Search for Vietnamese locale files ==="
$found = Get-ChildItem "C:\Program Files\GoOffice\share" -Recurse -Directory -Filter "vi" -ErrorAction SilentlyContinue
if ($found) {
    foreach ($f in $found) {
        Write-Output "  FOUND: $($f.FullName)"
    }
} else {
    Write-Output "  Vietnamese locale directory NOT found in share/"
}

Write-Output ""
Write-Output "=== Check program/locale ==="
$pl = Get-ChildItem "C:\Program Files\GoOffice\program\locale" -Directory -ErrorAction SilentlyContinue
if ($pl) {
    $pl | Select-Object -ExpandProperty Name | ForEach-Object { Write-Output "  locale/$_" }
} else {
    Write-Output "  program/locale/ directory does not exist"
}

Write-Output ""
Write-Output "=== List all installed GoOffice MSIs ==="
Get-ChildItem "C:\Users\NAM\GoOffice\dist\win-x64\" -Filter "*.msi" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
