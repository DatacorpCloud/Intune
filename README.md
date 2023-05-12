Required:
# Installa modulo Posh-SSH e Package NuGet Transferetto
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Install-Module -Name Posh-SSH -Scope AllUsers -Force

Install-Module -Name Transferetto -AllowClobber -Force

# Fine Installazione Modulo 


This script is designed to perform device enrollment on Intune in a semi-automatic way. 
The script should be deployed via Device GPO and adds the current user to the administrators group. 

It guides the user through pre-configured steps to perform enrollment on Intune autonomously, reducing the chances of error and avoiding the need for manual intervention on each workstation to add users to the administrators group.

The script handles scenarios such as user change, no restart when requested, and incomplete Enroll screen, promptly re-proposing the correct phase from where to resume. It also includes a remote log collection part via FTP for monitoring the progress status without the need to contact the device directly.

Upon completion of the operation, the script removes all users that have been added to the administrators group to perform the Enroll activity. It also removes the tasks it uses and all the files it generates, leaving only the log files. 

However, users who already belonged to the administrators group before the script execution will not be removed.
