# CHANGELOG for ediarum.DB

**ediarum.DB** is part of the research software

**ediarum**  
*Digital working environment for scholarly editions*  
<http://www.bbaw.de/telota/software/ediarum>
by  
*Berlin-Brandenburgische Akademie der Wissenschaften*  
*TELOTA - The electronic life of the academy*

----------

## Version 3.2.4 of 2019-02-12

* BUGFIX: Make zotero collections for indexes available.
* BUGFIX: Build number in expath-pkg.xml and file name are now the same.

## Version 3.2.3 of 2019-02-04

* BUGFIX: Deactivate download function at developer project page because of performance issues.

## Version 3.2.2 of 2018-12-20

* Update links in documentation

## Version 3.2.1 of 2018-10-29

* BUGFIX: Synchronizing zotero collections without error

## Version 3.2.0 of 2018-09-26

* UPDATE: Update port configuration for new exist version
* UPDATE: Substitute empty() in function declarations with empty-sequence()
* Complete the documentation
* Remove unnecessary comments
* Tests running projects controller with dynamical request url instead of hardcoded path
* Replace for-loop-function with for (1 to )
* Substitute strings with variables
* Delete register trigger function
* Add security tests for the menus, all admin functions, for the routing, and all relevant functions. The functions are using the sm module. Different roles are "projekt-nutzer", "group-manager" and "dba".
* Add build target: xar without build number
* BUGFIX #10645: Fix zotero item array problem
* BUG: Show only available collections in data.html
* BUG: Update redirect path for login and logout
* Clean code in  xqueries, update .md, build.xml with docu target

## Version 3.1.0 of 2018-02-20

* Collection-Permission-Vergabe auch für Dateien durchsetzen
* FEATURE #9197: Update build.properties
* FEATURE #9197: Add development folder, generate and download actions
* FEATURE #9178: Add error report to synchronisation

## Version 3.0.2 of 2017-11-27

* UPDATE #9178: Change rest-path for push synchronisation

## Version 3.0.1 of 2017-11-07

* BUGFIX #9084: Remove trigger for web collection

## Version 3.0.0 of 2017-11-06

* UPDATE: update documentation
* UPDATE: Fix bugs
* Clean code
* UPDATE #9062: Add security for exist-bot
* Clean code
* FEATURE #5663: Update scheduler warning and job
* FEATURE #5663: Update select cron options
* FEATURE #5663: Update scheduler and synchronisation tasks and views
* FEATURE #5663: Add cron notation
* FEATURE #8749: Add zotero synch to scheduler
* Enlarge scheduler interval; remove unused routines
* FEATURE #5365: Add ediarum index functions
* FEATURE #5365: Add gui und refresh for index api
* FEATURE #5365: Add gui for ediarum indexes
* Update version number
* UPDATE #8399: Update some errors
* FEATURE #8399: Add function change-user-pass
* UPDATE #8399: Change synchronize resource path to project resource path
* UPDATE #8399: Add change mode for pull synchronisations, remove xconf for data and register
* UPDATE #8399: Update xquery version number
* UPDATE #8399: Update synchronisation progressbar; remove message bug; update paths for url-rewriting
* FEATURE #8399: Update json to xml functions and replace loop with array function
* FEATURE #8399: Add zotero style and change json-to-xml function
* FEATURE #5365: Add project index functions
* FEATURE #8181: Add umask 0007 for new users
* Remove bugs for existdb3.0
* FEATURE #6286: Add set_default_permissions.xql to project setup
* BUGFIX: Replace map with map() for existdb 3.0
* Add function code for copy elements with namespaces
* Add ediarum icon
* FEATURE #5663: Add functions add and remove scheduler-job
* FEATURE #5663: Oberfläche für Parameter ergänzen
* FEATURE #5663: Add html layout + jquery for scheduler management

## Version 2.2.0 of 2016-09-12

* Add release directory
* Add functions in build.xml
* FEATURE #6108: Update documentation for zotero feature
* FEATURE #6108: Add error handling for zotero synchronizing
* FEATURE #6108: Show in items.html indexes instead of zotero connections
* FEATURE #6108: Add API links to indexes page
* FEATURE #6108: Add oxygen API for zotero indexes
* FEATURE #6108: Add functions 'remove-index', 'remove-zotero-connection', change parameter connection-name to connection-id
* FEATURE #6108: Add function 'remove index'
* FEATURE #6108: Add synchronize function incl collections
* FEATURE #6108: Add ediarum zotero API for oxygen
* FEATURE #6108: Add update zotero function
* FEATURE #6108: Add zotero synchronisation in blocks
* FEATURE #6108: Change id format to zotero-XXX-XXX
* BUG #6108: Update add index function
* FEATURE #6108: Add configuration page for indexes
* FEATURE #6108: Add interface ediarum.xql, add display functions for zotero items
* FEATURE #6108: Display zotero items in app with fontawesome
* FEATURE #6108: Add config:trash function for better linter
* FEATURE #6108: Merge branch 'fix-zotero-synch' into t6108
* FEATURE #6108: Fix zotero synch, dc namespaces added
* FEATURE #6108: Restore progress bar
* FEATURE #6108: Restore working synch version
* FEATURE #6108: Update synch zotero function, add progress.xql
* FEATURE #6108: Change json export to xml
* FEATURE #6108: Add zotero synch function
* FEATURE #6108: Add zotero menu and synch button
* FEATURE #6108: Add external_data to project collection
* FEATURE #6108: Add setup for zotero connections

## Version 2.1.0 of 2016

* Fix function ediarum:bot-login
* Add function signatures in config.xqm
* FEATURE #6137: Notwendige Abhängigkeiten beim ändern von Passwörtern beachten
* FEATURE #6137: Passwörter für Standardnutzer änderbar machen
* FEATURE #6139: Port-Änderung ermöglichen

## Version 2.0.1.57 of 2016-05-09

* FEATURE #6138: Synchronisationsdatei mit config.xml verbinden
* UPDATE: Update exist instance path variables
* FEATURE: Add functions to config: and ediarum:
* UPDATE: Move config:send-authHTTP to ediarum:send-authHTTP
* FEATURE: Add setup for projects-controller
* BUGFIX: Remove scheduler time bug

## Version 2.0.1.45 of 2016-02-02

* FEATURE #5701: Add synchronisation scheduler
* UPDATE #5688: Update the synchronisation with correct http-headers
* FEATURE #5663: Add correct trigger setup
* FEATURE #5663: Add scheduler period configuration, correct permissions
* FEATURE #5663: Add scheduler setup for new projects
* FEATURE Add webconfig.xml for web configuration
* FEATURE #5422: Add group and permissions for pull synchronisation. Add edit function.

## Version 2.0.0.32 of 2016-01-15

* UPDATE #5468: Remove bugs of the push synchronisation

## Version 2.0.0.31 of 2016-01-14

* FEATURE #5468: Push and pull working with xquery
* FEATURE #5468: Add a usable pull synchronization without python
* FEATURE #5422: Add push synchronisation
* UPDATE: Resolve merge conflict in build.xml

## Version 2.0.0.16 of 2015-12-01

* UPDATE #5378: Clear up the ediarum app

## Version 2.0.0.8 of 2015-11-19

* UPDATE #5332: Update logout behaviour
* VERSION: Change version to 2.0.0.8
* UPDATE: Update navigation, add collection functions
* FEATURE #5332: Add user management and update project navigation
* UPDATE #5332: Update layout
* FEATURE #5332: Create project management in ediarum and update layout
* UPDATE #5332: Change bootstrap layout
* NEW:Add all ediarum files: v2.0.0.7
