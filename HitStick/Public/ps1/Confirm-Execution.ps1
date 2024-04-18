# Funktion zur Abfrage, ob das Script jetzt ausgeführt werden soll oder ob man abbrechen will
function Confirm-Execution {
    [CmdletBinding()]
    param()
    
    $usrinput = read-host "Wollen Sie Fortfahren (j/n)"

    switch ($usrinput) `
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