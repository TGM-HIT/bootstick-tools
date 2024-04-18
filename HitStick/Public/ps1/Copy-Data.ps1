function Copy-Data {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$SrcPath,

        [Parameter(Mandatory)]
        [string]$DstPath
    )

    if ( ! (Test-Path -Path $DstPath) ) {
        mkdir $DstPath
    }

    Log "Kopiere $SrcPath nach $DstPath"
    Copy-Item $SrcPath -Destination $DstPath -Recurse -Force #-PassThru
}