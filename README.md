# Collection-of-useful-scripts
Collection of useful Powershell scripts for SW development

Description: 

- ConfigureIPSettings.ps1: 
Possible to configure IP settings on a network controller interface (NIC). 
IPv4 or IPv6 settings are supported.

Instructions: Start Powershell console as an administrator.

powershell -ExecutionPolicy Bypass -File ./ConfigureIPSettings.ps1 -Type Static -IPType IPv4 -IPv4Address 192.168.1.2 -SubnetMask 255.255.255.0 -IPv4Gateway 192.168.1.1 -IPv4DNS 8.8.8.8','8.8.4.4

powershell -ExecutionPolicy Bypass -File ./ConfigureIPSettings.ps1 -Type Static -IPType IPv4 -IPv4Address 192.168.1.2 -SubnetMask 255.255.255.0 

powershell -ExecutionPolicy Bypass -File ./ConfigureIPSettings.ps1 -Type DHCP -IPType IPv4

powershell -ExecutionPolicy Bypass -File ./ConfigureIPSettings.ps1 -Type Static -IPType IPv6 -IPv6Address aaaa::2 -SubnetPrefixLength 64 -IPv6Gateway aaaa::1 -IPv6DNS fd12:3456:ffff:1::1','fd12:3456:ffff:1::2

powershell -ExecutionPolicy Bypass -File ./ConfigureIPSettings.ps1 -Type Static -IPType IPv6 -IPv6Address aaaa::2 -SubnetPrefixLength 64

powershell -ExecutionPolicy Bypass -File ./ConfigureIPSettings.ps1 -Type DHCP -IPType IPv6

Tools: Powershell 5.1, Visual Studio Code (with the Powershell extension)

Use this command in the Powershell console: powershell -ExecutionPolicy Bypass -File pathToTheScript
Debugging the Powershell script can be done in the Visual Studio Code environment.

Note: These Powershell scripts have only been tested on Windows 10.
