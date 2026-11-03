param([string]$ExePath)
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class IcoDump {
  [DllImport("kernel32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr LoadLibraryEx(string f, IntPtr h, uint flags);
  [DllImport("kernel32.dll", CharSet=CharSet.Ansi)] public static extern IntPtr FindResource(IntPtr h, IntPtr name, string type);
  [DllImport("kernel32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr FindResource(IntPtr h, IntPtr name, IntPtr type);
  [DllImport("kernel32.dll")] public static extern IntPtr LoadResource(IntPtr h, IntPtr r);
  [DllImport("kernel32.dll")] public static extern IntPtr LockResource(IntPtr r);
  [DllImport("kernel32.dll")] public static extern uint SizeofResource(IntPtr h, IntPtr r);
  [DllImport("kernel32.dll")] public static extern bool FreeLibrary(IntPtr h);
  [DllImport("kernel32.dll")] public static extern bool EnumResourceNames(IntPtr h, IntPtr type, EnumResNameProc cb, IntPtr lp);
  public delegate bool EnumResNameProc(IntPtr h, IntPtr type, IntPtr name, IntPtr lp);
}
'@
$h = [IcoDump]::LoadLibraryEx($ExePath, [IntPtr]::Zero, 0x2)
Write-Host "lib=$([bool]$h)"
$cb = [IcoDump+EnumResNameProc]{ param($hm,$t,$n,$l)
    Write-Host "found id=$([Int64]$n)"
    return $true }
[IcoDump]::EnumResourceNames($h, [IntPtr]3, $cb, [IntPtr]::Zero) | Out-Null
Write-Host "enum-done"
[IcoDump]::FreeLibrary($h) | Out-Null
