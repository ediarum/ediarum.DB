xquery version "3.0";

import module namespace dbutil="http://exist-db.org/xquery/dbutil";

declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace sm="http://exist-db.org/xquery/securitymanager";

declare variable $collection external; (: Etwa: /db/project/TEST/data :)
declare variable $mode external; (: Die Rechte: rwxrwx--- :)
declare variable $group-name external; (: Etwa: TEST-nutzer :)

try {
    let $scan := dbutil:scan-collections(xs:anyURI($collection), function($coll) {
        (: Rechte in allen Dateien in der jeweiligen Sub-Kollektion ändern :)
        dbutil:scan-resources(xs:anyURI($coll), function($res) {
            sm:chmod($res, $mode),
            sm:chgrp($res, $group-name)
        }),
        (: Rechte der jeweiligen Sub-Kollektion ändern :)
        sm:chmod($coll, $mode),
        sm:chgrp($coll, $group-name)

    })
    return
        <result>
            <type>success</type>
            <message>Rechte "{$mode}" wurden in "{$collection}" gesetzt.</message>
        </result>
} catch * {
    <span>Caught error {$err:code}: {$err:description}</span>
}
