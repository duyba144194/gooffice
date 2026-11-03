$share = "C:\Program Files\GoOffice\share"
$dirs = Get-ChildItem "$share" -Recurse -Directory -Filter "vi" -ErrorAction SilentlyContinue
if ($dirs) {
    foreach ($d in $dirs) {
        Write-Output "DIR: $($d.FullName)"
        Get-ChildItem $d.FullName -File | Select-Object -First 5 | ForEach-Object {
            Write-Output "  - $($_.Name)"
        }
    }
} else {
    Write-Output 'No vi directories found in share/'
}

Write-Output ''
Write-Output '=== Check program directory for locale ==='
$program = "C:\Program Files\GoOffice\program"
Get-ChildItem $program -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name

Write-Output ''
Write-Output '=== Check all .pak files ==='
$paks = Get-ChildItem "$program\*.pak" -ErrorAction SilentlyContinue
if ($paks) {
    $paks | ForEach-Object { Write-Output "  $($_.Name)" }
} else {
    Write-Output '  No .pak files'
}

Write-Output ''
Write-Output '=== Check program/locale (if exists) ==='
$pl = "$program\locale"
if (Test-Path $pl) {
    Get-ChildItem $pl -Directory | Select-Object -ExpandProperty Name
} else {
    Write-Output '  locale/ does NOT exist'
}

Write-Output ''
Write-Output '=== Check registry Locale/Language settings ==='
$regPath = "HKCU:\Software\GoOffice\1.0\Common"
if (Test-Path $regPath) {
    Get-ItemProperty $regPath | Format-List
} else {
    Write-Output '  Registry path does not exist'
}

Write-Output ''
Write-Output '=== Check user profile ==='
$up = "$env:USERPROFILE\AppData\Roaming\GoOffice\4"
if (Test-Path $up) {
    Write-Output "Profile exists at: $up"
    Get-ChildItem "$up\user" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "  $($_.Name)" }
    # Check for registryback
    if (Test-Path "$up\registryback") {
        Write-Output "  registryback exists"
        Get-ChildItem "$up\registryback" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output "    $($_.Name)" }
    }
} else {
    Write-Output "Profile does NOT exist at: $up"
}
