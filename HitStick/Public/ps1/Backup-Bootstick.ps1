function Backup-Bootstick {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Volume,

        [switch]$Full
    )

    $StickName = $Volume.Label

    # Eventuell "\*" statt "\" notwendig (?)
    $SrcPath = $Volume.DriveLetter + "\"
    if (!$Full) {
        $SrcPath = $SrcPath + "Abgabe\"
    }
    $DstPath = "$PSScriptRoot\Abgaben\$date\$StickName"

    while (Test-Path -Path $DstPath){
        Write-Host "ACHTUNG!!!: Das Verzeichnis $DstPath existiert bereits. Der USB-Stick $StickName kann nicht gesichert werden." 
        Write-Host "Entfernen Sie den betreffenden Ordner $StickName aus dem Zielverzeichnis oder brechen Sie den Vorgang hier ab."
        ContinueExecution
    }

    Copy-Data $SrcPath $DstPath

    # Todo überprüfen ob alles kopiert wurde
}