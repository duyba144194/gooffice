# GoOffice admin setup: Visual Studio 2022 Build Tools + WSL2/Ubuntu
# Runs elevated. Logs to C:\Users\NAM\GoOffice\logs\admin-setup.log
$ErrorActionPreference = 'Continue'
Start-Transcript -Path 'C:\Users\NAM\GoOffice\logs\admin-setup.log' -Force

Write-Output "=== [1/3] Installing Visual Studio 2022 Build Tools (C++ x64 + ARM64) ==="
$vsArgs = '--quiet --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --add Microsoft.VisualStudio.Component.VC.Tools.ARM64 --add Microsoft.VisualStudio.Component.VC.ATL.ARM64 --add Microsoft.VisualStudio.Component.VC.Redist.14.Latest'
$proc = Start-Process -FilePath 'C:\Users\NAM\GoOffice\dl\vs_BuildTools.exe' -ArgumentList $vsArgs -Wait -PassThru
Write-Output "VS installer exit code: $($proc.ExitCode)  (0=OK, 3010=OK needs reboot, 743=already pending reboot)"

Write-Output "=== [2/3] Installing WSL2 platform ==="
wsl --install --no-launch 2>&1 | Write-Output
Write-Output "WSL platform install exit code: $LASTEXITCODE"

Write-Output "=== [3/3] Installing Ubuntu 24.04 distro ==="
wsl --install -d Ubuntu-24.04 --no-launch 2>&1 | Write-Output
Write-Output "Ubuntu install exit code: $LASTEXITCODE"

Write-Output "=== ADMIN SETUP FINISHED ==="
Stop-Transcript
