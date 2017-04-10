# Powershell script to update Mule license on server
# https://docs.mulesoft.com/mule-user-guide/v/3.8/installing-an-enterprise-license

# Set MULE_HOME - Mule BIN directory
function Create-MuleHome
{
	param(
		[string] $MuleHomePath = "F:\Program Files\Mule\mule-enterprise-standalone-3.8.3\bin"
	)
	$MULE_HOME = $MuleHomePath
	return $MULE_HOME
}

# Set MULE_CONF - Mule Configuration directory
function Create-MuleConf
{
	param(
		[string] $MuleConfPath = "F:\Program Files\Mule\mule-enterprise-standalone-3.8.3\conf"
	)
	$MULE_CONF = $MuleConfPath
	return $MULE_CONF
}

function Get-Server
{
	Param(
		[Parameter(Mandatory=$true)]
		[string]$MuleServerName
	)
	if(($MuleServerName -eq "MULESOFTWIN.ADS.COT") -or ($MuleServerName -eq "MULESOFTWIN"))
	{
		# Prod Server - MULESOFTWINPROD.ADS.COT
		$MuleServer = "PROD"
	}
	elseif(($MuleServerName -eq "MULESOFTWINTEST.ADS.COT") -or ($MuleServerName -eq "MULESOFTWINTEST"))
	{
		# Test Server - MULESOFTWINTEST.ADS.COT
		$MuleServer = "TEST"
	}
	else
	{
		$MuleServer = "OTHER"
	}
		
	return $MuleServer
}



$MULE_HOME = Create-MuleHome
$MULE_CONF = Create-MuleConf

function Get-KeyLocation
{
	param(
		[Parameter(Mandatory=$true)]
		[string] $MuleServer,
		[string] $KeyPath
	)

	if(($MuleServer -eq 'MULESOFTWIN') -or ($MuleServer -eq 'PROD')) # If Mule Production Server then get key if exist
	{
		# Network location for Production Key if can access - had issue with MuleSoftWinTest
		$prodNetworkLoc = "\\fs0\dept\mis\Share\Mulesoft-plan\MuleESB-EE_Licenses\Prod\license.lic"

		# Use this MulesoftWin Local location if network location not available
		$locLocation = "F:\Transfers\license.lic"
				
		if($KeyPath -eq $prodNetworkLoc) # Test if Network location exist on MulesoftWin (Prod) server unless location defined by user
		{
			if(Test-Path $KeyPath)
			{
				$KeySource = $KeyPath
			}
		}
		elseif($KeyPath -eq $locLocation) # Test if local location exist on MulesoftWin unless location defined by user
		{
			if(Test-Path $KeyPath)
			{
				$KeySource = $KeyPath
			}
		}
		else # Test location defined by user exist
		{
			if(Test-Path $KeyPath)
			{
				$KeySource = $KeyPath
			}
			else
			{
				Write-Host 'Location Path does not exist'
			}
		}
	}
	elseif (($MuleServer -eq 'MULESOFTWINTEST') -or ($MuleServer -eq 'TEST')) 	# If Mule Test Server then get key if exist
	{
		# Network location for Test Key if can access - had an issue with MulesoftWinTest accessing
		$testNetworkLoc = "\\fs0\dept\mis\Share\Mulesoft-plan\MuleESB-EE_Licenses\PreProd\license.lic"

		# Use this MulesoftwinTest local location if network location not available
		$locLocation = "F:\Transfers\license.lic"

		if($KeyPath -eq $testNetworkLoc) # Test if network location exist on MulesoftWinTest (Test) server unless location defined by user
		{
			if(Test-Path $KeyPath)
			{
				$KeySource = $KeyPath
			}
		}
		elseif($KeyPath -eq $locLocation) # Test if local location exist on MulesoftWinTest unless location defined by user
		{
			if(Test-Path $KeyPath)
			{
				$KeySource = $KeyPath
			}
		}
		else # TEst location defined by user exist
		{
			if(Test-Path $KeyPath)
			{
				$KeySource = $KeyPath
			}
			else
			{
				Write-Host 'Location Path does not exist'
			}

		}

	}
	else
	{
		Write-Host "Not a Mulesoft server."
	}
	return $KeySource
}

function Remove-MuleLicenseKey
{
	Add-MuleConf
	Set-MuleConf
	# Remove Old License Key
	Set-Location $MULE_HOME_CONF
	Remove-Item .\muleLicenseKey.lic -Force
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