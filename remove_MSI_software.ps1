$computerListPath = 'Installation-Scripts\computernames.txt'
$computerList = Get-Content -Path $computerListPath
$cred = Get-Credential -Credential "$env:UserDomain\$env:UserName"
$search = [name]

$ComputerList | Foreach-Object -Parallel {
  $cred = $using:cred
  Invoke-Command -ComputerName $_ -Credential $using:cred -ScriptBlock  {
  & MsiExec.exe /x "{MSI_UNINSTALL_CODE}" /gn /norestart /l*v "C:\temp\software_install_logs\" + $search + "_uninstall.log"
} -ErrorAction Continue

Try {
  $result = "error"
  $result = Invoke-Command -Computername $_ -ErrorAction Stop -Scriptblock {  
    & Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -like "*$search*} | Select-Object -Property DisplayName, UninstallString
}

if ($null -eq $result) {
  Write-Host $search + " successfully uninstalled from $_"
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
