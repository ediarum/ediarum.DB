xquery version "3.0";
import module namespace dbutil="http://exist-db.org/xquery/dbutil";

declare variable $project-path external;

declare function local:set-permission($uri as xs:string, $group as xs:string, $mode as xs:string) as xs:string {
    string-join(dbutil:scan(xs:anyURI($uri), function($collection, $resource) {
        if ($resource) then (
            sm:chgrp($resource, $group),
            sm:chmod($resource, $mode),
            "Updated: "||$resource
        )
        else (
            sm:chgrp($collection, $group),
            sm:chmod($collection, $mode),
            "Updated: "||$collection
        )
    }), '&#xA;')
};

let $druck := try {local:set-permission($project-path||"/druck", "website", "rwxrwx---")} catch * {"Couldn't set permissions of /web"}
let $exist := try {local:set-permission($project-path||"/exist", "dba", "rwxrwx---")} catch * {"Couldn't set permissions of /exist"}
let $oxygen := try {local:set-permission($project-path||"/oxygen", "oxygen", "rwsr-x---")} catch * {"Couldn't set permissions of /oxygen"}
let $web := try {local:set-permission($project-path||"/web", "website", "rwxrwx---")} catch * {"Couldn't set permissions of /web"}
let $config := try {
        let $resource := $project-path||"/config.xml"
        return (sm:chgrp($resource, "dba"), "Updated: "||$resource)
    } catch * {
        "Couldn't set group of /config.xml"
    }
let $webconfig := try {
        let $resource := $project-path||"/webconfig.xml"
        return (sm:chgrp($resource, "website"), "Updated: "||$resource)
    } catch * {
        "Couldn't set group of /webconfig.xml"
    }
let $controller := try {
        let $resource := $project-path||"/controller.xql"
        return (sm:chgrp($resource, "website"), sm:chmod($resource, "rwxr-xr-x"), "Updated: "||$resource)
    } catch * {
        "Couldn't set permissions of /controller.xql"
    }
let $scan := string-join(($druck,$exist,$oxygen,$web,$config,$webconfig,$controller),"&#xA;")
return $scan,
xmldb:reindex($project-path||"/data")
