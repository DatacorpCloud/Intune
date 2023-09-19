UT 5.0
Required:
# Install module Posh-SSH e Package NuGet Transferetto
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name Posh-SSH -Scope AllUsers -Force
Install-Module -Name Transferetto -AllowClobber -Force
# End Install Module 

This script is designed to perform device enrollment on Intune in a semi-automatic way. 
The script should be deployed via Device GPO and adds the current user to the administrators group. 

It guides the user through pre-configured steps to perform enrollment on Intune autonomously, reducing the chances of error and avoiding the need for manual intervention on each workstation to add users to the administrators group.

The script handles scenarios such as user change, no restart when requested, and incomplete Enroll screen, promptly re-proposing the correct phase from where to resume. It also includes a remote log collection part via FTP for monitoring the progress status without the need to contact the device directly.

Upon completion of the operation, the script removes all users that have been added to the administrators group to perform the Enroll activity. It also removes the tasks it uses and all the files it generates, leaving only the log files. 

However, users who already belonged to the administrators group before the script execution will not be removed.

OfficeOnFly

OfficeOnFly is a simple script designed to install the Microsoft Office package. 
The script consists of a .ps1 file and an XML file. It can be particularly useful when there's no option to distribute a uniform Office configuration with the same set of applications, or when it's not feasible to install everything. 
This script checks for installed applications and if they are not present on the system, it autonomously adds them to the exclusions in the XML file. 
The body of the XML file can be retrieved from the Microsoft site https://config.office.com/deploymentsettings.
It's sufficient not to include excluded apps for the script to function correctly. You can modify the XML file located in the folder with your own settings.
The script was originally created for distributing the Microsoft Office Suite via Intune. 
This approach eliminates the need to divide workstations into groups based on installed apps. 
The operations are carried out autonomously by the script, installing only the applications already present in the system.
     
To use it on Intune, simply construct a folder comprising a Microsoft Office 365 setup, the OfficeOnFly.ps1 file, and a .bat file if desired.
At this point, just create the intunewin file and upload the app.
