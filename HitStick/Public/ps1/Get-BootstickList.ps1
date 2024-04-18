function Get-BootstickList {
    Get-WMIObject Win32_Volume | Where-Object { $_.Label -like 'HIT*' } | Sort-Object -Property Label
}