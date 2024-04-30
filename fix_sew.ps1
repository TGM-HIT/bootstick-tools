#########################################################################################
##########														   ######################
########## Script zur Sicherung und Bespielung der HIT-Datensticks ######################
##########														   ######################
#########################################################################################
#
# V 2.0
# Markus Schabel
# 18.04.2023
#
#**************************************#
#
#Versionsverlauf:
#
# V1.0 Erstellung des Scripts
# V1.1 Kontrolle der Dateigröße hinzugefügt
# V2.0 Refactoring mit PS-Modul, ISO Files, ...
# V2.1 Datenstick-Erklärung wird noch hinzugefügt; inklusive .gitignore
#
#**************************************

Import-Module ./HitStick

$devices = Get-BootstickList

# Alle gefundenen Laufwerke werden aufgelistet
Foreach ($dev in $devices) {
    Write-Host "Laufwerk" $dev.DriveLetter "mit der Benennung" $dev.Label
}


# Ausführung des Scripts zur Abfrage, ob das Script jetzt ausgeführt werden soll oder ob man abbrechen will
Confirm-Execution


### Kopieren der Datenstick-Erklärung aus der Hilfe
$AngabenOrdner="$PSScriptRoot\Angaben"
$src_path = "$AngabenOrdner\Hilfe\Datenstick 2023_24.pdf"
$dst_path = "$($dev.DriveLetter)\Hilfe"

# Alle Bootsticks werden initialisiert
Foreach ($dev in $devices) {

    Remove-Item "$($dev.DriveLetter)\mount_isos.sh" -Recurse
    Copy-Item -Path "$PSScriptRoot\mount_isos.sh" -Destination "$($dev.DriveLetter)"
	# Auch das PDF zur Erklärung des Datensticks in Hilfe Kopieren
	Copy-Item -Path "$AngabenOrdner\Hilfe\Datenstick 2023_24.pdf" -Destination $dst_path
}

Start-Sleep -Seconds 5

Foreach ($dev in $devices){
    Dismount-Bootstick $dev
}


Write-Host "Alle angeschlossenen USB-Sticks bearbeitet. Bitte Logfile unter $logfilepath auf Fehler überprüfen"
pause
