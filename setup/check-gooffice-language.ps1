Write-Output '=== GoOffice Version ==='
$ver = & 'C:\Program Files\GoOffice\program\soffice.exe' --version 2>&1
Write-Output $ver

Write-Output ''
Write-Output '=== Language Pack Files ==='
$langDir = 'C:\Program Files\GoOffice\program\locale'
if (Test-Path $langDir) {
    Get-ChildItem $langDir -Directory | Select-Object Name
} else {
    'No locale directory found'
}

Write-Output ''
Write-Output '=== .pak Files (UI Resources) ==='
$paks = Get-ChildItem 'C:\Program Files\GoOffice\program\*.pak' -ErrorAction SilentlyContinue
if ($paks) {
    $paks | Select-Object Name | Select-Object -First 10
} else {
    'No .pak files found'
}
