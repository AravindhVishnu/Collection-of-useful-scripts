# Description: Print all Word, PDF and Notepad documents located in the 
# same folder (the default printer is used).

param(
	[string]$Path = ".",
	[string]$RemovePrintJobs = "false",
	[string]$PrinterName = "HPDC4550 (HP DeskJet 4100 series)",
	[string]$PrintEnable = "true",
	[int]$WaitTime = 10
)

# Stop running the script in case there is an error
$ErrorActionPreference = "Stop"

# Start the stop watch used to measure the script execution time
$StopWatch = New-Object System.Diagnostics.Stopwatch
$StopWatch.Start()

Write-Host "------------ Start Script -------------"

# Check if all existing print jobs shall be removed
if ($RemovePrintJobs -eq "true")
{
	# Check if PrinterName was input by the caller
	if ($PSBoundParameters.ContainsKey('PrinterName') -eq $False)
	{
		Write-Host "Default printer name is required for removing existing print jobs"
	}
	else
	{
		Write-Host "Removing existing print jobs"
		Get-PrintJob -ComputerName $env:COMPUTERNAME -PrinterName $PrinterName | 
		Where-Object {$_.JobStatus -eq 'Complete' -or $_.JobStatus -eq 'Error' -or $_.JobStatus -eq 'Printed' -or $_.JobStatus -eq ''} | 
		Remove-PrintJob
	}
}

# Check path
if ((Test-Path -Path $Path) -eq $False) 
{
	Write-Host "The path does not exist. No documents were sent to the printer."
}
else  # Print all documents
{
	if ($PrintEnable -eq "true")
	{
		Push-Location
	
		$docs = @()
		$docs = Get-ChildItem -Path . -Include *.txt,*.doc,*docx,*pdf -Recurse -Name
		if ($docs.Count -eq 0)
		{
			Write-Host "No documents were found. No documents were sent to the printer."
		}
		else
		{
			foreach ($doc in $docs)
			{
				Start-Process -Filepath $doc -Verb Print
				Write-Host "Printing $doc"
				Start-Sleep -Seconds $WaitTime
			}
		}
	
		Pop-Location
	}
}

$StopWatch.Stop()
$execTimeString = "Script execution time: " + $StopWatch.ElapsedMilliSeconds + " ms"
Write-Host $execTimeString

Write-Host "------------ Stop Script --------------"