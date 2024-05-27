Deploying Adobe Acrobat Reader DC
Summary

    Introduction
    Chapter 1: Checking Running Applications
    Chapter 2: Uninstalling Previous Versions
    Chapter 3: Installing the New Version
    Chapter 4: Applying Updates
    Chapter 5: Configuring Registry Settings
    Chapter 6: Creating the Installation Detection File
    Summary

Introduction

This document details the operations performed by the PowerShell script for deploying Adobe Acrobat Reader DC. It is used to automate the installation and configuration of Adobe Acrobat Reader DC in an enterprise environment. The various sections of the script and the main operations, including paths and real configurations used in the script, will be illustrated.
Chapter 1: Checking Running Applications
1.1 Checking Active Instances of Adobe Acrobat Reader DC

The script starts by checking if there are active instances of Adobe Acrobat Reader DC running. If found, it waits for all instances to close before proceeding with the uninstallation.
Technical Details:

    Process Check: Uses Get-Process to check if "Acrobat" or "AcroRd32" processes are running.
    Wait: If any process is active, the script waits for 60 seconds and checks again.

Example Code:

do {
    $adobeOpen = Get-Process -Name "Acrobat", "AcroRd32" -ErrorAction SilentlyContinue
    if ($adobeOpen) {
        Write-Host "Adobe Acrobat Reader DC is still running. Waiting for it to close before proceeding."
        Start-Sleep -Seconds 60
    } else {
        Write-Host "No active instances of Adobe Acrobat Reader DC. Proceeding with uninstallation."
    }
} while ($adobeOpen)

Chapter 2: Uninstalling Previous Versions
2.1 Removing Previous Versions of Adobe Reader

The script uninstalls all previous versions of Adobe Acrobat Reader DC installed on the system.
Technical Details:

    WMI Query: Uses Get-WmiObject to find all installations of Adobe Acrobat Reader DC (64-bit).
    Uninstallation: Calls the Uninstall() method to remove each found installation.

Example Code:

Write-Host "Starting the uninstallation process of all previous versions of Adobe Reader."
Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE 'Adobe Acrobat (64-bit)%'" | ForEach-Object {
    $_.Uninstall()
    Write-Host "Uninstalled: $($_.Name)"
}

# Wait a moment to ensure all uninstallations are complete
Start-Sleep -Seconds 10

Chapter 3: Installing the New Version
3.1 Installing Adobe Reader

The script installs the new version of Adobe Acrobat Reader DC using a specified executable file.
Technical Details:

    Installer Path: files\AcroRdr20202000130002_MUI.exe
    Installation Arguments: Uses options for a silent installation.

Example Code:

# Install the new version of Adobe Reader
$installerPath = "files\AcroRdr20202000130002_MUI.exe"
$arguments = "/sAll /rs /msi /norestart /quiet EULA_ACCEPT=YES"
Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait

# Wait a moment to ensure the installation is complete
Start-Sleep -Seconds 10

Chapter 4: Applying Updates
4.1 Applying an Update

The script applies an update to the new installation of Adobe Acrobat Reader DC.
Technical Details:

    Update File Path: files\AcroRdr2020Upd2000530574_MUI.msp
    Update Arguments: Uses msiexec to apply the update in silent mode.

Example Code:

# Apply the update
$updatePath = "files\AcroRdr2020Upd2000530574_MUI.msp"
$updateArguments = "/qn /norestart"
Start-Process -FilePath "msiexec.exe" -ArgumentList "/p `"$updatePath`" $updateArguments" -Wait

Chapter 5: Configuring Registry Settings
5.1 Disabling Automatic Updates

The script adds a registry key to disable automatic updates for Adobe Acrobat Reader DC.
Technical Details:

    Registry Path: HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\2020\FeatureLockDown
    Registry Property: Sets bUpdater to 0 to disable automatic updates.

Example Code:

# Add the registry key to disable automatic updates
$registryPath = "HKLM:\SOFTWARE\Policies\Adobe\Acrobat Reader\2020\FeatureLockDown"
$propertyName = "bUpdater"
$propertyType = "DWORD"
$propertyValue = 0

# Create the registry path if it does not exist
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}

# Set the registry property value
New-ItemProperty -Path $registryPath -Name $propertyName -Value $propertyValue -PropertyType $propertyType -Force

Chapter 6: Creating the Installation Detection File
6.1 Creating the Detection File

The script creates a text file to confirm the completion of the Adobe Acrobat Reader DC installation and configuration.
Technical Details:

    Detection File Path: C:\enroll\adobe2020.txt
    File Content: Message confirming the completed installation.

Example Code:

# Create a text file to confirm completion
$filePath = "C:\enroll\adobe2020.txt"
$content = "Installation and configuration of Adobe Reader 2020 completed."

# Create the directory if it does not exist
if (-not (Test-Path "C:\enroll")) {
    New-Item -Path "C:\enroll" -ItemType Directory
}

$content | Out-File -FilePath $filePath

Summary

This documentation details the operations performed by the PowerShell script for deploying Adobe Acrobat Reader DC. The sections covered include initial checks for running applications, uninstallation of previous versions, installation of the new version, application of updates, configuration of registry settings, and creation of the installation detection file.

The script ensures a consistent installation and configuration of Adobe Acrobat Reader DC across multiple devices, improving efficiency and reducing the need for manual intervention. Additionally, post-installation checks and configurations ensure that the runtime environment remains stable and secure.
