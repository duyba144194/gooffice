param([string]$Sql, [string]$MsiPath)
$wi = New-Object -ComObject WindowsInstaller.Installer
$db = $wi.GetType().InvokeMember('OpenDatabase','InvokeMethod',$null,$wi,@($MsiPath,0))
$v = $db.GetType().InvokeMember('OpenView','InvokeMethod',$null,$db,@($Sql))
$v.GetType().InvokeMember('Execute','InvokeMethod',$null,$v,$null)
while ($true) {
  $r = $v.GetType().InvokeMember('Fetch','InvokeMethod',$null,$v,$null)
  if (-not $r) { break }
  $cols = 1..$r.GetType().InvokeMember('FieldCount','GetProperty',$null,$r,$null)
  ($cols | ForEach-Object { $r.GetType().InvokeMember('StringData','GetProperty',$null,$r,@($_)) }) -join ' | '
}
