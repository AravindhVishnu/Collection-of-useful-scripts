# Description: Configure IP settings on a network interface controller (NIC).
# For this script to work correctly, Powershell needs to be run in admin mode.

param(
	[string]$Name = "Ethernet",
	[string]$Type = "Static",
	[string]$IPType = "IPv4",
	[IPAddress]$IPv4Address = "192.168.1.2",
	[string]$SubnetMask = "255.255.255.0",
	[IPAddress]$IPv4Gateway = "192.168.1.1",
	[string]$IPv4DNS = "8.8.8.8,8.8.4.4",
	[IPAddress]$IPv6Address = "aaaa::2",
	[int]$SubnetPrefixLength = 64,
	[IPAddress]$IPv6Gateway = "aaaa::1",
	[string]$IPv6DNS = "fd12:3456:ffff:1::1,fd12:3456:ffff:1::2"
)

# Stop running the script in case there is an error
$ErrorActionPreference = "Stop"

# Start the stop watch used to measure the script execution time
$StopWatch = New-Object System.Diagnostics.Stopwatch
$StopWatch.Start()

Write-Host "------------ Start Script -------------"

# Check if inputs are OK
$inputsOK = "True"
try
{
	# Check if the NIC can be found
	Get-NetAdapter -Name $Name | Out-Null
}
catch
{
	$inputsOK = "False"
	Write-Error "NIC not found"
}

# Check Type input parameter
if (($Type -ne "Static") -and ($Type -ne "DHCP"))
{
	$inputsOK = "False"
	Write-Error "Type not supported"		
}


# Check IPType input parameter
if (($IPType -ne "IPv4") -and ($IPType -ne "IPv6"))
{
	$inputsOK = "False"
	Write-Error "IPType not supported"		
}

if ($IPType -eq "IPv4")
{
	# Convert the Subnet mask from the decimal dotted notation to 
	# Classless Inter-Domain Routing (CIDR) notation
	switch ($SubnetMask)
	{
		{$_ -in "128.0.0.0" ,"128.000.000.000"} {$CIDR = 1; Break}
		{$_ -in "192.0.0.0" ,"192.000.000.000"} {$CIDR = 2; Break}
		{$_ -in "224.0.0.0" ,"224.000.000.000"} {$CIDR = 3; Break}
		{$_ -in "240.0.0.0" ,"240.000.000.000"} {$CIDR = 4; Break}
		{$_ -in "248.0.0.0" ,"248.000.000.000"} {$CIDR = 5; Break}
		{$_ -in "252.0.0.0" ,"252.000.000.000"} {$CIDR = 6; Break}
		{$_ -in "254.0.0.0" ,"254.000.000.000"} {$CIDR = 7; Break}
		{$_ -in "255.0.0.0" ,"255.000.000.000"} {$CIDR = 8; Break}
		{$_ -in "255.128.0.0" ,"255.128.000.000"} {$CIDR = 9; Break}
		{$_ -in "255.192.0.0" ,"255.192.000.000"} {$CIDR = 10; Break}
		{$_ -in "255.224.0.0" ,"255.224.000.000"} {$CIDR = 11; Break}
		{$_ -in "255.240.0.0" ,"255.240.000.000"} {$CIDR = 12; Break}
		{$_ -in "255.248.0.0" ,"255.248.000.000"} {$CIDR = 13; Break}
		{$_ -in "255.252.0.0" ,"255.252.000.000"} {$CIDR = 14; Break}
		{$_ -in "255.254.0.0" ,"255.254.000.000"} {$CIDR = 15; Break}
		{$_ -in "255.255.0.0" ,"255.255.000.000"} {$CIDR = 16; Break}
		{$_ -in "255.255.128.0" ,"255.255.128.000"} {$CIDR = 17; Break}
		{$_ -in "255.255.192.0" ,"255.255.192.000"} {$CIDR = 18; Break}
		{$_ -in "255.255.224.0" ,"255.255.224.000"} {$CIDR = 19; Break}
		{$_ -in "255.255.240.0" ,"255.255.240.000"} {$CIDR = 20; Break}
		{$_ -in "255.255.248.0" ,"255.255.248.000"} {$CIDR = 21; Break}
		{$_ -in "255.255.252.0" ,"255.255.252.000"} {$CIDR = 22; Break}
		{$_ -in "255.255.254.0" ,"255.255.254.000"} {$CIDR = 23; Break}
		{$_ -in "255.255.255.0" ,"255.255.255.000"} {$CIDR = 24; Break}
		"255.255.255.128" {$CIDR = 25; Break}
		"255.255.255.192" {$CIDR = 26; Break}
		"255.255.255.224" {$CIDR = 27; Break}
		"255.255.255.240" {$CIDR = 28; Break}
		"255.255.255.248" {$CIDR = 29; Break}
		"255.255.255.252" {$CIDR = 30; Break}
		"255.255.255.254" {$CIDR = 31; Break}
		"255.255.255.255" {$CIDR = 32; Break}
		default {$inputsOK = "False"; Write-Error "SubnetMask not supported"; Break}
	}
}

if ($inputsOK -eq "True")
{
	if ($IPType -eq "IPv4")
	{
		Write-Host "Enable IPv4 on the NIC"
		Set-NetAdapterBinding -Name $Name -DisplayName *4* -Enabled $True
	}
	else  # IPv6
	{
		Write-Host "Enable IPv6 on the NIC"
		Set-NetAdapterBinding -Name $Name -DisplayName *6* -Enabled $True		
	}
	
	try
	{
		Write-Host "Remove any existing IP and gateway from the NIC"
		Remove-NetIpAddress -InterfaceAlias $Name -AddressFamily $IPType -Confirm:$false
		Remove-NetRoute -InterfaceAlias $Name -AddressFamily $IPType -Confirm:$false
	}
	catch
	{
		Write-Host "No existing IP and gateway on the NIC to be removed"
	}

	if ($Type -eq "Static") 
	{
		Write-Host "Disable DHCP in the registry (this makes it possible to configure the static IP even if the NIC is diabled)"
		Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\$((Get-NetAdapter -InterfaceAlias $Name).InterfaceGuid)" -Name EnableDHCP -Value 0
	
		Write-Host "Disabling DHCP on NIC"
		Set-NetIPInterface -InterfaceAlias $Name -DHCP Disabled
		
		if ($IPType -eq "IPv4")
		{
			Write-Host "Configuring the IPv4 address and default gateway"
			if ($PSBoundParameters.ContainsKey('IPv4Gateway') -eq $True)
			{
				# Configure the DefaultGateway only if the caller specifies it
				Write-Host "Configuring the IPv4 address, subnet mask and default gateway"
				New-NetIPAddress -InterfaceAlias $Name -AddressFamily $IPType -IPAddress $IPv4Address -PrefixLength $CIDR -DefaultGateway $Ipv4Gateway | Out-Null
			}
			else
			{
				Write-Host "Configuring the IPv4 address and subnet mask"
				New-NetIPAddress -InterfaceAlias $Name -AddressFamily $IPType -IPAddress $IPv4Address -PrefixLength $CIDR | Out-Null
			}
			
			if ($PSBoundParameters.ContainsKey('IPv4DNS') -eq $True)
			{
				# Configure the DNS client server IP addresses only if the caller specifies it
				Write-Host "Configuring the DNS client server IP addresses"
				Set-DnsClientServerAddress -InterfaceAlias $Name -ServerAddresses ($IPv4DNS)
			}
		}
		else  # IPv6
		{
			Write-Host "Configuring the IPv6 address and default gateway"
			if ($PSBoundParameters.ContainsKey('IPv6Gateway') -eq $True)
			{
				# Configure the DefaultGateway only if the caller specifies it
				Write-Host "Configuring the IPv6 address, subnet prefix length and default gateway"
				New-NetIPAddress -InterfaceAlias $Name -AddressFamily $IPType -IPAddress $IPv6Address -PrefixLength $SubnetPrefixLength -DefaultGateway $Ipv6Gateway | Out-Null
			}
			else
			{
				Write-Host "Configuring the IPv6 address and subnet prefix length"
				New-NetIPAddress -InterfaceAlias $Name -AddressFamily $IPType -IPAddress $IPv6Address -PrefixLength $SubnetPrefixLength | Out-Null
			}
			
			if ($PSBoundParameters.ContainsKey('IPv6DNS') -eq $True)
			{
				# Configure the DNS client server IP addresses only if the caller specifies it
				Write-Host "Configuring the DNS client server IP addresses"
				Set-DnsClientServerAddress -InterfaceAlias $Name -ServerAddresses $IPv6DNS
			}
		}

		Write-Host "Restarting NIC"
		Restart-NetAdapter -InterfaceAlias $Name
	}
	else  # DHCP
	{
		Write-Host "Enable DHCP in the registry"
		Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\$((Get-NetAdapter -InterfaceAlias $Name).InterfaceGuid)" -Name EnableDHCP -Value 1

		Write-Host "Enabling DHCP on NIC"
		Set-NetIPInterface -InterfaceAlias $Name -DHCP Enabled

		Write-Host "Enabling automatic DNS"
		Set-DnsClientServerAddress -InterfaceAlias $Name -ResetServerAddresses
	
		Write-Host "Restarting NIC"
		Restart-NetAdapter -InterfaceAlias $Name
	}
	Write-Host "IP settings configured"
}
else
{
	Write-Host "IP settings not configured"
}

$StopWatch.Stop()
$execTimeString = "Script execution time: " + $StopWatch.ElapsedMilliSeconds + " ms"
Write-Host $execTimeString

$Error.Clear()

Write-Host "------------ Stop Script --------------"
