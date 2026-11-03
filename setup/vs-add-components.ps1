# Add missing VS components (fixed quoting for installPath with spaces)
$ErrorActionPreference = 'Continue'
Start-Transcript -Path 'C:\Users\NAM\GoOffice\logs\vs-components-add2.log' -Force
$vsArgs = 'modify --quiet --wait --norestart --nocache --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools" --add Microsoft.Net.Component.4.8.SDK --add Microsoft.VisualStudio.Component.VC.Redist.MSM --add Microsoft.VisualStudio.Component.VC.CMake.Project --add Microsoft.VisualStudio.Component.VC.Llvm.Clang --add Microsoft.VisualStudio.Component.VC.Tools.ARM64EC'
$proc = Start-Process -FilePath 'C:\Users\NAM\GoOffice\dl\vs_BuildTools.exe' -ArgumentList $vsArgs -Wait -PassThru
Write-Output "VS modify exit code: $($proc.ExitCode)  (0=OK, 3010=OK needs reboot)"
Write-Output "=== verify al.exe ==="
Get-ChildItem 'C:\Program Files (x86)\Microsoft SDKs\Windows' -Recurse -Filter al.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
Write-Output "=== DONE ==="
Stop-Transcript
