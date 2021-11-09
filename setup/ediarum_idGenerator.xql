xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace functx = "http://www.functx.com";

declare variable $url := request:get-url();
declare variable $project-name := substring-before(substring-after($url, "/projects/"), "/");

declare variable $doc-path := '/db/projects/'||$project-name||'/data';
declare variable $project-letter := doc('/db/projects/'||$project-name||'/config.xml')//id-namespace/text();

declare function local:get-new-id($path as xs:string, $project-char as xs:string){
    (: Neue ID zufällig generieren. :)
    let $new-id-ran := util:random(10000000)
    let $new-id-full := functx:pad-integer-to-length($new-id-ran, 7)
    let $new-id := concat($project-char, $new-id-full)
    return
        $new-id
};

declare function local:controll-ids-index($path as xs:string, $new-id as xs:string){
    (: Kontrolle, ob generierte ID schon im Projekt genutzt wird. :)
    if(collection($path)//id($new-id))
    then(local:controll-ids-index($doc-path, local:get-new-id($doc-path, $project-letter)))
    else(<new-id>{$new-id}</new-id>)
};

local:controll-ids-index($doc-path, local:get-new-id($doc-path, $project-letter))
