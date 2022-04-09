# Description: Merge serveral static libraries into one single static library file
# which is easy for the client executable to keep track of and use.

param(
	[string]$InputFolderPath = ".",
	[string]$OutputFilePath = "./libMerged.a"
)

# Stop running the script in case there is an error
$ErrorActionPreference = "Stop"

# Start the stop watch used to measure the script execution time
$StopWatch = New-Object System.Diagnostics.Stopwatch
$StopWatch.Start()

Write-Host "------------ Start Script -------------"

# Check paths
$pathsOK = "True"
$OutputFolderPath = Split-Path -Path $OutputFilePath
if ((Test-Path -Path $OutputFolderPath) -eq $False)
{
	Write-Host "Error: The path to where the merged static library is to be stored does not exist."
	$pathsOK = "False"
}
if ((Test-Path -Path $OutputFilePath) -eq $True)
{
	Write-Host "Error: The merged static library file already exists."
	$pathsOK = "False"
}
if ((Test-Path -Path $InputFolderPath) -eq $False)
{
	Write-Host "Error: The path to where the static libraries (to be merged) are stored does not exist."
	$pathsOK = "False"
}

if ($pathsOK -eq "True")
{
	$libs = Get-ChildItem -Path "$InputFolderPath/*" -Include *.a -File
	if ($libs.Count -lt 2)
	{
		Write-Host "Error: There needs to be at least two static libraries to be merged"
	}
	else
	{	
		foreach ($lib in $libs) 
		{
			$lib = Split-Path -Path $lib -Leaf  # Get only the file name
			Write-Host "Adding $lib"
		}
		Write-Host "A total of $($libs.Count) static libraries to be merged"
		
		Push-Location -Path "."
		
		# Create the MRI file
		New-Item -Path "." -Name "merge.mri" -ItemType "file" -Force | Out-Null
		Clear-Content -Path "./merge.mri" -Force | Out-Null
		Write-Host "MRI file created"
		
		$OutputFileName = Split-Path -Path $OutputFilePath -Leaf
		
		# Write the contents of the MRI file
		Add-Content -Path "./merge.mri" -Value "create $OutputFileName" -Force | Out-Null
		
		# Write the names of all static libraries
		$table = Get-ChildItem -Path "$InputFolderPath/*" -Include *.a -Name
		foreach ($row in $table)
		{
			Add-Content -Path "./merge.mri" -Value "addlib $row" -Force | Out-Null
		}
		
		# These two lines (save and end) are required to be written at the end of the MRI file 
		Add-Content -Path "./merge.mri" -Value "save" -Force | Out-Null
		Add-Content -Path "./merge.mri" -Value "end" -Force | Out-Null
		Write-Host "MRI file contents filled"

		if ($InputFolderPath -ne ".")
		{
			# Copy all static libraries to the local folder for temporary storage
			Copy-Item -Path "$InputFolderPath/*.a" -Destination "." -Force | Out-Null
			Write-Host "Static libraries copied to the local folder for temporary storage"
		}
		
		# Merge several static libraries using the Linux archiver script command
		Get-Content "./merge.mri" | &ar -M | Out-Null
		Write-Host "Merged the static libraries"

		if ($InputFolderPath -ne ".")
		{
			# Delete all static libraries in the local folder except the merged one
			Remove-Item -Path "./*.a" -Exclude "$OutputFileName" -Force | Out-Null
			Write-Host "Delete static libraries in the local folder except the merged one"
		}

		# This Linux command is used to generate an index to the static lib contents and store it in the archive.
		# An archive with such an index speeds up linking to the library and allows routines to call each other 
		# without regard to their placement in the archive.
		&ar -s "$OutputFileName"
		Write-Host "Generated an index to the static lib contents and stored it in the merged library"

		# Delete the MRI file, since it is no longer needed
		Remove-Item -Path "./merge.mri" -Force | Out-Null
		Write-Host "MRI file deleted, since it is no longer needed"

		if ($OutputFolderPath -ne ".")
		{
			# Move the generated merged static library to the desired location
			Move-Item -Path "./$OutputFileName" -Destination "$OutputFolderPath" -Force | Out-Null
			Write-Host "Merged static library moved to the desired destination"
		}
		
		Pop-Location
	}
}

$StopWatch.Stop()
$execTimeString = "Script execution time: " + $StopWatch.ElapsedMilliSeconds + " ms"
Write-Host $execTimeString

$Error.Clear()

Write-Host "------------ Stop Script --------------"