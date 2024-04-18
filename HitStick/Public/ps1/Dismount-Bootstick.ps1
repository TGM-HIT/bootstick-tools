function Dismount-Bootstick {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Volume
    )
    
    Log "USB-Stick $($Volume.Label) wird ausgeworfen"

    $Eject = New-Object -comObject Shell.Application
    $Eject.NameSpace(17).ParseName($Volume.DriveLetter).InvokeVerb("Eject")
}