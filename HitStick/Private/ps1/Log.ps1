$date = Get-Date -Format "yyyyMMdd"

$workdir = 	[Environment]::CurrentDirectory
$logfilename = "Log_" + $date  + ".txt"
$logfilepath = $workdir + "\Abgaben\" + $date
$logfile = $logfilepath +"\" + $logfilename

if (! (Test-Path -Path $logfilepath) ) {
    mkdir $logfilepath
    Add-Content $logfile $date
}

function Log {

    param (
        [Parameter(Mandatory)][string]$msg
    )

    Write-Verbose -Message $msg
    Add-Content $logfile $msg
}