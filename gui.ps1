Import-Module ./HitStick

$Script:backupPath = "$PSScriptRoot\Abgaben"
$Script:angabePath = "$PSScriptRoot\Angaben"

$date = Get-Date -Format "yyyyMMdd"


#Your XAML goes here :)
$inputXML = @"
<Window x:Class="Datenstick_Manager.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:Datenstick_Manager"
        mc:Ignorable="d"
        Title="Datenstick Manager" Height="450" Width="800">
    <Grid>
        <TextBox x:Name="backupPath" HorizontalAlignment="Left" Height="23" Margin="523,23,0,0" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="201"/>
        <Label Content="Backup-Pfad:" HorizontalAlignment="Left" Margin="429,19,0,0" VerticalAlignment="Top"/>
        <Button x:Name="selectBackupPath" Content="Verzeichnis auswählen" HorizontalAlignment="Left" Margin="429,60,0,0" VerticalAlignment="Top" Width="163"/>
        <Button x:Name="createBackup" Content="Backup erstellen" HorizontalAlignment="Left" Margin="597,60,0,0" VerticalAlignment="Top" Width="127"/>
        <ListView x:Name="stickList" HorizontalAlignment="Left" Height="399" Margin="10,10,0,0" VerticalAlignment="Top" Width="326">
            <ListView.View>
                <GridView>
                    <GridViewColumn/>
                </GridView>
            </ListView.View>
        </ListView>
        <Button x:Name="formatSticks" Content="Sticks Formatieren" HorizontalAlignment="Left" Margin="429,109,0,0" VerticalAlignment="Top" Width="163"/>
        <CheckBox x:Name="selectFullFormat" Content="Full Format" HorizontalAlignment="Left" Margin="621,112,0,0" VerticalAlignment="Top"/>
        <CheckBox x:Name="selectInit" Content="Initialisieren" HorizontalAlignment="Left" Margin="621,132,0,0" VerticalAlignment="Top"/>
        <CheckBox x:Name="selectIso" Content="ISO erstellen" HorizontalAlignment="Left" Margin="621,152,0,0" VerticalAlignment="Top"/>
        <TextBox x:Name="angabenPath" HorizontalAlignment="Left" Height="23" Margin="523,198,0,0" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="201"/>
        <Label Content="Angaben-Pfad:" HorizontalAlignment="Left" Margin="429,194,0,0" VerticalAlignment="Top"/>
        <Button x:Name="selectAngabenPath" Content="Verzeichnis auswählen" HorizontalAlignment="Left" Margin="429,235,0,0" VerticalAlignment="Top" Width="163"/>
        <Button x:Name="copyAngaben" Content="Angaben kopieren" HorizontalAlignment="Left" Margin="597,235,0,0" VerticalAlignment="Top" Width="127"/>
        <Button x:Name="ejectAll" Content="alle auswerfen" HorizontalAlignment="Left" Margin="429,281,0,0" VerticalAlignment="Top" Width="163"/>
        <Button x:Name="searchSticks" Content="Sticks suchen" HorizontalAlignment="Left" Margin="597,281,0,0" VerticalAlignment="Top" Width="127"/>
        <ProgressBar x:Name="progressBar" HorizontalAlignment="Left" Height="15" Margin="429,340,0,0" VerticalAlignment="Top" Width="295"/>
    </Grid>
</Window>
"@ 
 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
try{
    $Form=[Windows.Markup.XamlReader]::Load( $reader )
}
catch{
    Write-Warning "Unable to parse XML, with error: $($Error[0])`n Ensure that there are NO SelectionChanged or TextChanged properties in your textboxes (PowerShell cannot process them)"
    throw
}
 
#===========================================================================
# Load XAML Objects In PowerShell
#===========================================================================
  
$xaml.SelectNodes("//*[@Name]") | %{"trying item $($_.Name)";
    try {Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop}
    catch{throw}
    }
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}
 
Get-FormVariables
 
#===========================================================================
# Use this space to add code to the various form elements in your GUI
#===========================================================================
                                                                    
     
#Reference 
 
#Adding items to a dropdown/combo box
    #$vmpicklistView.items.Add([pscustomobject]@{'VMName'=($_).Name;Status=$_.Status;Other="Yes"})
     
#Setting the text of a text box to the current PC name    
    #$WPFtextBox.Text = $env:COMPUTERNAME
     
#Adding code to a button, so that when clicked, it pings a system
# $WPFbutton.Add_Click({ Test-connection -count 1 -ComputerName $WPFtextBox.Text
# })
#===========================================================================
# Shows the form
#===========================================================================
write-host "To show the form, run the following" -ForegroundColor Cyan
'$Form.ShowDialog() | out-null'


Function Update-StickList() {
    $WPFstickList.Items.Clear()
    $Script:devices = Get-BootstickList # | % {$WPFstickList.AddChild($_)}
    $Script:devices | % {$WPFstickList.AddChild($_.Label)}
}

Function Dismount-All() {
    foreach ($dev in $Script:devices){
        Dismount-Bootstick $dev
    }
}

Function Backup-Sticks {
    $WPFprogressBar.Minimum = 0
    $WPFprogressBar.Maximum = $Script:devices.Count
    $WPFprogressBar.Value = 0

    foreach ($dev in $Script:devices) {
        # Zielpfad in den gesichert werden soll
        $dst_path = "$Script:backupPath\$date\$($dev.Label)\"

        $src_path = $dev.DriveLetter + "\Abgabe"

        # Überprüfen, ob das Zielverzeichnis bereits existiert ...
        while (Test-Path -Path $dst_path) {
            $titleBar = "Fehler"
            $content = "ACHTUNG!!!: Das Verzeichnis $dst_path existiert bereits. Der USB-Stick $($dev.Label) kann nicht gesichert werden." + "`n" + "Entfernen Sie den betreffenden Ordner $($dev.Label) aus dem Zielverzeichnis oder brechen Sie den Vorgang hier ab."
            $Result = [System.Windows.Forms.MessageBox]::Show($content,$titleBar,1)
            if ($Result -eq "OK") {

            } else {
                $WPFprogressBar.Value = $WPFprogressBar.Maximum
                return
            }
        }

        # Zielverzeichnis anlegen
        mkdir $dst_path

        Copy-Data -SrcPath $src_path -DstPath $dst_path

        $WPFprogressBar.Value = $WPFprogressBar.Value + 1

        ## TODO File Check
    }

}


Update-StickList
$WPFbackupPath.Text = $Script:backupPath
$WPFangabenPath.Text = $Script:angabePath

$WPFsearchSticks.Add_Click({Update-StickList})
$WPFejectAll.Add_Click({
    Dismount-All
    Update-StickList
})
$WPFselectBackupPath.Add_Click({
    $FolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderDialog.SelectedPath = $Script:backupPath
    $FolderDialog.ShowDialog() | Out-Null
    $Script:backupPath = $FolderDialog.SelectedPath
    $WPFbackupPath.Text = $Script:backupPath
})
$WPFselectAngabenPath.Add_Click({
    $FolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $FolderDialog.SelectedPath = $Script:angabePath
    $FolderDialog.ShowDialog() | Out-Null
    $Script:angabePath = $FolderDialog.SelectedPath
    $WPFangabenPath.Text = $Script:angabePath
})
$WPFcreateBackup.Add_Click({Backup-Sticks})

#$WPFformatSticks.Add_Click({
#    write-host "formatting ..."
#    $titleBar = "Fehler"
#    $content = "ACHTUNG!!!: Das Verzeichnis .. existiert bereits. Der USB-Stick .. kann nicht gesichert werden." + "`n" + "Entfernen Sie den betreffenden Ordner ... aus dem Zielverzeichnis oder brechen Sie den Vorgang hier ab."
#    $Result = [System.Windows.Forms.MessageBox]::Show($content,$titleBar,1)
#    write-host $Result
#})

$Form.ShowDialog() | out-null