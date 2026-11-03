# One-shot: uninstall current GoOffice, fresh-install the icon-rebranded MSI
$ErrorActionPreference = 'Continue'
Start-Transcript -Path 'C:\Users\NAM\GoOffice\logs\reinstall-batch.log' -Force
$prod = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like 'GoOffice*' } | Select-Object -First 1
if ($prod) {
    Write-Output "Uninstalling $($prod.DisplayName) [$($prod.PSChildName)]"
    $u = Start-Process msiexec.exe -ArgumentList "/x", $prod.PSChildName, "/qn", "/norestart" -Wait -PassThru
    Write-Output ("UNINSTALL-EXIT:" + $u.ExitCode)
} else {
    Write-Output "No existing GoOffice found"
}
Write-Output "Installing icon-rebranded MSI..."
$i = Start-Process msiexec.exe -ArgumentList '/i','C:\Users\NAM\GoOffice\dist\win-x64\GoOffice_1.0.0.0_Win_x86-64_en-US_vi.msi','/qn','/norestart','/l*v','C:\Users\NAM\GoOffice\logs\msi-final-install.log' -Wait -PassThru
Write-Output ("INSTALL-EXIT:" + $i.ExitCode)
Write-Output "=== DONE ==="
Stop-Transcript
