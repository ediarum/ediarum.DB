xquery version "1.0";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace json="http://www.json.org";
(:import module namespace app="http://telota.bbaw.de/ediarum/templates" at "app.xql";:)

(: Switch to JSON serialization :)
declare option output:method "json";
declare option output:media-type "text/javascript";

(:~
 : Travers the sub collections of the specified root collection.
 :
 : @param $root the path of the root collection to process
 :)
declare function local:sub-collections($root as xs:string) {
    let $children := xmldb:get-child-collections($root)
    for $child in $children
    order by $child
    return
        if (xmldb:collection-available(concat($root, '/', $child))) then
            <children json:array="true">
    		{ local:collections(concat($root, '/', $child), $child) }
    		</children>
        else
            ()
};

declare function local:resources($root as xs:string) {
    let $resources := xmldb:get-child-resources($root)
    for $resource in $resources
    order by $resource
    return
(:      if (not(ends-with($resource,'.xql') or ends-with($resource,'.xquery')))
      then
:)        (<children json:array="true">
            <title>{$resource}</title>,
            <key>{$root}</key>
        </children>
        )
(:      else ():)
};

(:~
 : Generate metadata for a collection. Recursively process sub collections.
 :
 : @param $root the path to the collection to process
 : @param $label the label (name) to display for this collection
 :)
declare function local:collections($root as xs:string, $label as xs:string) {
    (
        <title>{$label}</title>,
        <isFolder json:literal="true">true</isFolder>,
        <key>{$root}</key>,
        local:sub-collections($root),
        local:resources($root)
    )
};


let $collection := request:get-parameter("root", "/db/data")
let $root-name := request:get-parameter("rootName", "data")
let $null := ""
return
    if (xmldb:collection-available($collection))
    then
    <collection json:array="true">
        {local:collections($collection, $root-name (:replace($collection, "^.*/([^/]+$)", "$1"):))}
    </collection>
    else
    <collection json:array="true">
    </collection>
