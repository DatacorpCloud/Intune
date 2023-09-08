<#
    .SYNOPSIS
        ChangeDevicePersonalToCompany

    .DESCRIPTION
        This script change Device Owner in Intune in massive mod
       

    .AUTHOR
        Alessio Orpellini

    .VERSION
        1.0.2
    .NOTES
        The script can be executed via GPO or distribution software.


    .EXAMPLE
        Powershell.exe -ExecutionPolicy Bypass .\ChangeDevicePersonalToCompany.ps1
#>


# For use This Script Modify Connect to Microsoft Graph Section

Function Get-ManagedDevices(){

    [cmdletbinding()]

    param
    (
        [switch]$IncludeEAS,
        [switch]$ExcludeMDM
    )

    # Defining Variables
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/managedDevices"

    try {

        $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource"

        (Invoke-MgGraphRequest -Uri $uri -Method GET).Value

    }
    catch {
        Write-Host "Error getting managed devices: $($_.Exception.Message)" -f Red
    }

}

Function Set-ManagedDevicesOwnerType(){

    [cmdletbinding()]

    param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet("personal", "company")]
        $OwnerType
    )

    # Defining Variables
    $graphApiVersion = "beta"
    $Resource = "deviceManagement/managedDevices"

    try {

        $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource"

        $managedDevices = (Invoke-MgGraphRequest -Uri $uri -Method GET).Value
        foreach ($device in $managedDevices) {

            $deviceID = $device.id
            $json = @{
                "ownerType" = $OwnerType
            } | ConvertTo-Json
            $uri = "https://graph.microsoft.com/$graphApiVersion/$Resource('$deviceID')"

            Invoke-MgGraphRequest -Uri $uri -Method PATCH -Body $json -ContentType "application/json"

        }

    }
    catch {
        Write-Host "Error setting managed devices owner type: $($_.Exception.Message)" -f Red
    }

}

####################################################

# Connect to Microsoft Graph or Simple Connect-MgGrph
Connect-MgGraph -ClientId "" -TenantId "" -CertificateThumbprint ""

# Prompting for the desired Owner Type
$OwnerType = Read-Host -Prompt "Please specify Owner Type (personal or company)"

# Setting the Owner Type for all Managed Devices
Set-ManagedDevicesOwnerType -OwnerType $OwnerType
