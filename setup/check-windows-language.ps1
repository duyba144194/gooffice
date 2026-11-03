Write-Output '=== Windows Display Language ==='
$ui = Get-WinUILanguageOverride -ErrorAction SilentlyContinue
if ($ui) {
    "  = $ui"
} else {
    "  No UI override (uses system default)"
}

Write-Output '=== User Language List ==='
try {
    $list = Get-WinUserLanguageList
    foreach ($l in $list) {
        "  - $($l.LanguageTag)"
    }
} catch {
    "  Error: $($_.Exception.Message)"
}

Write-Output '=== Windows Region (System Locale) ==='
$region = Get-WinSystemLocale
"  = $($region.Name) ($($region.DisplayName))"

Write-Output '=== Input Method ==='
try {
    $methods = Get-WinUserLanguageList | Select-Object -ExpandProperty InputMethodPreferences
    foreach ($m in $methods) {
        "  - $($m.KbdLayoutId)"
    }
} catch {
    "  No input methods configured"
}
