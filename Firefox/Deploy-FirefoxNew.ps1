<#
.SYNOPSIS
Questo script automatizza l'installazione o l'aggiornamento di Mozilla Firefox su dispositivi Windows.

.DESCRIPTION
Lo script gestisce la verifica dell'installazione esistente, l'installazione personalizzata di Firefox,
la configurazione delle politiche e la rinomina del file compatibility.ini per evitare problemi di compatibilità.
Supporta sia le versioni a 64 bit che quelle a 32 bit di Firefox.

.AUTHOR
Alessio Orpellini

.EMAIL
alessio.orpellini@gmail.com

.NOTES
Versione 1.0
Questa è la prima versione dello script per la distribuzione di Firefox. Personalizza i file di installazione e le politiche
in base alle esigenze della tua organizzazione prima di eseguire lo script.

#>

function Write-Log {
    param(
        [string]$Message,
        [string]$Path = "C:\enroll\deploy-log.txt",
        [string]$Severity = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp [$Severity] $Message"
    Add-Content -Path $Path -Value $logEntry
    Write-Host $logEntry
}

$Firefox64Path = "C:\Program Files\Mozilla Firefox\firefox.exe"
$Firefox32Path = "C:\Program Files (x86)\Mozilla Firefox\firefox.exe"
$FirefoxInstalled = $false
$FirefoxInstallPath = $null

# Verifica dell'installazione di Firefox
if (Test-Path $Firefox64Path) {
    $FirefoxInstalled = $true
    $FirefoxArch = "x64"
    $FirefoxInstallPath = "C:\Program Files\Mozilla Firefox"
    Write-Log -Message "Firefox 64-bit installation detected." -Severity "INFO"
} elseif (Test-Path $Firefox32Path) {
    $FirefoxInstalled = $true
    $FirefoxArch = "x86"
    $FirefoxInstallPath = "C:\Program Files (x86)\Mozilla Firefox"
    Write-Log -Message "Firefox 32-bit installation detected." -Severity "INFO"
} else {
    Write-Log -Message "Firefox is not installed." -Severity "ERROR"
    Exit
}

# Installazione personalizzata di Firefox basata sull'architettura rilevata
$installFilePath = Join-Path -Path $PSScriptRoot -ChildPath "Files\$FirefoxArch\FirefoxSetup.exe"
if (Test-Path -Path $installFilePath) {
    Start-Process -FilePath $installFilePath -ArgumentList "-ms" -Wait
    Write-Log -Message "Firefox ($FirefoxArch) installation initiated." -Severity "INFO"
} else {
    Write-Log -Message "Installation file not found: $installFilePath" -Severity "ERROR"
    Exit
}

# Attesa di 30 secondi post-installazione
Start-Sleep -Seconds 30

# Riconferma il percorso di installazione di Firefox
if (Test-Path $Firefox64Path) {
    $FirefoxInstallPath = "C:\Program Files\Mozilla Firefox"
} elseif (Test-Path $Firefox32Path) {
    $FirefoxInstallPath = "C:\Program Files (x86)\Mozilla Firefox"
} else {
    Write-Log -Message "Firefox installation not found after waiting." -Severity "ERROR"
    Exit
}

# Creazione della cartella distribution e copia di policies.json
$SupportFilesPath = Join-Path -Path $PSScriptRoot -ChildPath "SupportFiles"
$PoliciesSourcePath = Join-Path -Path $SupportFilesPath -ChildPath "policies.json"
$DistributionDir = Join-Path -Path $FirefoxInstallPath -ChildPath "distribution"

if (-not (Test-Path -Path $DistributionDir)) {
    New-Item -Path $DistributionDir -ItemType Directory | Out-Null
}

$PoliciesDestPath = Join-Path -Path $DistributionDir -ChildPath "policies.json"
Copy-Item -Path $PoliciesSourcePath -Destination $PoliciesDestPath -Force

Write-Log -Message "Policies.json has been copied to the Firefox distribution directory." -Severity "INFO"

# Ottieni l'elenco di tutti i profili utente
$UserDirs = Get-ChildItem -Path "C:\Users" -Directory

# Per ogni profilo utente, cerca e rinomina il file compatibility.ini in old-compatibility.ini
foreach ($UserDir in $UserDirs) {
    $FirefoxProfilesPath = Join-Path -Path $UserDir.FullName -ChildPath "AppData\Roaming\Mozilla\Firefox\Profiles"
    if (Test-Path -Path $FirefoxProfilesPath) {
        $ProfileDirs = Get-ChildItem -Path $FirefoxProfilesPath -Directory
        foreach ($ProfileDir in $ProfileDirs) {
            $CompatibilityIniPath = Join-Path -Path $ProfileDir.FullName -ChildPath "compatibility.ini"
            $NewPath = $CompatibilityIniPath -replace 'compatibility.ini', 'old-compatibility.ini'
            if (Test-Path -Path $CompatibilityIniPath) {
                if (Test-Path -Path $NewPath) {
                    Remove-Item -Path $NewPath -Force # Rimuove il file esistente prima di rinominare
                }
                Rename-Item -Path $CompatibilityIniPath -NewName $NewPath -Force
                Write-Log -Message "Renamed $CompatibilityIniPath to $NewPath" -Severity "INFO"
            }
        }
    }
}
# Creazione del file di rilevamento dell'installazione per Intune
$DetectionFilePath = "C:\enroll\firefox115.8.0esr.txt"

# Controlla se la cartella esiste, altrimenti la crea
if (-not (Test-Path -Path "C:\enroll")) {
    New-Item -Path "C:\enroll" -ItemType Directory | Out-Null
}

# Crea il file di rilevamento
New-Item -Path $DetectionFilePath -ItemType File -Force | Out-Null
Write-Log -Message "Firefox installation detection file created: $DetectionFilePath" -Severity "INFO"
