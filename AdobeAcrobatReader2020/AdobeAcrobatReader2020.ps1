<#
.SYNOPSIS
Script to automate the deployment of Adobe Acrobat Reader DC.

.DESCRIPTION
This PowerShell script automates the process of uninstalling previous versions of Adobe Acrobat Reader DC, installing a new version, applying updates, configuring registry settings, and confirming installation completion. It is intended for use with SCCM or Intune.

.AUTHOR
Alessio Orpellini
Your Email: alessio.orpellini@gmail.com
Your Web Address: https://github.com/DatacorpCloud/Intune

#>

 do {
    $adobeOpen = Get-Process -Name "Acrobat", "AcroRd32" -ErrorAction SilentlyContinue
    if ($adobeOpen) {
        Write-Host "Adobe Acrobat Reader DC è ancora in esecuzione. Attendo che sia chiuso per procedere."
        Start-Sleep -Seconds 60
    } else {
        Write-Host "Nessuna istanza di Adobe Acrobat Reader DC attiva. Proseguo con la disinstallazione."
    }
} while ($adobeOpen)

Write-Host "Inizio il processo di disinstallazione di tutte le versioni precedenti di Adobe Reader."
Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE 'Adobe Acrobat (64-bit)%'" | ForEach-Object {
    $_.Uninstall()
    Write-Host "Disinstallato: $($_.Name)"
}

# Attendi un momento per assicurare che tutte le disinstallazioni siano completate
Start-Sleep -Seconds 10


# Installa la nuova versione di Adobe Reader
$installerPath = "files\AcroRdr20202000130002_MUI.exe"
$arguments = "/sAll /rs /msi /norestart /quiet EULA_ACCEPT=YES"
Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait

# Attendi un momento per assicurare che l'installazione sia completata
Start-Sleep -Seconds 10

# Applica l'aggiornamento
$updatePath = "files\AcroRdr2020Upd2000530574_MUI.msp"
$updateArguments = "/qn /norestart"
Start-Process -FilePath "msiexec.exe" -ArgumentList "/p `"$updatePath`" $updateArguments" -Wait

# Aggiungi la chiave di registro per disattivare gli aggiornamenti automatici
$registryPath = "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\2020\FeatureLockDown"
$propertyName = "bUpdater"
$propertyType = "DWORD"
$propertyValue = 0

# Crea il percorso nel registro se non esiste
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}

# Imposta il valore della chiave di registro
New-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue -PropertyType $propertyType -Force

# Crea un file di testo per confermare la conclusione delle operazioni
$filePath = "C:\enroll\adobe2020.txt"
$content = "Installazione e configurazione di Adobe Reader 2020 completate."

# Crea la directory se non esiste
if (-not (Test-Path "C:\log")) {
    New-Item -Path "C:\log" -ItemType Directory
}

# Scrivi il contenuto nel file
$content | Out-File -FilePath $filePath
