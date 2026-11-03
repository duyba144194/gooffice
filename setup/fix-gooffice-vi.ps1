Write-Output "=== Step 1: Install Vietnamese language pack ==="
$langpack = "C:\Users\NAM\GoOffice\dist\win-x64\GoOffice_1.0.0.0_Win_x86-64_en-US_vi.msi"
if (Test-Path $langpack) {
    Write-Output "Installing language pack..."
    $result = Start-Process msiexec -ArgumentList "/i", $langpack, "/qb", "/norestart" -Wait -PassThru
    Write-Output "Exit code: $($result.ExitCode)"
} else {
    Write-Output "Langpack MSI NOT found at: $langpack"
}

Write-Output ""
Write-Output "=== Step 2: Configure GoOffice to use Vietnamese ==="
$regPath = "HKCU:\Software\GoOffice\1.0"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
    Write-Output "Created registry path: $regPath"
}

New-Item -Path "$regPath\Common" -Force | Out-Null
New-Item -Path "$regPath\Locale" -Force | Out-Null

Set-ItemProperty -Path "$regPath\Common" -Name "Locale" -Value "vi" -Type String
Set-ItemProperty -Path "$regPath\Common" -Name "Language" -Value "vi" -Type String
Set-ItemProperty -Path "$regPath\Common" -Name "DefaultLocale" -Value "vi-VN" -Type String
Write-Output "Set Locale = vi, Language = vi, DefaultLocale = vi-VN"

Write-Output ""
Write-Output "=== Step 3: Verify locale directory ==="
$localePath = "C:\Program Files\GoOffice\share\locale\vi"
if (Test-Path $localePath) {
    Write-Output "locale/vi EXISTS after install:"
    Get-ChildItem $localePath -Directory | Select-Object -ExpandProperty Name | ForEach-Object { Write-Output "  locale/$_" }
} else {
    Write-Output "locale/vi NOT FOUND - requires reinstalling langpack MSI manually"
    Write-Output "Run in PowerShell (Admin): Start-Process msiexec -ArgumentList '/i',`"$langpack`",'/qb' -Wait -Verb RunAs"
}

Write-Output ""
Write-Output "=== DONE ==="
