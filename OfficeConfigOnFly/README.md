OfficeOnFly

OfficeOnFly is a simple script designed to install the Microsoft Office package. The script consists of a .ps1 file and an XML file. It can be particularly useful when there's no option to distribute a uniform Office configuration with the same set of applications, or when it's not feasible to install everything. This script checks for installed applications and if they are not present on the system, it autonomously adds them to the exclusions in the XML file. The body of the XML file can be retrieved from the Microsoft site https://config.office.com/deploymentsettings. It's sufficient not to include excluded apps for the script to function correctly. You can modify the XML file located in the folder with your own settings. The script was originally created for distributing the Microsoft Office Suite via Intune. This approach eliminates the need to divide workstations into groups based on installed apps. The operations are carried out autonomously by the script, installing only the applications already present in the system.

To use it on Intune, simply construct a folder comprising a Microsoft Office 365 setup, the OfficeOnFly.ps1 file, and a .bat file if desired. At this point, just create the intunewin file and upload the app.

Modify xml file for chose specicic version.
  <Add OfficeClientEdition="64" Channel="SemiAnnual" Version="16.0.16130.20868">
