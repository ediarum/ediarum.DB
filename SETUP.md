# ediarum.DB: Setup und advanced configuration

## Database restoring

If the database is corrupt or should be reset, i.e. all data,
user accounts (incl. the *admin*) and installed apps can be deleted,
it is sufficient to stop exist-db and delete the separate data folder on the host.
You'll get an empty database on restart where you can re-install apps or re-import data.
It is strongly recommended to set a new admin password first.

## Scheduler

You can change various settings in the `conf.xml`, which is located in the eXist installation directory. Recurring routines can be set up under `<scheduler>`.
(see also [Scheduler Module](https://exist-db.org/exist/apps/doc/scheduler.xml) in the eXist documentation).
To do this, uncomment the line `<modules uri="http://exist-db.org/xquery/scheduler" class="org.exist.xquery.modules.scheduler.SchedulerModule" />`.
The settings for a four-hour incremental backup with daily full backup look something like this:

    <job type="system" name="backup"
        class="org.exist.storage.ConsistencyCheckTask"
        cron-trigger="0 0 0/4 * * ?">
            <parameter name="output" value="path/to/backup/directory"/>
            <parameter name="backup" value="yes"/>
            <parameter name="incremental" value="yes"/>
            <parameter name="incremental-check" value="no"/>
            <parameter name="max" value="6"/>
    </job>

The setup of a scheduler job to execute an XQuery in the database looks like this (parameters can be passed which are read in as external variables in XQuery):

    <job type="user" name="validation"
        xquery="/db/path/to/xquery.xql"
        cron-trigger="0 5 1 * * ?">
            <parameter name="username" value="username"/>
            <parameter name="password" value="pass"/>
    </job>

## Port configuration

To change the port of the database (see [Port conflicts](https://exist-db.org/exist/apps/doc/troubleshooting.xml#port-conflicts)),
edit `tools/jetty/etc/jetty.xml` in the eXist installation folder. Search for line

    <Set name="port"><SystemProperty name="jetty.port" default="8080"/></Set>

and reset the port number. The port 8443 for secure connections can be set in the same file by editing the two lines

    <Set name="confidentialPort"><SystemProperty name="jetty.port.ssl" default="8443"/></Set>

    <Set name="Port"><SystemProperty name="jetty.port.ssl" default="8443"/></Set>

## Collections and permissions

To ensure that the database is only accessible for logged in users, the authorisations of the individual
resources must be set correctly. eXist also allows reading permissions for guests
which is explicitly not desired here, especially for the project collections and the `data` directory there.

Access is only desired for registered users, so with respect to the [authorization scheme](https://exist-db.org/exist/apps/doc/security.xml#permissions).
of eXist there should be `-rwxrwx--- (group: PROJECT users)` permissions for all resources in the `/db/projects/PROJECT/data` collection.
The collection `data` and subcollections should be created with the permission `crwxrwx--- (owner: admin, group:PROJECT-user)`.
New users in the project are created with the `umask: 0007`, whereby files created by them automatically get the permission `rwxrwx---`.

When creating a new project, the project is created in the collection `/db/projects/PROJECTNAME`. The following collection structure is created:

* `data`: Contains the research data. The necessary register resources are stored in the `data/Register` collection.
* `druck` (print): Necessary resources can be stored here to start the printing process on the server.
* `exist`: Contains the routines (`exist/routines`) that can be executed by the database.
* `oxygen`: Contains the interfaces which are necessary for Oxygen XML Author to access the database. Especially for reading the current registers.
* `web`: Necessary resources (XQuery scripts, CSS, etc.) for a web presentation can be stored here.

The following table gives an overview of the permissions in the collections of an ediarum project:

| Directory / User Group     | /data | /exist | /oxygen | /website | Describtion |
| -------------------------- | ----- | ------ | ------- | -------- | ------------ |
| admin                      | yes   | yes    | yes     | yes      | admininistrator with all permissions |
| PROJECT-user               | yes   |        |         |          | user in an ediarum project |
| exist-bot                  | yes   | yes    | yes     | yes      | executes the routines |
| oxygen-bot                 |       |        | yes     |          | for oXygen in global options and CSS, reads the register APIs. |
| website-user               |       |        |         | yes      | has access to website and print directory |

## Routines and XQuery scripts

XQuery scripts are stored in the `exist/routines` collection. For testing purposes, the script `test.xql` already exists there.
Central functions are predefined in the **ediarum** module, which can be found in `modules/ediarum.xql` in the **ediarum.DB**-App.
They can be loaded into the current script via

    import module namespace ediarum="http://www.bbaw.de/telota/software/ediarum/ediarum-app" at "/db/apps/ediarum/modules/ediarum.xql";

If the script is to be executed with extended permissions, the permissions must be set accordingly.
(for example: rwxr-sr-x, with 'dba' as group).

## Triggers

For eXist-db different triggers can be set, which are executed at certain events,
for example when resources are created or changed in a certain collection (see [Trigger](https://exist-db.org/exist/apps/doc/triggers.xml)).

Triggers come in handy if you manage data in different resources, but also edit them collectively.
This is the case with registers where each register entry is saved in a separate file.
The different resources can be merged by a trigger with an XQuery and stored separately.
Another example are resources to which a read access should also exist when working on them.
These resources can be stored separately as well by a trigger and a corresponding XQuery script.

Triggers for the collection `/db/my/path` and its subdirectories can be set up by storing a `collection.xconf` under `/db/system/config/db/my/path`.
A XQuery may reference to this config file. This must belong to the trigger namespace and can define various actions
(see [xQuery functions](https://exist-db.org/exist/apps/doc/triggers.xml#D2.2.5.3)). The setup is illustrated in the following example.

**Example:**

Each register entry of a common register is stored in a seperate file.
After creating a register entry (i.e. a new resource in the Register collection), the permissions for this file should be reset.

A`collection.xconf` file is stored under `/db/system/config/db/projects/PROJECT/Register` with the following content:

    <collection xmlns="http://exist-db.org/collection-config/1.0">
        <triggers>
            <trigger class="org.exist.collections.triggers.XQueryTrigger">
                <parameter name="url" value="xmldb:exist://db/apps/ediarum/routinen/set-permissions-for-document.xql"/>
            </trigger>
        </triggers>
    </collection>

The `/db/apps/ediarum/routinen/set-permissions-for-document.xql` file belongs to
to the namespace trigger and defines a trigger that performs the desired action:

    xquery version "3.0";

    module namespace trigger="http://exist-db.org/xquery/trigger";

    declare namespace xmldb="http://exist-db.org/xquery/xmldb";
    declare namespace sm="http://exist-db.org/xquery/securitymanager";

    declare variable $local:group-name external;

    declare function trigger:after-create-document($uri as xs:anyURI) {
        let $chmod := sm:chmod($uri, "rwxrwx---")
        let $chgrp := sm:chgrp($uri, $local:group-name)
        return ()
     };

The XQueries to be executed must be accessible via the URL specified in the trigger, i.e. they must also be executable with guest privileges.
