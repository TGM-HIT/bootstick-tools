# HIT Bootstick PowerShell Tools

## `format_only.ps1`

Formatiert alle angeschlossenen Bootsticks (optional als vollständige Formatierung mit dem Parameter `-Full`).


## `prepare_full.ps1`

Sichert, formatiert und initialisiert alle angeschlossenen Bootsticks.

(TODO: Einschränkung mit Parametern)

### Sicherung

Die angeschlossenen Sticks werden im Verzeichnis `Abgaben\_Datum_\_StickNummer` gesichert.

### Initialisierung

Das Verzeichnis `Abgabe` wird auf jedem Stick angelegt.

Datein aus dem Verzeichnis `Angaben\Angabe` werden auf jedem Stick ins Verzeichnis `Angabe` kopiert.

Dateien aus dem Verzeichnis `Angaben\Hilfe` werden auf jedem Stick ins Verzeichnis `Hilfe` kopiert.

Für alle Verzeichnisse im Ordner `Angaben\toISO` werden entsprechende `iso` Dateien im Verzeichnis `Angaben\isofiles` erstellt (sofern nicht bereits existent).

Dateien aus dem Verzeichnis `Angaben\isofiles` werden auf jedem Stick ins Verzeichnis `isofiles` kopiert. Zusätzlich wird die Datei `mount_isos.sh` auf jeden Stick kopiert, die sämtliche `iso` Dateien mountet.
