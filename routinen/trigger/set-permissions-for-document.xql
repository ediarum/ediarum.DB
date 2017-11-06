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
