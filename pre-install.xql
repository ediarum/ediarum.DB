xquery version "1.0";

import module namespace xdb="http://exist-db.org/xquery/xmldb";

declare namespace sm="http://exist-db.org/xquery/securitymanager";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

declare function local:mkcol-recursive($collection, $components) {
    if (exists($components)) then
        let $newColl := concat($collection, "/", $components[1])
        return (
            xdb:create-collection($collection, $components[1]),
            local:mkcol-recursive($newColl, subsequence($components, 2))
        )
    else
        ()
};

(: Helper function to recursively create a collection hierarchy. :)
declare function local:mkcol($collection, $path) {
    local:mkcol-recursive($collection, tokenize($path, "/"))
};

(: store the collection configuration :)
local:mkcol("/db/system/config", $target),
xdb:store-files-from-pattern(concat("/system/config", $target), $dir, "*.xconf"),

(: Erstellt die Nutzergruppen. :)
if (not(sm:group-exists("oxygen"))) then sm:create-group("oxygen", "Zugang zum oxygen-Ordner") else (),
if (not(sm:group-exists("website"))) then sm:create-group("website", "Zugang zum web und druck-Ordner") else (),
(:if (not(sm:group-exists("ediarum"))) then sm:create-group("ediarum", "Zugang zu Routinen") else (),:)

(: Erstellt die Standardnutzer. :)
if (not(sm:user-exists("exist-bot"))) then sm:create-account("exist-bot", "exist-bot", "ediarum", ("dba"), "exist-bot","führt die Routinen aus") else (),
if (not(sm:user-exists("oxygen-bot"))) then sm:create-account("oxygen-bot", "oxygen-bot", "oxygen", "", "oxygen-bot","für den Zugriff von Oxygen auf die Schnittstellen") else (),
if (not(sm:user-exists("website-user"))) then sm:create-account("website-user", "website-user", "website", "", "website-user","mit Zugriff auf die Webseite") else ()
