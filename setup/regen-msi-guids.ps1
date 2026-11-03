# Regenerate all static MSI GUIDs in codes.txt for the GoOffice fork so it can
# be installed side-by-side with stock LibreOffice (different ProductCode/UpgradeCode).
$path = 'C:\Users\NAM\GoOffice\src\core\instsetoo_native\inc_openoffice\windows\msi_templates\codes.txt'
$lines = Get-Content $path
$inProductCode = $false
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^\[(.+)\]') {
        $inProductCode = ($Matches[1] -eq 'PRODUCTCODE')
        continue
    }
    if ($inProductCode -and $lines[$i] -match '^(\S+) = "\{[0-9A-Fa-f-]+\}"$') {
        $lines[$i] = '{0} = "{{{1}}}"' -f $Matches[1], [guid]::NewGuid().ToString().ToUpper()
    }
}
Set-Content -Path $path -Value $lines -Encoding ASCII
Write-Output "GUIDS-REGENERATED"
Select-String -Path $path -Pattern '^\S+ = ' | Measure-Object | ForEach-Object { "entries: $($_.Count)" }
