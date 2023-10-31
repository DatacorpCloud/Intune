<#
    .SYNOPSIS
        IntuneSetDeviceLimit

     .DESCRIPTION
        This script is designed to manage device enrollment configurations in Microsoft Intune using the Microsoft Graph API. The primary goal is to adjust the limit on the number of devices a single user can register in Intune. The script carries out the following operations:

    Establishes a connection to Microsoft Graph.
    Retrieves the current device enrollment configuration based on the type 'Limit'.
    Displays the retrieved configurations for verification.
    Updates the device registration limit for the selected configuration.
    Displays the updated configuration to confirm the changes.

Usage Scenarios:

    Using Application Credentials:
    The script can connect to Microsoft Graph using application-specific details: ClientId, TenantId, and CertificateThumbprint. This method is typically employed for automated tasks or when running scripts from server environments where user interaction is not feasible.

    Using User Credentials (Classic Approach):
    As an alternative to application credentials, the script can also connect using the classic approach, where the user provides their credentials directly. This method is beneficial when an individual administrator wants to execute the script and has the required permissions to make the changes.

Adjustable Limit:

The device registration limit is set in the script using the limit parameter. While the script currently sets this to 15, it can be adjusted according to specific organizational needs. Simply change the value associated with the limit key in the $params hashtable to your desired number.

Feel free to use this description as a guide or documentation for your script.


    .AUTHOR
        Alessio Orpellini

    .VERSION
        0.1.9

    .NOTES
        The script can be executed via GPO or distribution software.

    .CONTACT
        Email: alessio.orpellini@gmail.com
        GitHub: https://github.com/DatacorpCloud
    .CREDITS
        Special thanks to Attilio del Rio for his invaluable support during the development process.

    .EXAMPLE
        Powershell.exe -ExecutionPolicy Bypass .\IntuneSetDeviceLimit.ps1
#>

# Impostazione delle variabili per la connessione
$ClientId = "" # Inserisci il tuo ClientId qui
$TenantId = "" # Inserisci il tuo TenantId qui
$CertificateThumbprint = "" # Inserisci il tuo CertificateThumbprint qui

# Connessione a Microsoft Graph
# Utilizza il blocco seguente se vuoi connetterti tramite ClientId, TenantId e CertificateThumbprint
Connect-MgGraph -ClientId $ClientId -TenantId $TenantId -CertificateThumbprint $CertificateThumbprint

# Se preferisci utilizzare un altro metodo per connetterti, puoi commentare il blocco precedente e decommentare il blocco successivo.
# Connect-MgGraph

# Ottieni la configurazione di registrazione del dispositivo basata sul tipo 'Limit'
$configurations = Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -ExpandProperty "assignments" -Filter "deviceEnrollmentConfigurationType eq 'Limit'" 

# Stampa le informazioni per la verifica
$configurations | Format-Table -Property Id, DisplayName

# Supponendo che tu voglia modificare la prima configurazione nell'elenco
if ($configurations.Id) {
    $deviceEnrollmentConfigurationId = $configurations.Id
} else {
    Write-Host "Nessuna configurazione trovata"
    exit
}

# Stampa l'ID per la verifica
Write-Host "ID configurazione selezionato: $deviceEnrollmentConfigurationId"

# Aggiorna la configurazione di registrazione del dispositivo
$params = @{
	"@odata.type" = "#microsoft.graph.deviceEnrollmentLimitConfiguration"
	limit = 15
}
Update-MgBetaDeviceManagementDeviceEnrollmentConfiguration -DeviceEnrollmentConfigurationId $deviceEnrollmentConfigurationId -BodyParameter $params

# Ottieni di nuovo la configurazione di registrazione del dispositivo per confermare le modifiche
Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -DeviceEnrollmentConfigurationId $deviceEnrollmentConfigurationId -ExpandProperty "assignments" 
