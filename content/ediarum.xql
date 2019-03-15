xquery version "3.0";

module namespace ediarum = "http://www.bbaw.de/telota/software/ediarum/existdb";
import module namespace config="http://www.bbaw.de/telota/software/ediarum/config" at "/db/apps/ediarum/modules/config.xqm";

declare function ediarum:get-zotero-index($project-name as xs:string, $index-id as xs:string) {
    config:get-zotero-index($project-name, $index-id)
};

declare function ediarum:update-zotero-connection($project-name as xs:string, $zotero-connection-id as xs:string) as item()* {
    config:update-zotero-connection-in-blocks($project-name, $zotero-connection-id)
};

declare function ediarum:get-zotero-connection-id-from-index-id($project-name as xs:string, $index-id as xs:string) as xs:string {
    let $index := config:get-indexes($project-name)/index[@id=$index-id]
    let $zotero-connection-id := $index/parameter[@name="connection-id"]/@value/string()
    return
        $zotero-connection-id
};

declare function ediarum:get-index-type($project-name as xs:string, $index-id as xs:string) as xs:string {
    let $index := config:get-indexes($project-name)/index[@id=$index-id]
    let $index-type := $index/@type/string()
    return
        $index-type
        (: fn:error( (), "index-type: "||$index-type||", project-name: "||$project-name||", index-id: "||$index-id) :)
};

declare function ediarum:get-project-index($project-name as xs:string, $index-id as xs:string) as node()? {
    config:get-project-index($project-name, $index-id)
};

declare function ediarum:get-ediarum-index($project-name as xs:string, $index-id as xs:string, $first-letter as xs:string?, $show-details as xs:string*) as node()? {
    config:get-ediarum-index($project-name, $index-id, $first-letter, $show-details)
};

declare function ediarum:get-ediarum-index-unordered($project-name as xs:string, $index-id as xs:string, $first-letter as xs:string?, $show-details as xs:string*) as node()? {
    config:get-ediarum-index-unordered($project-name, $index-id, $first-letter, $show-details)
};