# ediarum.DB: Installation

## exist-db

To use **ediarum** an eXist-db installation is required. The latest version can be downloaded [here](https://github.com/eXist-db/exist).
Please  note that [installation requirements](https://exist-db.org/exist/apps/doc/basic-installation#system-requirements) must be fulfilled.
A detailed installation guide can be found in the [online documentation](https://exist-db.org/exist/apps/doc/basic-installation).

On Linux eXist can be installed with the command `java -jar eXist-{version}.jar -console`.
`target path` is the *absolute* path to the subdirectory (e.g.`/path/to/exist_db`).
`data dir` is the *absolute* path to the subdirectory (e.g.`/path/to/data`).You will be asked to set the admin password.
You can leave the default settings for maximum memory (1024 MB) and cache (128 MB).

*Note:* With Windows 10 there may be a problem if you leave the default memory of 2048 MB. It is therefore recommended to reduce the memory to 1024 MB during installation.
It can also lead to problems if exist is installed as a *service* at startup.

The database initially runs under the standard port 8080, but this can be adjusted (see [Setup](#db-setup)).
eXist-db can be started via the console:

    nohup bin/startup.sh $

Once the DB is started, it can be accessed via browser under `http://server:port/exist`.

## ediarum.DB

With an existing eXist-db installation the **ediarum.DB** app can be accessed via
the package manager. To do this, run the package manager fom the eXist-dashboard.
Click the symbol at the top left to open "Upload Packages" dialog. Add your current *ediarum.xar*.

The resources of the **ediarum.DB** app are added to the eXist installation.
Then the xQuery `pre-install.xql` is automatically called and executed.
It creates the user groups "website" and "oxygen", as well as the standard users "exist-bot", "oxygen-bot" and "website-user" with identical passwords.

After the app has been installed `post-install.xql` is called and executed.
This sets up access permissions to the different system directories and necessary routines.
