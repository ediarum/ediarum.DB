ediarum.DB: Installation
========================

## exist-db

Für die Benutzung von ediarum wird eine eXist-db Installation benötigt. Die
letzte Version läßt sich [hier](https://github.com/eXist-db/exist) herunterladen. Vor der Installations müssen die [Installationsvoraussetzungen](https://exist-db.org/exist/apps/doc/quickstart.xml#system-requirements)
erfüllt sein. Die genauen Installationsschritte finden sich in der [Online-Dokumentation](https://exist-db.org/exist/apps/doc/quickstart.xml).

Auf Linux lässt sich eXist mit dem Befehl `java -jar eXist-{version}.jar -console` installieren. Als `target path` gibt man etwa den *vollständigen* Pfad zum Unterverzeichnis `/pfad/zu/exist_db` an und
als `data dir` den wieder *vollständigen* Unterordner `/pfad/zu/data`. Daraufhin wird man aufgefordert das Admin-Passwort zu setzen.
Die Voreinstellungen zum maximalen Speicher (1024 MB) und zum Cache (128 MB) kann man stehen lassen.

*Hinweis:* Bei Windows 10 kann es zu einem Problem kommen, wenn man den voreingestellten Speicher von 2048 MB stehen lässt. Es empfiehlt sich daher den Speicher bei der Installation auf 1024 MB herunterzusetzen. Auch kann es zu Problemen führen, wenn exist beim Start als Service installiert wird.

Die Datenbank läuft zunächst unter dem Standardport 8080, was aber auch angepasst werden kann (s. [Setup](#db-setup)).
Über die Konsole kann eXist-db gestartet werden, etwa mit dem Befehl:

    nohup bin/startup.sh $

Die Datenbank lässt sich nach dem Starten über den Browser unter
`server:port/exist` erreichen.

## ediarum.DB

In eine bestehende eXist-db-Installation kann die **ediarum.DB**-App über
den Package-Manager hinzugefügt werden. Dazu muss im Dashboard der aktuellen
eXist-Installation der Package-Manager aufgerufen werden. Mit Klick auf
das Symbol oben links wird das Fenster "Upload Packages" geöffnet. In
diesem Fenster muss die aktuelle *ediarum.xar* hinzugefügt werden.

Der eXist-Installation werden die Ressourcen der **ediarum.DB**-App hinzugefügt.
Dann wird automatisch das xQuery `pre-install.xql` aufgerufen und ausgeführt. Darin werden die Nutzergruppen "website" und
"oxygen" angelegt, ebenso die Standardnutzer "exist-bot", "oxygen-bot" und "website-user"
mit gleich lautenden Passwörtern.

Nachdem die App mit ihren Dateien installiert wurde, wird automatisch das xQuery
`post-install.xql` aufgerufen und ausgeführt.
Dort werden die Zugriffsberechtigungen auf die verschiedenen System-Ordner und
die dafür notwendigen Routinen eingerichtet.
