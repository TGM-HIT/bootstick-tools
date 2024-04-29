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

param (
    [switch]$NoBackup=$false,
    [string]$BackupOrdner="$PSScriptRoot\Abgaben",
    [switch]$BackupOnly=$false,

    [switch]$NoFormat=$false,
    [switch]$FormatOnly=$false,
    [switch]$FullFormat=$false,

    [switch]$NoInit=$false,
    [switch]$SkipISO=$false,
    [switch]$MakeISO=$false,
    [string]$AngabenOrdner="$PSScriptRoot\Angaben",

    [switch]$NoEject=$false
)

$doBackup = !$NoBackup
$doFormat = !$NoFormat -and !$BackupOnly
$doMkIso = $MakeISO -or !$SkipISO
$doInit = !$NoInit -and !$FormatOnly -and !$BackupOnly
$doEject = !$NoEject

Import-Module ./HitStick

$date = Get-Date -Format "yyyyMMdd"

$devices = Get-BootstickList

Write-Host "Folgende Laufwerke werden formatiert:"

# Alle gefundenen Laufwerke werden aufgelistet
foreach ($dev in $devices) {
    Write-Host "Laufwerk" $dev.DriveLetter "mit der Benennung" $dev.Label
}


# Ausführung des Scripts zur Abfrage, ob das Script jetzt ausgeführt werden soll oder ob man abbrechen will
Confirm-Execution


# Alle Bootsticks werden gesichert
if ($doBackup) {
    foreach ($dev in $devices) {
        # Zielpfad in den gesichert werden soll
        $dst_path = "$BackupOrdner\$date\$($dev.Label)\"

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
}


# Pro gefundenem Laufwerk wird fogende Schleife einmal ausgeführt
if ($doFormat) {
    foreach ($dev in $devices){
        Write-Host "USB-Stick $($dev.Label) wird formatiert"
        
        if ($FullFormat) {
            Format-Bootstick $dev -Full
        } else {
            Format-Bootstick $dev
        }
    }
}


## Überprüfen, ob ein ISO angelegt werden soll und ggf. im Angaben-Ordner erstellen
if ($doMkIso) {
    $toISOPath = "$AngabenOrdner\toISO"
    if (Test-Path -Path toISOPath) {
        $isoTargetFolder = "$AngabenOrdner\isofiles"
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
}


# Alle Bootsticks werden initialisiert
if ($doInit) {
    foreach ($dev in $devices) {
        mkdir "$($dev.DriveLetter)\Abgabe"

        ### Kopieren der Angabe
        $src_path = "$AngabenOrdner\Angabe\*"
        $dst_path = "$($dev.DriveLetter)\Angabe"

        # Überprüfen ob überhaupt etwas kopiert werden soll ...
        if (Test-Path -Path $src_path) {
            mkdir $dst_path

            Copy-Data -SrcPath $src_path -DstPath $dst_path

            ## TODO File Check    
        }

        ### Kopieren der Hilfe
        $src_path = "$AngabenOrdner\Hilfe\*"
        $dst_path = "$($dev.DriveLetter)\Hilfe"

        # Überprüfen ob überhaupt etwas kopiert werden soll ...
        if (Test-Path -Path $src_path) {
            mkdir $dst_path
        
            Copy-Data -SrcPath $src_path -DstPath $dst_path
        
            ## TODO File Check    
        }

        ### Kopieren der ISO Files
        $src_path =  "$AngabenOrdner\isofiles\*.iso"
        $dst_path = "$($dev.DriveLetter)\isofiles"

        # Überprüfen ob überhaupt etwas kopiert werden soll ...
        if ( (Get-ChildItem $srcPath).Count -gt 0 ) {
            mkdir $dst_path
            
            Copy-Data -SrcPath $src_path -DstPath $dst_path

            ## TODO File Check

            Copy-Item -Path "$PSScriptRoot\mount_isos.sh" -Destination "$($dev.DriveLetter)"
        }
    }
}


if ($doEject) {
    foreach ($dev in $devices){
        Dismount-Bootstick $dev
    }
}


Write-Host "Alle angeschlossenen USB-Sticks bearbeitet. Bitte Logfile unter $logfilepath auf Fehler überprüfen"
pause
