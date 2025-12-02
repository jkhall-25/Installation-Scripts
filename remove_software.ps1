$computerListPath = 'Installation-Scripts\computernames.txt'
$computerList = Get-Content -Path $computerListPath
$search = [name]

$ComputerList | Foreach-Object {
  $InstallerPath = [string]
  $args = "/q /uninstall"
  Start-Process -FilePath $InstallerPath -ArgumentList $args -Wait

Try {
  $result = "error"
  $result = Invoke-Command -Computername $_ -ErrorAction Stop -Scriptblock {  
    & Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -like "*$search*} | Select-Object -Property DisplayName, UninstallString
}

if ($null -eq $result) {
  Write-Host "$search successfully uninstalled from $_"
  } 
  else {
  $__
  Write-Host $result | Format-Table -Autosize
  }
}

  Catch {
    Write-Host "Could not connect to $_"
  }
}
