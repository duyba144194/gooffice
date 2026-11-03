# GoOffice smoke-test — run AFTER build completes
# Checks the portable instdir build (no install needed) and MSI artifacts.
$ErrorActionPreference = 'Continue'
$instdir = 'C:\Users\NAM\GoOffice\src\core\instdir'
$report = @()

Write-Output "=== 1. Binary exists ==="
$soffice = Join-Path $instdir 'program\soffice.exe'
$report += "soffice.exe: $(Test-Path $soffice)"

Write-Output "=== 2. Version info of soffice.bin ==="
$bin = Join-Path $instdir 'program\soffice.bin'
if (Test-Path $bin) {
    $v = (Get-Item $bin).VersionInfo
    $report += "ProductName : $($v.ProductName)"
    $report += "ProductVersion: $($v.ProductVersion)"
    $report += "CompanyName : $($v.CompanyName)"
    $report += "FileDescription: $($v.FileDescription)"
}

Write-Output "=== 3. Branding images present in instdir ==="
foreach ($f in @('program\intro.png', 'program\shell\logo.svg', 'program\shell\about.svg')) {
    $p = Join-Path $instdir $f
    if (Test-Path $p) {
        $h = (Get-FileHash $p -Algorithm SHA256).Hash
        $b = (Get-FileHash "C:\Users\NAM\Desktop\office\branding\$(Split-Path $f -Leaf)" -Algorithm SHA256).Hash -replace 'program\\shell\\','' 
        $report += "${f}: present"
    } else { $report += "${f}: MISSING" }
}

Write-Output "=== 4. Launch headless (conversion smoke test) ==="
$tmp = "$env:TEMP\gooffice-smoke"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
Set-Content -Path "$tmp\t.html" -Value '<html><body><h1>GoOffice smoke</h1><p>hello</p></body></html>'
& $soffice --headless --norestore --convert-to txt --outdir $tmp "$tmp\t.html" 2>&1 | Out-Host
Start-Sleep 5
$report += "convert output: $(Test-Path "$tmp\t.txt")"

Write-Output "=== 5. MSI artifacts ==="
Get-ChildItem -Path (Join-Path $instdir '..\workdir\installation') -Recurse -Include *.msi -ErrorAction SilentlyContinue |
    ForEach-Object { $report += "MSI: $($_.FullName) ($([math]::Round($_.Length/1MB)) MB)" }

Write-Output ""
Write-Output "===== SMOKE REPORT ====="
$report | ForEach-Object { Write-Output $_ }
