xquery version "3.0";

import module namespace ediarum="http://www.bbaw.de/telota/software/ediarum/existdb";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare variable $current-version := "7";

(: URL Parameter :)
declare variable $url := request:get-url();
declare variable $index-id := request:get-parameter('index', ());
declare variable $project-name := substring-before(substring-after($url, "/projects/"), "/");
declare variable $action := request:get-parameter('action', 'get');
declare variable $first-letter := request:get-parameter('letter', ());
declare variable $order := request:get-parameter('order', ());
declare variable $show-details := tokenize(request:get-parameter('showDetails', ()), ',');
declare variable $show-version external := "1";

if (exists($index-id)) then (
    if (ediarum:get-index-type($project-name, $index-id) eq 'zotero') then
        let $zotero-connection-id := ediarum:get-zotero-connection-id-from-index-id($project-name, $index-id)
        return
        if ($action eq 'get') then (
            ediarum:get-zotero-index($project-name, $index-id)
        )
        else if ($action eq 'update') then (
            ediarum:update-zotero-connection($project-name, $zotero-connection-id)
        )
        else if ($action eq 'update-get') then (
            let $update := ediarum:update-zotero-connection($project-name, $zotero-connection-id)
            return
                ediarum:get-zotero-index($project-name, $index-id)
        )
        else ()
    else if (ediarum:get-index-type($project-name, $index-id) eq 'ediarum') then
        if ($action eq 'get') then (
           if ($order eq 'false') then
               ediarum:get-ediarum-index-unordered($project-name, $index-id, $first-letter, $show-details)
           else
                ediarum:get-ediarum-index($project-name, $index-id, $first-letter, $show-details)
        )
        else()
    else
        if ($action eq 'get') then (
            ediarum:get-project-index($project-name, $index-id)
        )
        else()
)
else if ($show-version instance of xs:string and $show-version eq 'show') then
    $current-version
else ()
