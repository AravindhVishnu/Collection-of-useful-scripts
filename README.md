# Collection-of-useful-scripts
Collection of useful Powershell scripts for SW development

Collection:
- ConfigureIPSettings.ps1
- PrintDocuments.ps1
- StoreComputerInfo.ps1
- MergeStaticLibs.ps1

Tools: Powershell 5.1, Visual Studio 2022, Visual Studio Code (with the Powershell extension). 
Debugging the Powershell script can be done in the Visual Studio Code environment.

Note: These Powershell scripts have only been tested on Windows 10.

Description: 

- ConfigureIPSettings.ps1: 
Configure IP settings on a network interface controller (NIC). IPv4 or IPv6 settings are supported.

Instructions: Start Powershell console as an administrator. Find out the name of the NIC that shall be configured.

Static IPv4 configuration: 
powershell -ExecutionPolicy Bypass -File PathToTheScript -Name Ethernet -Type Static -IPType IPv4 -IPv4Address 192.168.1.2 -SubnetMask 255.255.255.0 -IPv4Gateway 192.168.1.1 -IPv4DNS 8.8.8.8','8.8.4.4

Static IPv4 configuration (in case the default gateway and DNS address need not be configured): 
powershell -ExecutionPolicy Bypass -File PathToTheScript -Name Ethernet -Type Static -IPType IPv4 -IPv4Address 192.168.1.2 -SubnetMask 255.255.255.0 

DHCP IPv4 configuration: 
powershell -ExecutionPolicy Bypass -File PathToTheScript -Name Ethernet -Type DHCP -IPType IPv4

Static IPv6 configuration: 
powershell -ExecutionPolicy Bypass -File PathToTheScript -Name Ethernet -Type Static -IPType IPv6 -IPv6Address aaaa::2 -SubnetPrefixLength 64 -IPv6Gateway aaaa::1 -IPv6DNS fd12:3456:ffff:1::1','fd12:3456:ffff:1::2

Static IPv6 configuration (in case the default gateway and DNS address need not be configured): 
powershell -ExecutionPolicy Bypass -File PathToTheScript -Name Ethernet -Type Static -IPType IPv6 -IPv6Address aaaa::2 -SubnetPrefixLength 64

DHCP IPv6 configuration: 
powershell -ExecutionPolicy Bypass -File PathToTheScript -Name Ethernet -Type DHCP -IPType IPv6

- PrintDocuments.ps1: Print all Word, PDF and Notepad documents located in the same folder (the default printer is used).
It is optionally possible to remove all existing print jobs before commencing with the print.

Instructions: Configure the default printer.

Print all documents: 
powershell -ExecutionPolicy Bypass -File PathToTheScript -Path PathToTheDocumentsFolder

Remove all existing print jobs and then print all documents: 
powershell -ExecutionPolicy Bypass -File PrintDocuments.ps1 -Path PathToTheDocumentsFolder -RemovePrintJobs true -PrinterName DefaultPrinterName

- StoreComputerInfo.ps1: Store computer info in a text file which is created in the same folder as this script is placed in.

Instructions: Start Powershell console as an administrator. Move the Powershell script to a suitable folder.

Create a text file which contains detailed computer information:
powershell -ExecutionPolicy Bypass -File PathToTheScript

- MergeStaticLibs.ps1: Merge serveral static libraries into one single static library file which is easy for the client executable to keep track of and use.

Instructions: Make sure all the static libraries are placed in the InputFolderPath (at least two static libraries are needed for the merge to work).
The following path needs to be added to the PATH environment variable: 
C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.31.31103\bin\Hostx64\x64\

Above path is correct if Visual Studio 2022 Community version is used. For another version of Visual Studio, find out the path to the folder containing 
lib.exe (Microsoft Library Manager).

Create the merged static library:
powershell -ExecutionPolicy Bypass -File PathToTheScript -InputFolderPath PathToFolderContainingAllStaticLibs -OutputFilePath PathToTheMergedStaticLibFile
