<#
    .SYNOPSIS
        OfficeOnFly

     .DESCRIPTION
        OfficeOnFly is a simple script designed to install the Microsoft Office package. 
        The script consists of a .ps1 file and an XML file. It can be particularly useful when there's no option to distribute a uniform Office configuration with the same set of applications, or when it's not feasible to install everything. 
        This script checks for installed applications and if they are not present on the system, it autonomously adds them to the exclusions in the XML file. 
        The body of the XML file can be retrieved from the Microsoft site https://config.office.com/deploymentsettings.
        It's sufficient not to include excluded apps for the script to function correctly. You can modify the XML file located in the folder with your own settings.
        Add other application to check in $apps variable for filter other app.
        The script was originally created for distributing the Microsoft Office Suite via Intune. 
        This approach eliminates the need to divide workstations into groups based on installed apps. 
        The operations are carried out autonomously by the script, installing only the applications already present in the system.
       
        To use it on Intune, simply construct a folder comprising a Microsoft Office 365 setup, the OfficeOnFly.ps1 file, and a .bat file if desired.
        At this point, just create the intunewin file and upload the app.


    .AUTHOR
        Attilio del Rio - Alessio Orpellini

    .VERSION
        0.4.3

    .NOTES
        The script can be executed via GPO or distribution software.

    .CONTACT
        Email: alessio.orpellini@gmail.com
        GitHub: https://github.com/DatacorpCloud
    .CREDITS
        Special thanks to Attilio del Rio for his invaluable support during the development process.

    .EXAMPLE
        Powershell.exe -ExecutionPolicy Bypass .\OfficeOnFly.ps1
#>
 
 # Define the lista delle applicazioni Office e i loro eseguibili
$apps = @{
    "Word"     = "WINWORD.EXE"
    "Excel"    = "EXCEL.EXE"
    "Access"   = "MSACCESS.EXE"
    "Outlook"  = "OUTLOOK.EXE"
    "Publisher" = "MSPUB.EXE"
    "PowerPoint" = "POWERPNT.EXE"
    "OneNote"  = "ONENOTE.EXE"
    "Visio"    = "VISIO.EXE"
    "Lync"     = "LYNC99.exe"
}

# Function to verify application presence with improved logging
function AppIsInstalled($executable) {
    $path1 = Test-Path "C:\Program Files (x86)\Microsoft Office\root\Office16\$executable"
    $path2 = Test-Path "C:\Program Files\Microsoft Office\root\Office16\$executable"

    if ($path1 -or $path2) {
        Write-Host "Application '$executable' found."
        return $true
    } else {
        Write-Warning "Application '$executable' not found."
        return $false
    }
}

# Check for at least one installed application
$anyAppInstalled = $false
foreach ($app in $apps.Values) {
    if (AppIsInstalled $app) {
        $anyAppInstalled = $true
        break
    }
}

# Handle no applications installed scenario
if (-not $anyAppInstalled) {
    $errorMessage = "Nessuna applicazione di Office è installata. Codice di errore 9999."
    $outputDir = "C:\enroll"
    $outputFile = Join-Path $outputDir "office.txt"

    # Create output directory if needed
    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir | Out-Null
    }

    # Write error message and log
    Set-Content -Path $outputFile -Value $errorMessage
    Write-Error $errorMessage
    exit 9999
}

# ### Dynamic Configuration based on Installed Applications

# Percorsi dei file XML
$inputXmlPath = $PSScriptRoot + "\Config.xml"  # Replace with the actual path
$outputXmlPath = $PSScriptRoot + "\ConfigOK.xml"  # Replace with the desired path

# Load the original XML content
[xml]$xmlContent = Get-Content -Path $inputXmlPath

# Get the Product node
$productNode = $xmlContent.Configuration.Add.Product

# Verify if the Product node exists
if ($productNode) {
    # Clear existing ExcludeApp nodes (optional, ensures a clean slate)
    $productNode.RemoveChildNodes("ExcludeApp")

    # Add ExcludeApp nodes for non-installed apps
    $apps.GetEnumerator() | ForEach-Object {
        if (-not (AppIsInstalled $_.Value)) {
            $excludeNode = $xmlContent.CreateElement("ExcludeApp")
            $excludeNode.SetAttribute("ID", $_.Key)
            $productNode.AppendChild($excludeNode)
        }
    }

    # Save the modified XML content to ConfigOK.xml
    $xmlContent.OuterXml | Set-Content -Path $outputXmlPath

    Write-Host "ConfigOK.xml generated successfully."
} else {
    Write-Error "Nodo Product non trovato!"
}

# Adjust the following paths if necessary
$setupExePath = ".\\OfficeSetup.exe"  # Replace with the actual path to setup.exe
$configFile = ".\\Config.xml"    # Replace with the correct path to Config.xml
$outputFile = ".\\ConfigOK.xml"  # Replace with the desired output path

# Verify if setup.exe exists
if (-not (Test-Path $setupExePath)) {
    Write-Error "setup.exe not found. Please check the path."
    exit 1
}

# Start the installer, log errors, and exit with appropriate code
try {
    Start-Process -FilePath $setupExePath -ArgumentList "/configure $outputFile" -Wait
    Write-Host "Office configuration completed successfully."
    exit 0
} catch {
    Write-Error "Error during setup.exe execution: $($_.Exception.Message)"
    exit 1
}



Start-Process .\OfficeSetup.exe -ArgumentList "/configure configok.xml" -Wait

# Verifica se il processo è terminato con successo
if ($process.ExitCode -eq 0) {
    # Scrivi un log in caso di successo
    $logDir = "C:\enroll"
    $logFile = Join-Path $logDir "Office-16.0.16130.20868.txt"
    $logMessage = "Configurazione di Office completata con successo."

    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir | Out-Null
    }

    Set-Content -Path $logFile -Value $logMessage
    exit 0  # Uscita con codice di successo
} else {
    Write-Error "Errore durante l'esecuzione di setup.exe. Codice di errore: $($process.ExitCode)"
    exit $process.ExitCode
}
