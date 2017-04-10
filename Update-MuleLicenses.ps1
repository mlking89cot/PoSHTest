# Powershell script to update Mule license on server
# https://docs.mulesoft.com/mule-user-guide/v/3.8/installing-an-enterprise-license

# Mule Bin Directory
$MULE_HOME = "F:\Program Files\Mule\mule-enterprise-standalone-3.8.3\bin"

# Mule Configuration Directory
$MULE_HOME_CONF = "F:\Program Files\Mule\mule-enterprise-standalone-3.8.3\conf"

function Get-Server($result)
{
	if(($result -eq "MULESOFTWIN.ADS.COT") -or ($result -eq "MULESOFTWIN"))
	{
		# Prod Server - MULESOFTWINPROD.ADS.COT
		$server = "MULESOFTWIN"
	}
	elseif(($result -eq "MULESOFTWINTEST") -or ($result -eq "MULESOFTWINTEST"))
	{
		# Test Server - MULESOFTWINTEST.ADS.COT
		$server = "MULESOFTWINTEST"
	}
	else
	{
		$server = "OTHER"
	}
		
	return $server
}

function Get-KeyLocation($server)
{
	if($server -eq 'MULESOFTWIN')
	{
		# $ProdKeyLoc Location - "\\fs0\dept\mis\Share\Mulesoft-plan\MuleESB-EE_Licenses\Prod\license.lic"	
		# $KeyLocPath = "\\fs0\dept\mis\Share\Mulesoft-plan\MuleESB-EE_Licenses\Prod\license.lic"
		$KeyLocPath = "F:\Transfers\license.lic"
		return $KeyLocPath
	}
	elseif ($server -eq 'MULESOFTWINTEST')
	{
		# Pre-Prod Key Location - \\fs0\dept\mis\Share\Mulesoft-plan\MuleESB-EE_Licenses\PreProd\license.lic
		# $KeyLocPath = "\\fs0\dept\mis\Share\Mulesoft-plan\MuleESB-EE_Licenses\PreProd\license.lic"
		$KeyLocPath = "F:\Transfers\license.lic"
		return $KeyLocPath
	}
	else
	{
		Write-Host "Not Mulesoft server."
		$KeyLocPath = "Unknown"
		return $KeyLocPath
	}

}

function Remove-MuleLicenseKey
{
	# Remove Old License Key
	Set-Location $MULE_HOME_CONF
	Remove-Item .\muleLicenseKey.lic -Force
}

function Set-MuleConf
{
	# Change directory to MULE_CONF
	Set-Location $MULE_HOME_CONF
}

function Set-MuleHome
{
	# Change directory to MULE_HOME
	Set-Location $MULE_HOME
}

function Get-LicenseInfo
{
	# Verify Current License Key
	$currentLicenseInfo = mule -verifyLicense
	$currentLicenseInfo | Out-File "F:\Transfers\newLicenseInfo.txt"
}

function Uninstall-MuleLicenseKey
{
	# Change to MULE_HOME directory
	Set-Location $MULE_HOME
	
	# Uninstall current License key
	mule -unInstallLicense
}

function Copy-LicenseKey($keyLocPath, $MULE_HOME)
{
	# Copy new license key to bin directory in Mule Home
	Copy-Item -Path $keyLocPath -Destination $MULE_HOME -Force
}

function Install-NewLicense
{
	# Change to MULE_HOME directory
	Set-Location $MULE_HOME
	
	# Install new License Key
	mule -installLicense .\license.lic
}