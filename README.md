# HIT Bootstick PowerShell Tools

## `gui.bat`

Startet `gui.ps1` mit Powershell (und hoffentlich korrekten Ausführungsberechtigungen)

## `gui.ps1`

Erstellt eine WinForms GUI für die Verwaltung der Datensticks.

*Derzeit nur _scan_, _backup_ und _eject_ implementiert*

## `format_only.ps1`

Formatiert alle angeschlossenen Bootsticks (optional als vollständige Formatierung mit dem Parameter `-Full`).


## `prepare_full.ps1`

Sichert, formatiert und initialisiert alle angeschlossenen Bootsticks.

Das Skript akzeptiert die folgenden Parameter:

* `NoBackup` es werden keine Sicherungen erstellt
* `BackupOrdner` der Ordner in dem die Sicherungen abgelegt werden sollen (dort im Unterordner `\Datum\StickNummer`)
* `BackupOnly` um nur ein Backup zu erstellen

* `NoFormat` wenn die Sticks nicht formatiert werden sollen
* `FormatOnly` wenn die Sticks nur formatiert (aber weder gesichert noch initialisiert) werden sollen
* `FullFormat` wenn eine volle Formatierung (statt einer schnellen Formatierung) durchgeführt werden soll

* `NoInit` wenn keine Dateien auf die Sticks kopiert werden sollen
* `SkipISO` um die Erstellung von ISO Dateien zu unterbinden
* `MakeISO` um die Erstellung von ISO Dateien zu erzwingen
* `AngabenOrdner` der Ordner in dem die zu kopierenden Dateien liegen, dort in den Verzeichnissen `Angabe`, `Hilfe`, `toISO` und `isofiles`. Default-Wert: `Angaben`

### Sicherung

Die angeschlossenen Sticks werden (sofern nicht über den Parameter `BackupOrdner` anders angegeben) im Verzeichnis `Abgaben\_Datum_\_StickNummer` gesichert.

### Initialisierung

Das Verzeichnis `Abgabe` wird auf jedem Stick angelegt.

Im Verzeichnis `Angaben` (kann durch den Parameter `AngabenOrdner` überschrieben werden) wird folgende Dateistruktur erwartet:

```
|- Angabe
|- Hilfe
|- isofiles
|- toISO
```

Dateien aus den Unterverzeichnissen `Angabe`, `Hilfe` und `isofiles` (sofern vorhanden) werden in die gleichnamigen Verzeichnisse auf allen Sticks kopiert (nur Dateien mit der Endung `.iso` im Unterverzeichnis `isofiles`). Falls Dateien aus dem Verzeichnis `isofiles` kopiert wurden, so wird auch das Skript `mount_isos.sh`auf jeden Stick kopiert (mit dem die entsprechenden Dateien gemountet werden können).

Für alle Verzeichnisse im Unterordner `toISO` werden entsprechende `iso` Dateien im Unterverzeichnis `isofiles` erstellt (sofern nicht bereits existent).
