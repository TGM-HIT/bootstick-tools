function Initialize-Bootstick {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Volume
    )

    $AbgabeDst = $Volume.DriveLetter + "\Abgabe"
    $AngabeDst = $Volume.DriveLetter + "\Angabe\"
    $AngabeSrc = $PSScriptRoot + "\Angabe\*"

    mkdir $AngabeDst
    mkdir $AbgabeDst

    if (Test-Path -Path $AngabeSrc) {
        Copy-Data $AngabeSrc $AngabeDst
    }

    # Todo überprüfen ob alles kopiert wurde
}