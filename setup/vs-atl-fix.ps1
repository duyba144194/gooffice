# Install x64/x86 ATL component (atls.lib missing for so_activex.dll link)
$ErrorActionPreference = 'Continue'
Start-Transcript -Path 'C:\Users\NAM\GoOffice\logs\vs-atl-fix.log' -Force
$vsArgs = 'modify --quiet --wait --norestart --nocache --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools" --add Microsoft.VisualStudio.Component.VC.ATL'
$proc = Start-Process -FilePath 'C:\Users\NAM\GoOffice\dl\vs_BuildTools.exe' -ArgumentList $vsArgs -Wait -PassThru
Write-Output "VS modify exit code: $($proc.ExitCode)"
Write-Output "=== verify atls.lib ==="
Get-ChildItem 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\*\atlmfc\lib' -Recurse -Filter atls.lib -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
Write-Output "=== DONE ==="
Stop-Transcript
