xquery version "3.0";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace http = "http://expath.org/ns/http-client";

let $path := request:get-parameter('path','/db/data')
let $document := if (util:binary-doc-available($path)) then (
                    util:binary-to-string( util:binary-doc($path) )
                    )
                else
                     doc($path)
return
    $document
