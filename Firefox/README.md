Script di Distribuzione Firefox

Lo script Deploy-FirefoxNew.ps1 automatizza l'installazione o l'aggiornamento di Mozilla Firefox su dispositivi Windows, gestendo sia le versioni a 64 bit (x64) che quelle a 32 bit (x86). Ecco i passaggi chiave dello script:

    Verifica dell'Installazione Esistente: Lo script inizia verificando se Firefox è già installato sul dispositivo, controllando sia la directory standard per la versione a 64 bit (C:\Program Files\Mozilla Firefox) che quella per la versione a 32 bit (C:\Program Files (x86)\Mozilla Firefox). Registra l'esito della verifica in un file di log.

    Installazione Personalizzata di Firefox: Se l'installazione esistente è rilevata, lo script determina l'architettura (x64 o x86) e procede con l'installazione di Firefox utilizzando il file di setup corrispondente, rinominato per rispecchiare la versione e l'architettura (esempio: FirefoxSetup115.8.0esr.exe). Lo script cerca questo file nella cartella Files\$FirefoxArch relativa al percorso dello script stesso.
        Personalizzazione del File di Installazione: È possibile personalizzare l'installazione di Firefox per diverse architetture modificando o sostituendo i file di setup in Files\x64 o Files\x86, a seconda delle esigenze. Questi file devono essere rinominati correttamente per riflettere la versione di Firefox che si intende distribuire.

    Configurazione delle Politiche di Firefox: Dopo l'installazione, lo script crea una cartella distribution nel percorso di installazione di Firefox e vi copia il file policies.json dalla cartella SupportFiles relativa al percorso dello script. Questo file policies.json può essere personalizzato per definire varie politiche e impostazioni di Firefox prima della copia.
        Personalizzazione di policies.json: Gli amministratori possono modificare il file policies.json presente nella cartella SupportFiles dello script per adattare le configurazioni di Firefox alle esigenze specifiche dell'organizzazione prima di eseguire lo script.

    Rinomina del File compatibility.ini: Lo script cerca e rinomina compatibility.ini in old-compatibility.ini per ogni profilo utente di Firefox. Questa operazione è necessaria per evitare problemi di compatibilità qualora la versione installata sia inferiore a quella distribuita, una situazione rara ma possibile in alcuni scenari.

    Creazione del File di Rilevamento per Intune: Alla fine dello script, viene creato un file di testo (firefox115.8.0esr.txt) in C:\enroll per facilitare il rilevamento dell'installazione da parte di Microsoft Intune, indicando così il completamento dell'installazione o dell'aggiornamento di Firefox.

Questo script fornisce un metodo efficace e automatizzato per gestire l'installazione di Firefox, con opportunità di personalizzazione sia per l'installazione del software che per le politiche utente. Gli amministratori possono adattare facilmente lo script alle proprie esigenze, personalizzando i file di installazione e le configurazioni di Firefox prima della distribuzione.

Per l'Installazione Personalizzata di Firefox, inserire semplicemente i file di installazione per le versioni a 64 bit (x64) e a 32 bit (x86) nelle rispettive cartelle (Files\x64 e Files\x86) mantenendo il nome del file come FirefoxSetup.exe. Questo passaggio consente allo script di identificare e utilizzare automaticamente il file di setup corretto in base all'architettura del sistema su cui viene eseguito.
_________________________________________________________________________

Firefox Deployment Script

The Deploy-FirefoxNew.ps1 script automates the installation or update of Mozilla Firefox on Windows devices, managing both 64-bit (x64) and 32-bit (x86) versions. Here are the key steps of the script:

    Existing Installation Check: The script starts by checking if Firefox is already installed on the device, inspecting both the standard directory for the 64-bit version (C:\Program Files\Mozilla Firefox) and that for the 32-bit version (C:\Program Files (x86)\Mozilla Firefox). It logs the outcome of this check in a log file.

    Custom Firefox Installation: If an existing installation is detected, the script determines the architecture (x64 or x86) and proceeds with the installation of Firefox using the corresponding setup file, renamed to reflect the version and architecture (example: FirefoxSetup115.8.0esr.exe). The script looks for this file in the Files\$FirefoxArch folder relative to the script's path.
        Installation File Customization: It's possible to customize the Firefox installation for different architectures by modifying or replacing the setup files in Files\x64 or Files\x86, depending on needs. These files must be correctly renamed to reflect the Firefox version intended for distribution.

    Firefox Policies Configuration: After installation, the script creates a distribution folder in the Firefox installation path and copies the policies.json file from the SupportFiles folder relative to the script's location. This policies.json file can be customized to define various policies and settings for Firefox before the copy.
        Customizing policies.json: Administrators can modify the policies.json file located in the SupportFiles folder of the script to tailor Firefox configurations to the specific needs of the organization before running the script.

    Renaming the compatibility.ini File: The script searches for and renames compatibility.ini to old-compatibility.ini for every Firefox user profile. This operation is necessary to prevent compatibility issues if the installed version is lower than the distributed one, a rare but possible scenario in some cases.

    Creation of the Intune Detection File: At the end of the script, a text file (firefox115.8.0esr.txt) is created in C:\enroll to facilitate the detection of the installation by Microsoft Intune, thus indicating the completion of the Firefox installation or update.

This script provides an effective and automated method for managing the installation of Firefox, with opportunities for customization both for the software installation and for user policies. Administrators can easily adapt the script to their needs, customizing the installation files and Firefox configurations before distribution.

For Custom Firefox Installation, simply place the installation files for both 64-bit (x64) and 32-bit (x86) versions in their respective folders (Files\x64 and Files\x86), keeping the file name as FirefoxSetup.exe. This approach allows the script to automatically identify and use the correct setup file based on the architecture of the system it's running on.
