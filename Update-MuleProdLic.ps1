# Powershell script to update Mule license on server
# https://docs.mulesoft.com/mule-user-guide/v/3.8/installing-an-enterprise-license

$MULE_HOME = "F:\Program Files\Mule\mule-enterprise-standalone-3.8.3\bin"
$MULE_HOME_CONF = "F:\Program Files\Mule\mule-enterprise-standalone-3.8.3\conf"

# Prod Server - MULESOFTWIN.ADS.COT

# Prod Key Location - \\fs0\dept\mis\Share\Mulesoft-plan\MuleESB-EE_Licenses\Prod\license.lic
$ProdKeyLoc = "\\fs0\dept\mis\Share\Mulesoft-plan\MuleESB-EE_Licenses\Prod\license.lic"

# Remove Old License Key
Set-Location $MULE_HOME_CONF
Remove-Item .\muleLicenseKey.lic -Force

# Change directory to MULE_HOME
Set-Location $MULE_HOME

# Verify Current License Key
$currentLicenseInfo = mule -verifyLicense
mule -verifyLicense

# Uninstall current License key
mule -unInstallLicense

# Copy new license key to bin directory in Mule Home
Copy-Item -Path $ProdKeyLoc -Destination $MULE_HOME -Force

# Install new License Key
mule -installLicense license.lic

$newLicenseInfo = mule -verifyLicense

mule -verifyLicense

$newLicenseInfo | Out-File "\\fs0\dept\mis\Share\Mulesoft-plan\MuleESB-EE_Licenses\Prod\newLicenseInfo.txt"
