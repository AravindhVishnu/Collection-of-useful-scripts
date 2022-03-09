# Description: Store computer information in a text file which will be created 
# in the same folder as this script is placed in.

# Stop running the script in case there is an error
$ErrorActionPreference = "Stop"

# Start the stop watch used to measure the script execution time
$StopWatch = New-Object System.Diagnostics.Stopwatch
$StopWatch.Start()

Write-Host "------------ Start Script -------------"

$DateTimeNow = Get-Date -Format "_ddMMyyyy_HHmmss"
$FilePath = (Get-Location).Path + "\" + "specs_" + $env:COMPUTERNAME + $DateTimeNow + ".txt"

"General computer info" | Out-File -FilePath $FilePath
Get-ComputerInfo | Out-File -FilePath $FilePath -Append

"Desktop settings" | Out-File -FilePath $FilePath -Append
Get-CimInstance -ClassName Win32_Desktop | Select-Object -ExcludeProperty "CIM*" | 
Out-File -FilePath $FilePath -Append

"BIOS" | Out-File -FilePath $FilePath -Append
Get-CimInstance -ClassName Win32_BIOS | Out-File -FilePath $FilePath -Append

"Base board" | Out-File -FilePath $FilePath -Append
Get-WmiObject -ClassName Win32_Baseboard | Out-File -FilePath $FilePath -Append

"Physical memory" | Out-File -FilePath $FilePath -Append
Get-WmiObject Win32_Physicalmemory | 
Select-Object Manufacturer,Banklabel,Configuredclockspeed,Devicelocator,Capacity,Serialnumber | 
Out-File -FilePath $FilePath -Append

"Processor" | Out-File -FilePath $FilePath -Append
Get-CimInstance -ClassName Win32_Processor | Select-Object -ExcludeProperty "CIM*" | 
Out-File -FilePath $FilePath -Append

"Computer manufacturer and model" | Out-File -FilePath $FilePath -Append
Get-CimInstance -ClassName Win32_ComputerSystem | Out-File -FilePath $FilePath -Append

"Installed Hotfixes" | Out-File -FilePath $FilePath -Append
Get-CimInstance -ClassName Win32_QuickFixEngineering | Out-File -FilePath $FilePath -Append

"Operating system version info" | Out-File -FilePath $FilePath -Append
Get-CimInstance -ClassName Win32_OperatingSystem |
Select-Object -Property BuildNumber,BuildType,OSType,ServicePackMajorVersion,ServicePackMinorVersion | 
Out-File -FilePath $FilePath -Append

"Local users and owner" | Out-File -FilePath $FilePath -Append
Get-CimInstance -ClassName Win32_OperatingSystem |
Select-Object -Property NumberOfLicensedUsers,NumberOfUsers,RegisteredUser | 
Out-File -FilePath $FilePath -Append

"Available disk space" | Out-File -FilePath $FilePath -Append
Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" |
Out-File -FilePath $FilePath -Append

"Logon session" | Out-File -FilePath $FilePath -Append
Get-CimInstance -ClassName Win32_LogonSession | Out-File -FilePath $FilePath -Append

"User logged on to the computer" | Out-File -FilePath $FilePath -Append
Get-CimInstance -ClassName Win32_ComputerSystem -Property UserName | 
Out-File -FilePath $FilePath -Append

"Local time and date" | Out-File -FilePath $FilePath -Append
Get-CimInstance -ClassName Win32_LocalTime | Out-File -FilePath $FilePath -Append

"Service status" | Out-File -FilePath $FilePath -Append
Get-CimInstance -ClassName Win32_Service |
Format-Table -Property Status,Name,DisplayName -AutoSize -Wrap |
Out-File -FilePath $FilePath -Append

"Network interface controller" | Out-File -FilePath $FilePath -Append
Get-NetIPAddress | Out-File -FilePath $FilePath -Append
Get-NetIPConfiguration | Out-File -FilePath $FilePath -Append

$StopWatch.Stop()
$execTimeString = "Script execution time: " + $StopWatch.ElapsedMilliSeconds + " ms"
Write-Host $execTimeString

$Error.Clear()

Write-Host "------------ Stop Script --------------"
