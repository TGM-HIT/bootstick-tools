#########################################################################################
##########														   ######################
########## Script zur Sicherung und Bespielung der HIT-Datensticks ######################
##########														   ######################
#########################################################################################
#
#V 1.1
#Michael Weber
#21.03.2023
#
#**************************************#
#
#Versionsverlauf:
#
#V1.0 Erstellung des Scripts
#V1.1 Kontrolle der Dateigröße hinzugefügt
#
#**************************************

param (
    [switch]$Full
)

Import-Module ./HitStick

$devices = Get-BootstickList

Write-Host "Folgende Laufwerke werden formatiert:"

# Alle gefundenen Laufwerke werden aufgelistet
Foreach ($dev in $devices) {
    Write-Host "Laufwerk" $dev.DriveLetter "mit der Benennung" $dev.Label
}


# Ausführung des Scripts zur Abfrage, ob das Script jetzt ausgeführt werden soll oder ob man abbrechen will
Confirm-Execution


#Pro gefundenem Laufwerk wird fogende Schleife einmal ausgeführt
Foreach ($dev in $devices){
    Write-Host "USB-Stick $($dev.Label) wird formatiert"

    if ($Full) {
        Format-Bootstick $dev -Full
    } else {
        Format-Bootstick $dev
    }
}


Foreach ($dev in $devices){
    Dismount-Bootstick $dev
}


Write-Host "Alle angeschlossenen USB-Sticks bearbeitet. Bitte Logfile unter $logfilepath auf Fehler überprüfen"
pause
