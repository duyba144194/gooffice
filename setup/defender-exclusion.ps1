# Add Windows Defender exclusions for the GoOffice build tree
$ErrorActionPreference = 'Continue'
Start-Transcript -Path 'C:\Users\NAM\GoOffice\logs\defender-exclusion.log' -Force
Write-Output "=== Adding Defender exclusions for GoOffice build dirs ==="
Add-MpPreference -ExclusionPath 'C:\Users\NAM\GoOffice'
Add-MpPreference -ExclusionPath 'C:\Users\NAM\lo'
Add-MpPreference -ExclusionProcess 'cl.exe'
Add-MpPreference -ExclusionProcess 'make.exe'
Add-MpPreference -ExclusionProcess 'jom.exe'
Add-MpPreference -ExclusionProcess 'link.exe'
Add-MpPreference -ExclusionProcess 'midl.exe'
Write-Output "=== Verify (should list the paths above) ==="
(Get-MpPreference).ExclusionPath
Write-Output "=== DONE ==="
Stop-Transcript
