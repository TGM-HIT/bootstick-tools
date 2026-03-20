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





#Einlesen der Laufwerke die mit "HIT" beginnen
$devices = Get-WMIObject Win32_Volume | ? { $_.Label -like 'HIT*' }

$date = Get-Date -Format "yyyyMMdd"

Write-Host "Folgende Laufwerke werden gesichert und anschließend zurückgesetzt:"

# Alle gefundenen Laufwerke werden aufgelistet
Foreach ($dev in $devices){ Write-Host "Laufwerk" $dev.DriveLetter "mit der Benennung" $dev.Label }

# Funktion zur Abfrage, ob das Script jetzt ausgeführt werden soll oder ob man abbrechen will
function ContinueExecution {
    $input = read-host "Wollen Sie Fortfahren (j/n)"

    switch ($input) `
    {
        'j' {
            write-host 'Script wird fortgesetzt'
        }

        'n' {
            write-host 'Script wird abgebrochen'
            exit
        }

        default {
            write-host 'Bitte tippen Sie j oder n um fortzufahren'
            Get-SomeInput
        }
    }
}

# Ausführung des Scripts zur Abfrage, ob das Script jetzt ausgeführt werden soll oder ob man abbrechen will
ContinueExecution



# Logfile anlegen
$logfilename = "Log_" + $date  + ".txt"
$logfile = $PSScriptRoot + "\Abgaben\" + $date +"\" + $logfilename
$logfilepath = $PSScriptRoot + "\Abgaben\" + $date
$logfileexists = Test-Path -Path $logfile

#Überprüfen ob das Logfile bereits existiert
if ($logfileexists){
    Write-Host "Logfile bereits vorhanden"
    }
    else{
    Write-Host "Logfile wird angelegt"
    mkdir $logfilepath
    $logfile | Out-File $logfile
    }


#Pro gefundenem Laufwerk wird fogende Schleife einmal ausgeführt
Foreach ($dev in $devices){

    # Speichern des Laufwerknamens (z.B. HIT A01) um  den Stick mit diesem Namen neu zu formatieren
    $Stick_Name = $dev.Label
    # Laufwerksbuchstaben auslesen
    $sourcepath = $dev.DriveLetter + "\*"
    # Zielpfad - Dort werden die ausgelesenen Abgaben geschrieben. Es wird im Unterordner "Abgaben" je Stick ein Ordner mit dem Namen des Sticks angelegt.
    # Stammpfad ist der Ordner, in welchem das Script ausgeführt wird
    #$destpath = $PSScriptRoot + "\Abgaben\" + $date +"\" + $dev.Label
    #Auslesen des Laufwerksbuchstabens (zum Formatieren notwendig)
    $Drive = $dev.DriveLetter.TrimEnd(':')


    "*************** USB-Stick " + $Stick_Name + " wird bearbeitet ***************" | Out-File $logfile -Append 


    # $abgabedest = $dev.DriveLetter + "\Abgabe"
	$abgabedest = $dev.DriveLetter + "\"
    # $angabedest = $dev.DriveLetter + "\Angabe\"
	# Nicht in das Verzeichnis Angabe schreiben
	# Fuer SEW auf \ schreiben
	$angabedest = $dev.DriveLetter + "\"
    $angebesrc = $PSScriptRoot + "\Angabe\*"

    # mkdir $angabedest
	# Muss nicht erstellt werden
    # mkdir $abgabedest



    $filestocopy = Test-Path -Path $angebesrc

 

    #if ($exit -eq 0){

        if ($filestocopy){
		Write-Host "Datenüberprüfung für USB-Stick " $Stick_Name "erfolgreich abgeschlossen, USB-Stick wird nun formatiert"
        "Datenüberprüfung für USB-Stick " + $Stick_Name + " erfolgreich abgeschlossen, USB-Stick wird nun formatiert" | Out-File $logfile -Append
        Format-Volume -DriveLetter $Drive -FileSystem fat32 -NewFileSystemLabel $dev.Label -Force 
		
		# Da Quick-Format für 64GB Sticks nicht unterstützt wird werden die 
		# Laufwerksbuchstaben des USB-Sticks anpassen (ohne Doppelpunkt)
		#$usbDriveLetter = $Drive

		#$usbRoot = "$usbDriveLetter`:\"
		
		# Alle Dateien und Ordner im Root und Unterordner löschen
		# Prüfen ob Daten (Files/Ordner) im Root vorhanden sind
		#	$hasData = Get-ChildItem -Path $usbRoot -Force | Select-Object -First 1
			
		#	if ($hasData) {
		#		Write-Host "Daten gefunden auf $usbRoot - lösche alles..."
		#		"Daten gefunden auf $usbRoot - lösche alles..." | Out-File $logfile -Append
		#		Get-ChildItem -Path $usbRoot -Recurse -Force | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
		#		Write-Host "✓ USB-Stick geleert."
		#	}
		#	else {
		#		Write-Host "USB-Stick $usbRoot ist bereits leer."
		#	}
		
		
		
         "Daten in " + $angebesrc + " gefunden. Die Daten werden nun auf den USB-Stick " + $Stick_Name + "kopiert." | Out-File $logfile -Append
         Write-Host "Daten in " + $angebesrc + " gefunden. Die Daten werden nun auf den USB-Stick " + $Stick_Name + "kopiert."

         Copy-Item $angebesrc -Recurse -Destination $angabedest


        $files_src = Get-ChildItem $angebesrc -Recurse
        $files_dest = Get-ChildItem $angabedest -Recurse
        $found_file = 0
        $allfiles_src_length = 0
        $allfiles_dest_length = 0
        $exit = 0

        ForEach ($file_src in $files_src) {


        ForEach ($file_dest in $files_dest) {

            if ($file_src.Name -eq $file_dest.Name){

                Write-Host "Datei"  $file_dest.Name  "gefunden"
                "Datei " + $file_dest.Name + " gefunden" | Out-File $logfile -Append
                $found_file = 1
                $allfiles_dest_length += $file_dest.Length

            }    
        }

        if ($found_file -eq 0){
        Write-Host "###Error###: Datei"  $file_dest.Name  "wurde nicht gefunden"
        "###Error###: Datei " + $file_dest.Name + " wurde nicht im Zielverzeichnis " + $angabedest + " gefunden"| Out-File $logfile -Append
        $exit = 1

        }
        $found_file = 0

        $allfiles_src_length += $file_src.Length 


        }

        if ($allfiles_src_length -ne $allfiles_dest_length){

    
            $exit = 2
            Write-Host "Dateigröße stimmt nicht überein"
            "###Error###: Die Größer aller Dateien am Ziel stimmt nicht mit der Größe aller Dateien am USB-Stick überein"| Out-File $logfile -Append
            "Datenübertragung zu USB-Stick " + $Stick_Name + " war NICHT erfolgreich!" | Out-File $logfile -Append
            }



        if($exit -eq 0){

            Write-Host "Datenüberprüfung für USB-Stick " $Stick_Name " erfolgreich abgeschlossen, alle Daten wurden ins Angabeverzeichnis kopiert"
            "Datenüberprüfung für USB-Stick " + $Stick_Name + " erfolgreich abgeschlossen, alle Daten wurden ins Angabeverzeichnis kopiert" | Out-File $logfile -Append
            }
            elseif ($exit -eq 1){
                Write-Host "Error mindestens eine Datei wurde am Zielpfad nicht gefunden, Details finden Sie im Logfile"
                Write-Host "Datenübertragung zu USB-Stick " + $Stick_Name + " war NICHT erfolgreich!"
                pause 
            }
            elseif ($exit -eq 2){

                Write-Host "###Error###: Ziel- und Quelldateigrößen stimmen nicht überein, Details finden Sie im Logfile"
                Write-Host "Datenübertragung zu USB-Stick " + $Stick_Name + " war NICHT erfolgreich!"
                pause 
            }
            else {
                Write-Host "Unerwarteter Fehler aufgetreten"
                Write-Host "Datenübertragung zu USB-Stick " + $Stick_Name + " war NICHT erfolgreich!"
                pause 
        }



        #}
        #else {
        #Write-Host "Keine Daten im Angabelaufwerk " + $angebesrc + " gefunden. Es werden keine Daten auf den USB-Stick " $Stick_Name " kopiert" 
        #"Keine Daten im Angabelaufwerk " + $angebesrc + " gefunden. Es werden keine Daten auf den USB-Stick " + $Stick_Name + " kopiert"  | Out-File $logfile -Append
        #}
   

    }
    else {
    Write-Host "Aufgrund eines Fehlers beim Sichern des USB-Sticks werden keine neuen Daten auf den USB-Stick " $Stick_Name "  geschrieben"
    "Aufgrund eines Fehlers beim Sichern des USB-Sticks werden keine neuen Daten auf den USB-Stick " + $Stick_Name + "  geschrieben" | Out-File $logfile -Append
    }
    
    



}

Write-Host "Alle angeschlossenen USB-Sticks bearbeitet. Bitte Logfile unter" $logfilepath "auf Fehler überprüfen"
pause

#>