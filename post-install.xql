xquery version "1.0";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://www.bbaw.de/telota/software/ediarum/config" at "./modules/config.xqm";

declare namespace sm="http://exist-db.org/xquery/securitymanager";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

declare function local:write-to-filesystem($file-path, $directory) {
    let $file := util:binary-doc($file-path)
    return
    file:serialize-binary($file, $directory)
};

(: Das project-Verzeichnis wird angelegt. :)
xmldb:create-collection("/db", "projects"),
xmldb:create-collection("/db/system/config/db", "projects"),
sm:chmod(xs:anyURI("/db/apps/ediarum/routinen/scheduler.xql"), "rwxr-sr-x")

(: Die Dateien auf der lokalen Maschine werden eingerichtet :)
(: TODO: wird nicht mehr benötigt, da es eine alternative Synchronisation gibt. Diese hier ist allerdings schneller.
file:mkdir(concat($home, "/ediarum")),
local:write-to-filesystem(concat($target, "/local-files/ediarum.py"), concat($home, "/ediarum/ediarum.py")),
local:write-to-filesystem(concat($target, "/local-files/synch.py"), concat($home, "/ediarum/synch.py"))
 :)
