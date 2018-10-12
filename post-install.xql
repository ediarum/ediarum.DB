xquery version "3.1";

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
sm:chmod(xs:anyURI("/db/apps/ediarum/routinen/scheduler.xql"), "rwxr-sr-x"),
let $config := doc("setup/setup.xml")
let $file := file:read(config:get-existdb-jetty-config-path())
let $current-port := normalize-space(replace($file, '^.*?<SystemProperty name="jetty.port" default="(\d+)"/>.*?$', "$1", "s"))
let $file-ssl := file:read(config:get-existdb-jetty-ssl-config-path())
let $current-ssl-port := normalize-space(replace($file-ssl, '^.*?<SystemProperty name="jetty.ssl.port" deprecated="ssl.port" default="(8443)"/>.*?$', "$1", "s"))

return (
    update value doc("setup/setup.xml")/setup/property[@name="port"]/@value with $current-port,
    update value doc("setup/setup.xml")/setup/property[@name="sslPort"]/@value with $current-ssl-port
)
