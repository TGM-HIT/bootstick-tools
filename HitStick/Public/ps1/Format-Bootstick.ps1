 <#
.SYNOPSIS

Formatiert ein gegebenes Win32_Volume neu (FAT32, behält das Volume Label)

.DESCRIPTION

.PARAMETER Volume

Das Win32_Volume welches neu formatiert werden soll.
Ein entsprechendes Objekt erhält man z.B. über den Befehl `Get-WMIObject Win32_Volume`.

.PARAMETER Full

Soll es eine vollständige Formatierung oder eine schnelle Formatierung sein.

.INPUTS

Keine - man kann nichts in Format-Bootstick pipen.

.OUTPUTS

Keine (?)

.EXAMPLE

```
$devices = Get-WMIObject Win32_Volume | Where-Object { $_.Label -like 'HIT*' } | Sort-Object -Property Label
for ($dev in $devices) {
    Format-Bootstick $dev #-Full
}
```

.LINK

https://learn.microsoft.com/en-us/powershell/module/storage/format-volume?view=windowsserver2022-ps

.LINK

https://learn.microsoft.com/en-us/previous-versions/windows/desktop/legacy/aa394515(v=vs.85)

.NOTES

#>
function Format-Bootstick {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $Volume,

        [switch]$Full
    )

    $Drive = $Volume.DriveLetter.TrimEnd(':')

    Log "USB-Stick $($Volume.Label) wird formatiert"

    if ($Full) {
        Format-Volume -DriveLetter $Drive -FileSystem fat32 -NewFileSystemLabel $Volume.Label -Full
    } else {
        Format-Volume -DriveLetter $Drive -FileSystem fat32 -NewFileSystemLabel $Volume.Label
    }
}