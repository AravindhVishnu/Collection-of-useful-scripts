# Description: Merge serveral static libraries into one single static library file
# which is easy for the client program to keep track of and use.

param(
	[string]$InputFolderPath = ".",
	[string]$OutputFilePath = ".\merged.lib"
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
	$libs = Get-ChildItem -Path "$InputFolderPath\*" -Include *.lib,*.LIB -File
	if ($libs.Count -lt 2)
	{
		Write-Host "Error: There needs to be at least two static libraries to be merged"
	}
	else
	{
		# Initialize arguments for Microsoft Library Manager
		$arguments = @("/OUT:$OutputFilePath", "/LIBPATH:$InputFolderPath")
		
		foreach ($lib in $libs) 
		{
			$lib = Split-Path -Path $lib -Leaf  # Get only the file name
			Write-Host "Adding $lib"
			$arguments += $lib  # Add all libs to $arguments
		}
		Write-Host "A total of $($libs.Count) static libraries to be merged"
	
		try
		{
			# Execute the Microsoft Library Manager
			# The arguments are the path to the output file, path to the folder where all static 
			# libraries (to be combined) are located, and the names of these static libraries.
			# For this command to work, the path to the folder containing lib.exe:
			# C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.31.31103\bin\Hostx64\x64\
			# needs to be added to the PATH environment variable. If Visual Studio 2022 Community version is used,
			# the above path is correct. For another Visual Studio version, find out the path to the folder 
			# containing lib.exe
			Write-Host "Run Microsoft Library Manager to merge all the static libraries."
			&lib.exe $arguments
		}
		catch
		{
			Write-Host "Error: Not possible to correctly run Microsoft Library Manager."
		}
	}
}

$StopWatch.Stop()
$execTimeString = "Script execution time: " + $StopWatch.ElapsedMilliSeconds + " ms"
Write-Host $execTimeString

$Error.Clear()

Write-Host "------------ Stop Script --------------"
