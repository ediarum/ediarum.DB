# ediarum.DB: User Interface

## User Navigation

### Project Homepage

Here you have access to the `data` directory. Use the buttons to create or delete folders and files. Selected files can be displayed in the source code.

### "Register" (Indexes)

If registers have been set up, they can be selected here.
The "Update" button can be used to update the register via the corresponding zotero connection.

A list of all register entries is displayed in preformatted format. The IDs of the entries
(right) link to the zotero database. Entries where expected fields - such as author information -
are missing will be displayed in yellow.

## "Projektkonfiguration" (Project configuration)

The *Projektkonfiguration* menu is only available for administrators of a project.

### "Benutzer" (User management)

Here, new users can be added to a project (*Anlegen*).
If a user already exists in the database, she will be added to the project without changing the password.
For project members, the password can be reassigned (*Passwort ändern*). Project members can also be removed from the project (*Löschen*).

### "Synchronisation" (Synchronisation)

This can be used to set up synchronisation between different existing databases. A distinction is made between *push synchronisation* and *pull synchronisation*.

### Push synchronisation

This allows resources to be copied to another eXist database. The target folder will be deleted from the target database first!

The following information is required:

* *Bezeichnung (Description):*
    A name with which the synchronisation appears in the list and in the logs.
* *Quellen-Ordner (Source folder):*
    A path relative to the current project folder that refers to the folder to be copied.
* *Ziel-Server (REST-Schnittstelle) (Destination server (REST interface)):*
    The web address incl. path to the REST interface of the target database.
* *Ziel-Ordner (Destination folder):*
    An absolute specification of the folder to which the source folder is to be copied.
* *Benutzername (User name) and Passwort (password):*
    For logging into the target database.

Note: The user must have write permission for the parent folder of the target folder, because this folder will be deleted and newly created.

#### Pull synchronisation

This allows to copy resources from another eXist database into the current one. The target folder will be deleted first!

The following information is required:

* *Bezeichnung (Description):*
    A name with which the synchronization appears in the list and in the logs.
* *Ziel-Ordner (Destination folder):*
    A path relative to the current project directory to the folder into which the source folder is to be copied.
* *Ziel-Gruppe (Target group):*
    An indication of the group to which the copied resources are to be assigned.
* *Ziel-Berechtigung (Destination permission):*
    An indication of the permissions that the copied resources should have.
* *Quellen-Server (Source server) (WebDAV): *
    The web address incl. path to the WebDAV interface of the source database.
* *Quellen-Ordner (Source folder):*
    An absolute path that refers to the folder to be copied.
* *Benutzername (User name) and Passwort (password):*
    For logging into the source database.

### "Scheduler"

This can be used to create regular tasks. These are based on an **ediarum** scheduler task which is called regularly by the database.

The specifications for a task contain:

* *Name:*
    The name with which the task appears in the list and in the logs.
* *Period:*
    Various periods are available for selection after which the task is executed. The correct cron expression is displayed in the "Cron Expression" field. If "Manual input" is selected, the cron expression can be freely entered. More about cron expressions can be found at : <https://exist-db.org/exist/apps/doc/scheduler#D3.17.8>. Only entries with numbers and "*" are supported in the printout.
* *Type:*
    The values "ediarum routine" and "Project routine" are available for selection. The **ediarum** routines are predefined, project routines are scripts in the project subfolder "/exist/routinen/scheduler".
* *XQuery:*
    Depending on the type selection, different XQuery scripts are available here.
* *Parameter:*
    If the selected XQuery script lists external variables, these can be entered here.

### "Zotero"

The registers of **ediarum** can be connected with zotero bibliographies.
In order to do this, connections to a zotero group have to be set first.

Various parameters are required to set up a new zotero connection ("Neue Verbindung hinzufügen")

* *Bezeichnung (Name):*
    The name under which the connection is to be displayed.
* *Gruppen-ID (Group ID):*
    The identifier of the zotero group, consisting of a number chain. For private zotero groups the ID is directly visible from the URL, e.g.: <https://www.zotero.org/groups/00001>.
    For public groups the ID is more difficult to find:
    1. Open the webpage of the group library
    2. Find the link "Subscribe to this feed" on the left, below the keywords
    3. The number in the link between `/groups/` and `/items/` is the ID you are looking for
* *API Schlüssel (API key):*
    A special API key so that the group can be synchronized via the zotero API interface. The key consists of digits, upper and lower case letters.
    The keys are bound to users. In order to create such a key you have to proceed as follows:
    1. Open the "settings" web page of a user who has access to the zotero group
    2. Open the "feeds/API" page and create a new key
    3. When creating the key, make sure that read access to the zotero group is allowed.
* *Bibliographie-Stil (Citation style):*
    An optional specification that names one of the published Zotero bibliography styles. The different styles can be found in the [Zotero Style Repository](https://www.zotero.org/styles/)

Several actions are available for each zotero group:

* *Update!:*
    Synchronizes recently changed or added entries since the last synchronization or update.
    The connection should be synchronized once before updating it.
* *Synchronisieren! (Synchronize):*
    Deletes all existing entries from the database and re-downloads all entries from Zotero. This process takes about 2 minutes for 1,000 entries.
* *Bearbeiten (Edit):*
    The settings can be changed.
* *Löschen (Delete):*
    The connection will be deleted.

### "Register"

Sets up the interfaces for Oxygen access to the registers.

#### Project register

Depending on the project, own registers can be specified. The following parameters must be specified:

* *API-ID:*
    For the API ID, a unique string of letters and numbers without special characters should be used because the register can be accessed via a URI using the API ID.
* *Bezeichnung (Name):*
    The name of the register.
* *Registerordner / -datei (Collection / resource):*
    The folder or file in which the register is located. For example: `Register/Persons.xml`.
* *Namespace:*
    If the XML files have a specific namespace, this must be specified here, for example: `tei:http://www.tei-c.org/ns/1.0`.
* *Node:*
    The specification of the node (with namespace) in which a single register entry is located. For example `tei:TEI` or `tei:item`.
* *XML-ID:*
    The specification where the ID is located relative to the node, for example: `@xml:id`.
* *Span:*
    The XPath expression that specifies how the register entry is to be displayed.

#### Zotero register

Individual registers can be configured for existing zotero connections. To create a new register
("Hinzufügen") four parameters are required:

* *API-ID:*
    For the API-ID, a unique string of letters and numbers without special characters should be used
    because the register can be accessed via a URI using the API ID.
* *Bezeichnung (Name):*
    The name of the register.
* *Zotero-Verbindung (Connection):*
    You can select one of the configured zotero connections.
    If no connection has been set up so far, this should be done first.
* *Zotero-Ordner (Folder):*
    A register can either contain all entries of a zotero group, then this field remains empty. A register can only contain one single folder of a zotero group, then this folder should be selected.

The actions "Bearbeiten" (edit) and "Löschen" (delete) are available for the registers.
Additionally, the available API actions for each register are displayed:

* *GET:*
    The register is returned as TEI.
* *UPDATE:*
    The register is updated to the latest version via zotero.
* *UPDATE-GET:*
    The register is first updated and then output in the updated form in TEI format.

#### ediarum register

The default registers of **ediarum** can be activated here.
Depending on the selection, these registers are created either in one file or in files separated by letters.
There is a choice between:

* index of persons
* index of places
* index of subjects
* index of corporate bodies
* bibliography
* register of letters:
    There is no separate register file for this, but all letters in the `data` directory are included.
* register of comments:
    There is no separate register file for this, but the comments from the documents in the `data` directory are included.

### "Entwicklung" (Development)

On this page you can download a new developer directory.
This already contains the basic structure for the development of an oxygen framework and other tools, such as ANT scripts for the development.
**Note: This doesn't work stable with every exist-db. Further testing is required. Therefore, this function is deactivated in the code.**

You can also download the current `build.xml` with the ANT scripts. Thus the ANT scripts can be kept up-to-date in the development.

In addition, the page shows a list of variables that can be set in the `build.properties`, which is GIT public, and in the `project.properties`, which is only stored locally.  
It is recommended to set passwords and local paths only in the `project.properties`.

## "Verwaltung" (Administration)

Only the administrators of the database have access to the *Verwaltung* (administration) menu.

### "Projekte" (Projects)

A list of projects is displayed here. You can create new projects or delete existing ones.

### "exist-db"

Information about the existing eXist-db installation and the current **ediarum.DB** app.

### Database "Scheduler"

The status of the **ediarum** scheduler can be viewed here. If it is not activated, a corresponding button is displayed.

In addition, a list of the current `log` files of the last Scheduler jobs run is displayed.

### "Setup"

Change the passwords of the protected users of the database (`admin`, `exist-bot`, `oxygen-bot`, `website-user`). The current ports of the database can also be set.
A project controller can also be set up here, i.e. calls to the URL `/exist/projects` will be processed directly from `controller.xql` in the `/db/projects` directory.
