Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using Microsoft.Win32.Interop;

namespace MsiInspect {
    public class MsiDb {
        [DllImport("msi.dll", CharSet = CharSet.Unicode)]
        internal static extern uint MsiOpenDatabase(
            string szDatabasePath,
            uint uiOpenMode,
            out IntPtr hDb);

        [DllImport("msi.dll", CharSet = CharSet.Unicode)]
        internal static extern uint MsiDatabaseOpenView(
            IntPtr hDb,
            string szQuery,
            out IntPtr hView);

        [DllImport("msi.dll", CharSet = CharSet.Unicode)]
        internal static extern uint MsiViewExecute(IntPtr hView, IntPtr hInit);

        [DllImport("msi.dll", CharSet = CharSet.Unicode)]
        internal static extern uint MsiViewFetch(IntPtr hView, out IntPtr hRecord);

        [DllImport("msi.dll", CharSet = CharSet.Unicode)]
        internal static extern uint MsiCloseHandle(IntPtr hObject);
    }

    public static class MsiTools {
        [DllImport("msi.dll", CharSet = CharSet.Unicode)]
        internal static extern uint MsiRecordGetString(
            IntPtr hRec, int iField,
            [Out] System.Text.StringBuilder szBuffer,
            out int cchBufferMax);

        [DllImport("msi.dll", CharSet = CharSet.Unicode)]
        internal static extern uint MsiRecordGetFieldCount(IntPtr hRec);
    }
}
"@ -ErrorAction SilentlyContinue

$msi = 'C:\Users\NAM\GoOffice\dist\win-x64\GoOffice_1.0.0.0_Win_x86-64_en-US_vi.msi'
Write-Output "=== Inspecting MSI: $(Split-Path $msi -Leaf) ==="

# Try using Windows Installer COM via PowerShell built-in
Write-Output ''
Write-Output '=== Attempting MSI inspection via Get-Msi... ==='

# Use basic COM object approach
try {
    $installer = [activator]::CreateInstance([type]::GetTypeFromProgID("WindowsInstaller.Installer"))
    $db = $installer.GetType().InvokeMember("OpenDatabase", "InvokeMethod", $null, $installer, @($msi, 0))
    
    # Get table names
    $view = $db.GetType().InvokeMember("OpenView", "InvokeMethod", $null, $db, @("SELECT DISTINCT Table FROM MsiTables ORDER BY Table"))
    $view.GetType().InvokeMember("Execute", "InvokeMethod", $null, $view, $null) | Out-Null
    
    Write-Output 'Table names:'
    $rec = $view.GetType().InvokeMember("Fetch", "InvokeMethod", $null, $view, $null)
    while ($rec -ne $null) {
        $table = $rec.GetType().InvokeMember("StringData", "GetProperty", $null, $rec, @(1))
        Write-Output "  $table"
        $rec = $view.GetType().InvokeMember("Fetch", "InvokeMethod", $null, $view, $null)
    }
    
    # Check Files table for vi files
    Write-Output ''
    Write-Output '=== Files table entries containing "vi": ==='
    $view2 = $db.GetType().InvokeMember("OpenView", "InvokeMethod", $null, $db, @("SELECT File, FileName FROM Files WHERE FileName LIKE '%vi%' OR File LIKE '%vi%'"))
    $view2.GetType().InvokeMember("Execute", "InvokeMethod", $null, $view2, $null) | Out-Null
    $rec2 = $view2.GetType().InvokeMember("Fetch", "InvokeMethod", $null, $view2, $null)
    $count = 0
    while ($rec2 -ne $null -and $count -lt 50) {
        $file = $rec2.GetType().InvokeMember("StringData", "GetProperty", $null, $rec2, @(1))
        $name = $rec2.GetType().InvokeMember("StringData", "GetProperty", $null, $rec2, @(2))
        Write-Output "  $file -> $name"
        $rec2 = $view2.GetType().InvokeMember("Fetch", "InvokeMethod", $null, $view2, $null)
        $count++
    }
    if ($count -eq 0) {
        Write-Output '  (No vi files in Files table)'
    }
    
    $db.GetType().InvokeMember("Close", "InvokeMethod", $null, $db, @(0, $null)) | Out-Null
    
} catch {
    Write-Output "COM error: $_"
    # Fallback: try a simpler approach with Orca or similar
}
