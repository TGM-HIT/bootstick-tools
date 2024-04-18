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
#
#**************************************

Import-Module ./HitStick

$date = Get-Date -Format "yyyyMMdd"

$devices = Get-BootstickList

Write-Host "Folgende Laufwerke werden formatiert:"

# Alle gefundenen Laufwerke werden aufgelistet
Foreach ($dev in $devices) {
    Write-Host "Laufwerk" $dev.DriveLetter "mit der Benennung" $dev.Label
}


# Ausführung des Scripts zur Abfrage, ob das Script jetzt ausgeführt werden soll oder ob man abbrechen will
Confirm-Execution


# Alle Bootsticks werden gesichert
Foreach ($dev in $devices) {
    # Zielpfad in den gesichert werden soll
    $dst_path = "$PSScriptRoot\Abgaben\$date\$($dev.Label)\"

    $src_path = $dev.DriveLetter + "\Abgabe"

    # Überprüfen, ob das Zielverzeichnis bereits existiert ...
    while (Test-Path -Path $dst_path) {
        Write-Host "ACHTUNG!!!: Das Verzeichnis $dst_path existiert bereits. Der USB-Stick $($dev.Label) kann nicht gesichert werden." 
        Write-Host "Entfernen Sie den betreffenden Ordner$($dev.Label) aus dem Zielverzeichnis oder brechen Sie den Vorgang hier ab."
        Confirm-Execution
    }

    # Zielverzeichnis anlegen
    mkdir $dst_path

    Copy-Data -SrcPath $src_path -DstPath $dst_path

    ## TODO File Check
}


# Pro gefundenem Laufwerk wird fogende Schleife einmal ausgeführt
Foreach ($dev in $devices){
    Write-Host "USB-Stick $($dev.Label) wird formatiert"
    Format-Bootstick $dev #-Full
}


## Überprüfen, ob ein ISO angelegt werden soll und ggf. im Angabe-Ordner erstellen
$toISOPath = "$PSScriptRoot\Angabe\toISO"
if (Test-Path -Path toISOPath) {
    $isoTargetFolder = "$PSScriptRoot\Angabe\isofiles"
    if ( !(Test-Path -Path $isoTargetFolder) ) {
        mkdir $isoTargetFolder
    }

    $isoFolders = Get-ChildItem $toISOPath -Directory
    
    foreach ($isoFolder in $isoFolders) {
        $isoTargetFile = "$isoTargetFolder\$($isoFolder.Name).iso"

        # TODO Nicht auf Existenz prüfen, sondern auf Aktualität
        if ( !(Test-Path -Path $isoTargetFile) ) {
            New-IsoFile $isoFolder.FullName -Path "$isoTargetFile" -Title $isoFolder.Name
        }
    }
}


# Alle Bootsticks werden initialisiert
Foreach ($dev in $devices) {
    mkdir "$($dev.DriveLetter)\Abgabe"

    ### Kopieren der Angabe
    $src_path = "$PSScriptRoot\Angabe\Angabe\*"
    $dst_path = "$($dev.DriveLetter)\Angabe"

    # Überprüfen ob überhaupt etwas kopiert werden soll ...
    if (Test-Path -Path $src_path) {
        mkdir $dst_path

        Copy-Data -SrcPath $src_path -DstPath $dst_path

        ## TODO File Check    
    }

    ### Kopieren der Hilfe
    $src_path = "$PSScriptRoot\Angabe\Hilfe\*"
    $dst_path = "$($dev.DriveLetter)\Hilfe"

    # Überprüfen ob überhaupt etwas kopiert werden soll ...
    if (Test-Path -Path $src_path) {
        mkdir $dst_path
    
        Copy-Data -SrcPath $src_path -DstPath $dst_path
    
        ## TODO File Check    
    }

    ### Kopieren der ISO Files
    $src_path =  "$PSScriptRoot\Angabe\isofiles\*.iso"
    $dst_path = "$($dev.DriveLetter)\isofiles"

    # Überprüfen ob überhaupt etwas kopiert werden soll ...
    if ( (Get-ChildItem $srcPath).Count -gt 0 ) {
        mkdir $dst_path
        
        Copy-Data -SrcPath $src_path -DstPath $dst_path

        ## TODO File Check

        Copy-Data -SrcPath "$PSScriptRoot\mount_isos.sh" -DstPath "$($dev.DriveLetter)\mount_isos.sh"
    }
}


Foreach ($dev in $devices){
    Dismount-Bootstick $dev
}


Write-Host "Alle angeschlossenen USB-Sticks bearbeitet. Bitte Logfile unter $logfilepath auf Fehler überprüfen"
pause
