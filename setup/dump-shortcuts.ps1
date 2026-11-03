param([string]$MsiPath)
$wi = New-Object -ComObject WindowsInstaller.Installer
$db = $wi.GetType().InvokeMember('OpenDatabase','InvokeMethod',$null,$wi,@($MsiPath,0))
$view = $db.GetType().InvokeMember('OpenView','InvokeMethod',$null,$db,@('SELECT `Name`, `Target`, Icon_ FROM Shortcut'))
$view.GetType().InvokeMember('Execute','InvokeMethod',$null,$view,$null)
while ($true) {
    $rec = $view.GetType().InvokeMember('Fetch','InvokeMethod',$null,$view,$null)
    if (-not $rec) { break }
    $a = $rec.GetType().InvokeMember('StringData','GetProperty',$null,$rec,@(1))
    $b = $rec.GetType().InvokeMember('StringData','GetProperty',$null,$rec,@(2))
    $c = $rec.GetType().InvokeMember('StringData','GetProperty',$null,$rec,@(3))
    Write-Output ("{0} | target={1} | icon={2}" -f $a, $b, $c)
}
