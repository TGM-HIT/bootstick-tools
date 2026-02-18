# USB-Sticks ermitteln
$usbVolumes = Get-Volume | Where-Object {
    $_.DriveType -eq 'Removable' -and $_.DriveLetter
}

if (-not $usbVolumes) {
    Write-Host "Keine USB-Sticks gefunden."
    return
}

Write-Host "Gefundene USB-Sticks:"
$usbVolumes | Select-Object DriveLetter, FileSystemLabel, Size, SizeRemaining | Format-Table

# Maximal 40 Labels (DATEN a01 ... DATEN a40)
$maxCount = 40

# Startwert vom Benutzer abfragen (1-40)
do {
    $startInput = Read-Host "Bitte Startnummer (1-40) für die Benennung eingeben"
    [bool]$ok = [int]::TryParse($startInput, [ref]$null) -and
                ([int]$startInput -ge 1) -and
                ([int]$startInput -le $maxCount)

    if (-not $ok) {
        Write-Host "Ungültige Eingabe. Bitte eine Zahl zwischen 1 und $maxCount eingeben."
    }
} until ($ok)

$startNumber = [int]$startInput

# Zähler initialisieren mit Startwert
$counter = $startNumber

foreach ($vol in $usbVolumes) {
    if ($counter -gt $maxCount) {
        Write-Host "Die maximale Nummer $maxCount ist erreicht. Weitere Sticks werden nicht umbenannt."
        break
    }

    # Nummer mit führender Null (01..40)
    $num = "{0:00}" -f $counter  # oder: $counter.ToString("D2")[web:16]

    # Neues Label bauen
    $newLabel = "HIT e$num"

    Write-Host "Laufwerk $($vol.DriveLetter): wird umbenannt in '$newLabel'..."

    # Volume-Label setzen
    Set-Volume -DriveLetter $vol.DriveLetter -NewFileSystemLabel $newLabel

    $counter++
}

Write-Host "Fertig."
