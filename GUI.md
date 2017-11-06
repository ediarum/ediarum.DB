ediarum.DB: Benutzeroberfläche
==============================

## Nutzer-Navigation

### Projekt-Startseite

Hier gibt es einen Zugang zum `data`-Verzeichnis. Über die Schaltflächen können Ordner und Dateien angelegt und gelöscht werden. Die Dateien lassen sich bei Auswahl im Quelltext anzeigen.

### Register

Falls Register eingerichtet wurden, stehen sie hier zur Auswahl.
Mit der
Schaltfläche "Aktualisieren" kann das Register über die entsprechende zotero-Verbindung aktualisiert
werden.

Eine Liste aller Registereinträge wird im vorformatierten Format angezeigt. Die IDs der Einträge
(rechts) verlinken auf die zotero Datenbank. Einträge, bei denen Felder fehlen, die erwartet werden
– etwa Autorenangaben –, werden in gelb dargestellt.

## Projektkonfiguration

Das Menü *Projektkonfiguration* ist nur für Administratoren eines Projektes verfügbar.

### Benutzer

Es lassen hier einfach neue Benutzer einem Projekt hinzufügen.
Existiert der Benutzer bereits in der Datenbank, wird er dem Projekt hinzugefügt, ohne dass sein Passwort geändert wird.
Für Projektmitglieder lässt sich das Passwort neu vergeben. Auch können Projektmitglieder wieder aus dem Projekt entfernt werden.

### Synchronisation

Hierüber können Synchronisationen zwischen verschiedenen exist-Datenbanken eingerichtet werden. Dabei wird zwischen *Push-Synchronisation* und *Pull-Synchronisation* unterschieden.

<!-- TODO -->

### Scheduler

<!-- TODO -->

### Zotero

Die Register von ediarum lassen sich mit zotero-Bibliographien verbinden. Dazu müssen zunächst die
Verbindungen zu einer zotero-Gruppe hergestellt werden.

Für die Einrichtung einer neuen zotero-Verbindung "Neue Verbindung hinzufügen" werden verschiedene Angaben benötigt:

* *Bezeichnung:*
    Der Name unter dem die Verbindung im weiteren angezeigt werden soll.
* *Gruppen-ID:*
    Der Identifikator der zotero-Gruppe, bestehend aus einer Ziffernkette. Bei privaten zotero-Gruppen ist die ID direkt aus der URL ersichtlich, etwa: https://www.zotero.org/groups/00001.
    Bei öffentlichen Gruppen ist die ID schwieriger zu finden:
    1. Die Webpage der Gruppen-Bibliothek öffnen
    2. Den Link "Subscribe to this feed" links, unterhalb der Schlagwörter finden
    3. Die Nummer im Link zwischen `/groups/` und `/items/` ist die gesuchte ID
* *API Schlüssel:*
    Ein spezieller API-Schlüssel, damit die Gruppe über die API-Schnittstelle von zotero synchronisiert werden kann. Der Schlüssel besteht aus Ziffern, großen und kleinen Buchstaben.
    Die Schlüssel sind Nutzer gebunden. Um einen solchen Schlüssel zu erstellen muss daher folgend vorgegangen werden:
    1. Die Webpage der Einstellungen "settings" eines Benutzers öffnen, der Zugriff auf die zu einzurichtende zoterp-Gruppe besitzt
    2. Die Seite "feeds/API" öffnen und einen neuen Schlüssel erstellen
    3. Bei Erstellung des Schlüssels ist darauf zu achten, dass Lese-Zugriff auf die einzurichtende zotero-Gruppe erlaubt wird.
* *Bibliographie-Stil:*
    Eine optionale Angabe, die einen der publizierten Zotero-Bibliographie-Stile benennt. Die verschiedenen Stile finden sich im [Zotero Style Repository](https://www.zotero.org/styles/)

Für jede eingerichtete zotero-Gruppe stehen mehrere Aktionen zur Auswahl:
* *Update!:*
    Synchronisiert die geänderten oder neu hinzugekommenen Einträge seit der letzten Synchronisation
    bzw. des letzten Updates. Bevor ein Update durchgeführt werden kann, sollte die Verbindung einmal
    synchronisiert worden sein.
* *Synchronisieren!:*
    Löscht alle vorhandenen Einträge aus der Datenbank und lädt alle in zotero
    vorhandenen Einträge neu herunter. Dieser Vorgang benötigt etwa 2 Minuten für 1.000 Einträge.
* *Bearbeiten:*
    Die Einstellungen können geändert werden.
* *Löschen:*
    Die Verbindung wird gelöscht.

### Register

Hier werden die Schnittstellen für den Oxygen-Zugriff auf die Register eingerichtet.

#### Projekt-Register

Es lassen sich je nach Projekt eigene Register spezifizieren. Folgende Parameter müssen angegeben werden:
* *API-ID:*
    Für die API-ID sollte ein eindeutiger String aus Buchstaben und Ziffern ohne Sonderzeichen
    gewählt werden, da das Register mithilfe der API-ID über eine URI angesteuert werden kann.
* *Bezeichnung:*
    Die Bezeichnung des Registers
* *Registerordner / -datei:*
    Der Ordner oder die Datei, in welchen sich das Register befindet. Etwa: `Register/Personen.xml`.
* *Namespace:*
    Falls die XML-Dateien einen bestimmten Namespace besitzen, muss dieser hier angegeben werden, etwa: `tei:http://www.tei-c.org/ns/1.0`.
* *Node:*
    Die Angabe des Knoten (mit Namespace), in welchem sich ein einzelner Registereintrag befindet. Also etwa `tei:TEI` oder `tei:item`.
* *XML-ID:*
    Die Angabe, wo sich relativ zum Knoten die ID befindet, etwa: `@xml:id`.
* *Span:*
    Der XPath-Ausdruck, der angibt,  wie der Registereintrag angezeigt werden soll.

#### Zotero-Register

Für eingerichtete zotero-Verbindungen lassen sich einzelne Register konfigurieren. Um ein neues Register
einzurichten ("Neues Register hinzufügen") werden vier Angaben benötigt:
*  *API-ID:*
    Für die API-ID sollte ein eindeutiger String aus Buchstaben und Ziffern ohne Sonderzeichen
    gewählt werden, da das Register mithilfe der API-ID über eine URI angesteuert werden kann.
* *Bezeichnung:*
    Die Bezeichnung des Registers
* *Zotero-Verbindung:*
    ier kann zwischen den eingerichteten zotero-Verbindungen ausgewählt werden.
    Ist bisher keine Verbindung eingerichtet, sollte dies vorher getan werden.
* *Zotero-Ordner:*
    Ein Register kann entweder alle Einträge einer zotero-Gruppe umfassen, dann bleibt
    dieses Feld leer. Ein Register kann aber auch nur einen einzelnen Ordner einer zotero-Gruppe umfassen,
    dann sollte jener hier ausgewählt werden.

Für die eingerichteten Register stehen die Aktionen "Bearbeiten" und "Löschen" zur Verfügung. Weiterhin
wird zu jedem Register angezeigt, welche Zugriffe über die API bestehen:
* *GET:*
    Das Register wird im TEI-Format ausgeliefert.
* *UPDATE:* Das Register wird über die zotero-Verbindung auf die neueste Version aktualisiert.
* *UPDATE-GET:*
    Das Register wird zunächst aktualisiert und dann in der aktualisierten Form im TEI-Format ausgeliefert.

#### Ediarum Register

Die Standardregister von Ediarum können an dieser Stelle aktiviert werden.
Diese werden dabei je nach Auswahl entweder in einer Datei oder in nach Buchstaben getrennten Dateien angelegt.
Es gibt die Auswahl zwischen:
* Personenregister
* Ortsregister
* Sachbegriffe
* Körperschaftsregister
* Werkregister
* Briefregister:
    Hierfür gibt es keine eigene Registerdatei, sondern es werden alle Briefe im `data`-Verzeichnis einbezogen.
* Anmerkungsregister:
    Hierfür gibt es keine eigene Registerdatei, sondern es werden die Anmerkungen aus den Dokumenten im `data`-Verzeichnis einbezogen.

## Verwaltung

Nur den Administratoren der Datenbank steht das Menü *Verwaltung* zur Verfügung.

### Projekte

Hier wird eine Liste der Projekte angezeigt. Es lassen sich neue Projekte anlegen oder bestehende löschen.

### exist-db

Hier werden Informationen zur bestehenden eXist-db-Installation angezeigt, sowie zur aktuellen **ediarum.DB**-App.

### Scheduler

Hier kann der Status des **ediarum**-Schedulers eingesehen werden. Ist er nicht aktiviert, wird eine entsprechende Schaltfläche angezeigt.

Außerdem wird eine Liste des aktuellen `log`-Files der zuletzt gelaufenen Scheduler-Jobs angezeigt.

### Setup

Unter *Setup* lassen sich die Passwörter der geschützten Benutzer der Datenbank ändern (`admin`, `exist-bot`, `oxygen-bot`, `website-user`). Auch lassen sich die aktuellen Ports der Datenbank neu einstellen.

<!-- TODO: Projects Controller -->
