xquery version "3.1";

(:~
 : A set of helper functions to access the application context from
 : within a module.
 :)
module namespace config="http://www.bbaw.de/telota/software/ediarum/config";
import module namespace ediarum="http://www.bbaw.de/telota/software/ediarum/ediarum-app" at "./ediarum.xql";

declare namespace templates="http://exist-db.org/xquery/templates";
declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace expath="http://expath.org/ns/pkg";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace functx = "http://www.functx.com";
(: Für den Import von Zotero-Items :)
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace owl="http://www.w3.org/2002/07/owl#";

(: Determine the application root collection from the current module load path. :)
declare variable $config:app-root :=
    let $rawPath := system:get-module-load-path()
    let $modulePath :=
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    return
        substring-before($modulePath, "/modules");

declare variable $config:data-col := "/data";
declare variable $config:data-root := $config:app-root || $config:data-col;
declare variable $config:ediarum-path := "/exist/apps/ediarum";
declare variable $config:routines-col := "/routinen";
declare variable $config:scheduler-col := $config:routines-col||"/scheduler";
declare variable $config:ediarum-db-path := "/db/apps/ediarum";
declare variable $config:ediarum-db-routinen-scheduler-path := $config:ediarum-db-path||$config:scheduler-col;
declare variable $config:expath-descriptor := doc(concat($config:app-root, "/expath-pkg.xml"))/expath:package;
declare variable $config:local-ediarum-dir := "ediarum";
declare variable $config:projects-path := "/db/projects";
declare variable $config:exist-bot-name  := "exist-bot";
declare variable $config:protected-users := ("admin", $config:exist-bot-name, "oxygen-bot", "website-bot");
declare variable $config:repo-descriptor := doc(concat($config:app-root, "/repo.xml"))/repo:meta;
declare variable $config:zotero-base-url := "https://api.zotero.org";
declare variable $config:ediarum-index-api-path := "/setup/";
declare variable $config:project-index-api-path := "/oxygen/";
declare variable $config:ediarum-index-api-file := "ediarum.xql";
declare variable $config:user-group-suffix := "-nutzer";
declare variable $config:ediarum-config-path := "/setup/setup.xml";
declare variable $config:exist-conf-file := "conf.xml";
declare variable $config:exist-controller-config-file := "/webapp/WEB-INF/controller-config.xml";
declare variable $config:exist-jetty-config-file := "/tools/jetty/etc/jetty-http.xml";
declare variable $config:exist-jetty-ssl-config-file := "/tools/jetty/etc/jetty-ssl.xml";
declare variable $config:ediarum-indexes := [
        map {
            "id": "persons",
            "label": "Personenregister",
            "file": "Register/Personen.xml",
            "collection": "Register/Personen"
        },
        map {
            "id": "places",
            "label": "Ortsregister",
            "file": "Register/Orte.xml",
            "collection": "Register/Orte"
        },
        map {
            "id": "items",
            "label": "Sachbegriffe",
            "file": "Register/Sachbegriffe.xml",
            "collection": "Register/Sachbegriffe"
        },
        map {
            "id": "organisations",
            "label": "Körperschaftsregister",
            "file": "Register/Koerperschaften.xml",
            "collection": "Register/Koerperschaften"
        },
        map {
            "id": "bibliography",
            "label": "Werkregister",
            "file": "Register/Werke.xml",
            "collection": "Register/Werke"
        },
        map {
            "id": "letters",
            "label": "Briefregister",
            "active": "false"
        },
        map {
            "id": "comments",
            "label": "Anmerkungsregister",
            "active": "false"
        }];

declare function functx:escape-for-regex($arg as xs:string?) as xs:string {
    replace($arg, '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
};

declare function functx:substring-before-match($arg as xs:string?, $regex as xs:string) as xs:string {
    tokenize($arg,$regex)[1]
};

declare function functx:substring-after-match($arg as xs:string?, $regex as xs:string) as xs:string? {
    replace($arg,concat('^.*?',$regex),'')
};

declare function functx:substring-before-last ($arg as xs:string?, $delim as xs:string)  as xs:string {
    if (matches($arg, functx:escape-for-regex($delim)))
    then replace($arg,
        concat('^(.*)', functx:escape-for-regex($delim),'.*'),
        '$1')
    else ''
};

declare function functx:substring-after-last($arg as xs:string?, $delim as xs:string) as xs:string {
    replace ($arg,concat('^.*',functx:escape-for-regex($delim)),'')
};

declare function config:app-meta($node as node(), $model as map(*)) as element()* {
    <meta xmlns="http://www.w3.org/1999/xhtml" name="description" content="{$config:repo-descriptor/repo:description/text()}"/>,
    for $author in $config:repo-descriptor/repo:author
        return <meta xmlns="http://www.w3.org/1999/xhtml" name="creator" content="{$author/text()}"/>
};

declare %templates:wrap function config:app-title($node as node(), $model as map(*)) as text() {
    $config:expath-descriptor/expath:title/text()
};

declare %templates:wrap function config:app-version($node as node(), $model as map(*)) as xs:string {
    $config:expath-descriptor/@version/string()
};

(: Zum Durchreichen von Parametern. :)
declare function config:get-parameter($node as node(), $model as map(*), $param as text()) as xs:string* {
    request:get-parameter($param, '')
};

declare function config:copy($source-uri as xs:string, $target-uri as xs:string, $group as xs:string, $permissions as xs:string) as xs:boolean {
    let $source-collection := functx:substring-before-last($source-uri, "/")
    let $source-resource := functx:substring-after-last($source-uri, "/")
    let $target-collection := functx:substring-before-last($target-uri, "/")
    let $target-resource := functx:substring-after-last($target-uri, "/")
    return (
        not(false()=distinct-values((
            if (not(xmldb:collection-available($target-collection))) then (
                config:mkcol($target-collection, $group, $permissions)
            ) else (),
            xmldb:copy($source-collection, $target-collection, $source-resource),
            if ($source-resource eq $target-resource) then ()
            else xmldb:rename($target-collection, $source-resource, $target-resource),
            sm:chgrp(xs:anyURI($target-uri), $group),
            sm:chmod(xs:anyURI($target-uri), $permissions),
            true()
        )))
    )
};

declare function config:create-collection ($new-collection as xs:string, $owner as xs:string, $group-name as xs:string, $mode as xs:string) as xs:string* {
    if (collection($new-collection)) then ()
    else (
        let $parent-collection := config:substring-beforelast($new-collection, "/")
        return
            config:create-collection($parent-collection, $owner, $group-name, $mode),
        xmldb:create-collection('', $new-collection),
        sm:chown(xs:anyURI($new-collection), $owner),
        sm:chgrp(xs:anyURI($new-collection), $group-name),
        sm:chmod(xs:anyURI($new-collection), $mode)
    )
};

declare function config:do-synchronisation($synch-name as xs:string, $synch-type as xs:string) as node() {
    config:do-synchronisation($synch-name, $synch-type, ediarum:get-current-project())
};

declare function config:do-synchronisation($synch-name as xs:string, $synch-type as xs:string, $project-name as xs:string) as node() {
    if ($synch-type eq "push") then
        let $target := config:get-synchronisation-targets($project-name)//target[label=$synch-name][@type=$synch-type]
        let $source-collection := if (starts-with(string($target/source-resource),$config:projects-path||"/"||$project-name)) then (string($target/source-resource)) else ($config:projects-path||"/"||$project-name||"/"||string($target/source-resource))
        let $target-user := string($target/target-user)
        let $target-password := string($target/target-password)
        let $target-server := string($target/target-server)
        let $target-collection := string($target/target-resource)
        let $response := config:synchronisation-push-existdb-collections($source-collection, $target-server, $target-user, $target-password, $target-collection)
        return
        if ($response("error")) then
            <result>
                <type>danger</type>
                <message>
                    <p>Beim Ausführen des Prozesses "{$synch-name}" trat ein Fehler auf! <a role="button" data-toggle="collapse" href="#result" aria-expanded="false" aria-controls="collapseExample">Mehr..</a>
                    </p>
                    <div class="collapse" id="result">
                        <div class="well">
                            <pre>{serialize($response("result"))}</pre>
                        </div>
                    </div>
                </message>
            </result>
        else
            <result>
                <type>success</type>
                <message>
                    <p>Der Prozess "{$synch-name}" wurde ausgeführt! <a role="button" data-toggle="collapse" href="#result" aria-expanded="false" aria-controls="collapseExample">Mehr..</a>
                    </p>
                    <div class="collapse" id="result">
                        <div class="well">{$response("result")}</div>
                    </div>
                </message>
            </result>
            (: Alternative Ansätze zur Dokumenation:
                process:execute(("python","synch.py", $source-user, $source-pass, $source-server, $source-resource, $target-user, $target-pass, $target-server, $target-resource), $options)
            config:synchronize-existdb-resources($source-server, $source-user, $source-pass, $source-resource, $target-server, $target-user, $target-pass, $target-resource)
            :)
    else if ($synch-type eq "pull") then
        let $target := config:get-synchronisation-targets($project-name)//target[label=$synch-name][@type=$synch-type]
        return if (not(exists($target))) then
            <result>
                <type>danger</type>
                <message>
                    <p>{$synch-type}: {$synch-name} in {$project-name} existiert nicht!</p>
                </message>
            </result>
        else
        let $source-user := string($target/source-user)
        let $source-password := string($target/source-password)
        let $source-server := string($target/source-server)
        let $source-collection := string($target/source-resource)
        let $target-group-name := if (exists(string($target/target-group-name))) then (string($target/target-group-name)) else (sm:id()//sm:group[1]//string())
        let $target-mode := if (exists(string($target/target-mode))) then (string($target/target-mode)) else ("rwxrwx---")
        let $target-collection := if (starts-with(string($target/target-resource),$config:projects-path||"/"||$project-name)) then (string($target/target-resource)) else ($config:projects-path||"/"||$project-name||"/"||string($target/target-resource))

        let $response := config:synchronisation-pull-existdb-collections($source-server, $source-user, $source-password, $source-collection, $target-collection, $target-group-name, $target-mode)
        return
        if ($response("error")) then
            <result>
                <type>danger</type>
                <message>
                    <p>Beim Ausführen des Prozesses "{$synch-name}" trat ein Fehler auf! <a role="button" data-toggle="collapse" href="#result" aria-expanded="false" aria-controls="collapseExample">Mehr..</a>
                    </p>
                    <div class="collapse" id="result">
                        <div class="well">
                            <pre>{serialize($response("result"))}</pre>
                        </div>
                    </div>
                </message>
            </result>
        else
            <result>
                <type>success</type>
                <message>
                    <p>Der Prozess "{$synch-name}" wurde ausgeführt! <a role="button" data-toggle="collapse" href="#result" aria-expanded="false" aria-controls="collapseExample">Mehr..</a>
                    </p>
                    <div class="collapse" id="result">
                        <div class="well">{$response("result")}</div>
                    </div>
                </message>
            </result>
    else
        <result>
            <type>warning</type>
            <message>Der Prozess {$synch-name} ist nicht verfügbar!</message>
        </result>
};

(: Returns the expath-pkg.xml descriptor for the current application. :)
declare function config:expath-descriptor() as element(expath:package) {
    $config:expath-descriptor
};

declare function config:format-zotero-item($item as node()) as map(*) {
    let $key := $item/key/string()
    let $type := $item/itemType/string()
    let $title := $item/title/string()
    let $date := $item/date/string()
    let $url := $item/url/string()
    let $publisher := $item/publisher/string()
    let $place := $item/place/string()
    let $publication-title := $item/publicationTitle/string()
    let $volume := $item/volume/string()
    let $pages := $item/pages/string()
    let $blog-title := $item/blogTitle/string()
    let $book-title := $item/bookTitle/string()
    let $author :=
        if (count($item/creators/item[creatorType="author"]) > 3) then (
            $item/creators/item[creatorType="author"][1]/lastName||", "||$item/creators/item[creatorType="author"][1]/firstName||" et al."
        )
        else
            string-join(
                for $author at $pos in $item/creators/item[creatorType="author"]
                return
                    if ($pos eq 1) then
                        $author/lastName[1]||", "||$author/firstName[1]
                    else
                        $author/firstName[1]||" "||$author/lastName[1]
                , " / "
        )
    let $editor :=
        if (count($item/creators/item[creatorType="editor"]) > 3) then (
            $item/creators/item[creatorType="editor"][1]/lastName||", "||$item/creators/item[creatorType="editor"][1]/firstName||" et al."
        )
        else
            string-join(
                for $author at $pos in $item/creators/item[creatorType="editor"]
                return
                    if ($pos eq 1) then
                        $author/lastName[1]||", "||$author/firstName[1]
                    else
                        $author/firstName[1]||" "||$author/lastName[1]
                , " / "
        )
    let $author-empty := normalize-space(string-join($item/creators/item[creatorType="author"]//text(), "")) eq ""
    let $creator-empty := normalize-space(string-join($item/creators//text(), "")) eq ""
    let $missing-entries :=
        if($type eq "attachment") then (
            $title eq "" or $url eq ""
        )
        else if($type eq "blogPost") then (
            $creator-empty or $date eq "" or $title eq "" or $blog-title eq "" or $url eq ""
        )
        else if($type eq "book") then (
            $creator-empty or $date eq "" or $title eq "" or $publisher eq "" or $place eq ""
        )
        else if($type eq "bookSection") then (
            $creator-empty or $date eq "" or $title eq "" or $book-title eq "" or $publisher eq "" or $place eq "" or $pages eq ""
        )
        else if($type eq "journalArticle") then (
            $creator-empty or $title eq "" or $date eq "" or $publication-title eq "" or $volume eq "" or $pages eq ""
        )
        else if($type eq "webpage") then (
            $title eq "" or $url eq ""
        )
        else (
            false()
        )
    let $icon :=
        if($type eq "attachment") then (
            "fa fa-paperclip"
        )
        else if($type eq "blogPost") then (
            "fa fa-rss"
        )
        else if($type eq "book") then (
            "fa fa-book"
        )
        else if($type eq "bookSection") then (
            "fa fa-file-text-o"
        )
        else if($type eq "journalArticle") then (
            "fa fa-file-text-o"
        )
        else if($type eq "webpage") then (
            "fa fa-external-link"
        )
        else ()
    let $formatted-item :=
        if($type eq "attachment") then (
            <span><a href="{$url}">{$title}</a></span>
        )
        else if($type eq "blogPost") then (
            <span>{$author||" ("||$date||"): """||$title||""", in: "}<i>{$blog-title}</i>{" <"}<a href="{$url}">{$url}</a>{">."}</span>
        )
        else if($type eq "book") then (
            <span>{if ($author-empty) then ($editor||" (Hrsg.)") else ($author)}{" ("||$date||"): "}<i>{$title||","}</i>{" "||$publisher||" "||$place||"."}</span>
        )
        else if($type eq "bookSection") then (
            <span>{$author||" ("||$date||"): """||$title||""", in: "}<i>{$book-title||","}</i>{" hg. v. "||$editor||", "||$publisher||" "||$place||", "||$pages||"."}</span>
        )
        else if($type eq "journalArticle") then (
            <span>{$author||" ("||$date||"): """||$title||""", in: "}<i>{$publication-title||" "||$volume||","}</i>{" "||$pages||"."}</span>
        )
        else if($type eq "webpage") then (
            <span>{$title||" <"}<a href="{$url}">{$url}</a>{">."}</span>
        )
        else (
            <span>{$author||" ("||$date||"): "||$title||" ("||$type||")."}</span>
        )
    let $item-map :=
        map {
            "type" : $type,
            "missing-entries" : $missing-entries,
            "key" : $key,
            "icon" : $icon,
            "span" : $formatted-item
        }
    return
        $item-map
};

declare function config:get-collections-in-collection($collection as xs:string) as xs:string* {
    for $coll in xmldb:get-child-collections($collection)
    return (
        $collection || "/" || $coll,
        config:get-collections-in-collection($collection || "/" || $coll)
        )
};

(: Returns the path of the config file :)
declare function config:get-config-file($project-name as xs:string) as xs:string {
    $config:projects-path||"/"||$project-name||"/config.xml"
};

declare function config:get-current-index() as node()? {
    let $index-id := config:get-current-index-id()
    let $project-name := config:get-current-project()
    let $index := config:get-index($project-name, $index-id)
    return
        $index
};

declare function config:get-current-index-id() as xs:string? {
    session:get-attribute('current-index-id')
};

declare function config:get-current-index-name() as xs:string? {
    let $index := config:get-current-index()
    let $index-name := $index/label/string()
    return
        $index-name
};

(: Get the current project from the session. :)
declare function config:get-current-project() as xs:string? {
    session:get-attribute('current-project')
};

declare function config:get-current-user() as xs:string? {
    sm:id()//sm:username/string()
};

declare function config:get-current-zotero-collection() as xs:string {
    let $project-name := config:get-current-project()
    let $connection-id := config:get-current-zotero-connection-id()
    let $zotero-collection := config:get-zotero-collection($project-name, $connection-id)
    return
        $zotero-collection
};

declare function config:get-current-zotero-connection-id() as xs:string? {
    let $index := config:get-current-index()
    let $connection-id := $index/parameter[@name eq "connection-id"]/@value/string()
    return
        $connection-id
};

declare function config:get-ediarum-db-path() as xs:string {
    $config:ediarum-db-path
};

declare function config:get-data-collection ($project-name as xs:string) as xs:string {
    $config:projects-path||"/"||$project-name||$config:data-col
};

declare function config:get-ediarum-index($project-name as xs:string, $ediarum-index-id as xs:string, $first-letter as xs:string?, $show-details as xs:string*) as node()? {
    config:get-ediarum-index-with-params($project-name, $ediarum-index-id, $first-letter, $show-details, true())
};

declare function config:get-ediarum-index-unordered($project-name as xs:string, $ediarum-index-id as xs:string, $first-letter as xs:string?, $show-details as xs:string*) as node()? {
    config:get-ediarum-index-with-params($project-name, $ediarum-index-id, $first-letter, $show-details, false())
};

declare function config:get-ediarum-index-with-params($project-name as xs:string, $ediarum-index-id as xs:string, $first-letter as xs:string?, $show-details as xs:string*, $order as xs:boolean) as node()? {
    if (not(config:is-ediarum-index-active($project-name, $ediarum-index-id))) then
        ()
    else
    let $data-collection := $config:projects-path||"/"||$project-name||$config:data-col
    let $index-collection := $data-collection||'/Register'
    let $alphabet := tokenize('A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z', ',')
    let $letter :=
        if (upper-case($first-letter)=$alphabet)
        then(upper-case($first-letter))
        else ()
    let $entries :=
        if ($letter) then (
            switch($ediarum-index-id)
            case "persons" return
                doc($index-collection||'/Personen/'||$letter||'.xml')
            case "places" return
                doc($index-collection||'/Orte/'||$letter||'.xml')
            default return false
        )
        else (
            collection($index-collection)
        )

    return
    switch($ediarum-index-id)
    case "persons" return (
        let $ul :=
            element ul {
                for $x in $entries//tei:person
                let $name :=
                    if ($x/tei:persName[@type='reg'][1]/tei:forename)
                    then (normalize-space(concat(string-join($x/tei:persName[@type='reg'][1]/tei:surname/text()), ', ', string-join($x/tei:persName[@type='reg'][1]/tei:forename/text()))))
                    else ($x/tei:persName[@type='reg'][1]/tei:name[1]/normalize-space())
                let $lifedate :=
                    if ($x/tei:floruit)
                    then (concat(' (', $x/tei:floruit, ')'))
                    else if ($x/tei:birth)
                        then (concat(' (', $x/tei:birth[1], '-', $x/tei:death[1], ')'))
                        else ()
                let $note :=
                    if ($x/tei:note//text() and $show-details='note')
                    then (concat(' (', $x/tei:note//normalize-space(), ')'))
                    else ()
                order by if ($order) then $name else ()
                return
                    try {
                        element li {
                            attribute xml:id { $x/@xml:id},
                            element span {
                                concat($name, $lifedate, $note)
                            }
                        }
                    } catch * {
                        error((), "Error in file: "||document-uri(root($x))||" in entry: "||serialize($x))
                    }
            }
        return
        $ul
    )
    case "places" return (
        let $ul :=
            element ul {
                for $place in $entries//tei:place
                let $name :=
                    if ($place[ancestor::tei:place])
                    then ($place/ancestor::tei:place/tei:placeName[@type='reg'][1]/normalize-space()||' - '||$place/tei:placeName[@type='reg'][1]/normalize-space())
                    else ($place/tei:placeName[@type='reg'][1]/normalize-space())
                let $altname :=
                    if ($place/tei:placeName[@type='alt'] and $show-details='altname')
                    then (' ['||
                        string-join(
                            for $altname at $pos in $place/tei:placeName[@type='alt']
                            return
                            if ($pos=1)
                            then ($altname/normalize-space())
                            else (', '||$altname/normalize-space())
                        )
                    ||']')
                    else ()
                let $note :=
                    if ($place/tei:note//text() and $show-details='note')
                    then (concat(' (', $place/tei:note[1]//normalize-space(), ')'))
                    else ()
                order by if ($order) then $name[1] else ()
                return
                    try {
                        element li {
                            attribute xml:id { $place/@xml:id},
                            element span {
                                ($name||$altname||$note)
                            }
                        }
                    } catch * {
                        error((), "Error in file: "||document-uri(root($place))||" in entry: "||serialize($place))
                    }
            }
        return
            $ul
    )
    case "items" return (
        let $ul :=
            element ul {
                for $item in $entries//tei:item
                let $name :=
                    if ($item[ancestor::tei:item])
                    then ($item/ancestor::tei:item/tei:label[@type='reg'][1]/normalize-space()||' - '||$item/tei:label[@type='reg'][1]/normalize-space())
                    else ($item/tei:label[@type='reg'][1]/normalize-space())
                order by if ($order) then $name[1] else ()
                return
                try {
                    element li {
                        attribute xml:id {$item/@xml:id},
                        element span {
                            $name
                        }
                    }
                } catch * {
                    error((), "Error in file: "||document-uri(root($item))||" in entry: "||serialize($item))
                }
            }
        return
            $ul
    )
    case "organisations" return (
        let $ul :=
            element ul {
                for $org in $entries//tei:org
                let $name := $org/tei:orgName[@type='reg'][1]/normalize-space()
                order by if ($order) then $name[1] else ()
                return
                    try {
                        element li {
                            attribute xml:id { $org/@xml:id},
                            element span {
                                $name
                            }
                        }
                    } catch * {
                        error((), "Error in file: "||document-uri(root($org))||" in entry: "||serialize($org))
                    }
            }
        return
            $ul
    )
    case "bibliography" return (
        let $ul :=
            element ul {
                for $x in $entries//tei:bibl
                let $author :=
                    if ($x/tei:author[1]/tei:persName[1]/tei:surname/normalize-space())
                    then (concat($x/tei:author[1]/tei:persName[1]/tei:surname/normalize-space(), ', '))
                    else ()
                let $title := $x/tei:title/normalize-space()
                order by $author, $title
                return
                    try {
                        element li {
                            attribute xml:id { $x/@xml:id},
                            element span {
                                concat($author, $title)
                            }
                        }
                    } catch * {
                        error((), "Error in file: "||document-uri(root($x))||" in entry: "||serialize($x))
                    }
            }
        return
            $ul
    )
    case "letters" return (
        let $ul :=
            element ul {
                for $x in collection($data-collection)//tei:TEI[.//tei:correspAction]
                let $title := $x//tei:titleStmt/tei:title/normalize-space()
                order by $x//tei:correspAction[@type='sent']/tei:date/(@when|@from|@notBefore)/data(.)
                return
                    try {
                        element li {
                            attribute xml:id { $x/@xml:id/data(.)},
                            element span {
                                $title
                            }
                        }
                    } catch * {
                        error((), "Error in file: "||document-uri(root($x))||" in entry: "||serialize($x))
                    }
            }
        return
            $ul
    )
    case "comments" return (
        let $ul :=
            element ul {
                for $x in collection($data-collection)//tei:TEI
                let $fileName := substring-after(base-uri($x), 'data/')
                order by $fileName
                return
                    for $note in $x//tei:seg/tei:note
                    return
                        try {
                            element li {
                                attribute id { $x/@xml:id/data(.)||'/#'||$note/@xml:id/data(.)},
                                element span {
                                    $fileName||' - '||substring($note//normalize-space(), 0, 100)
                                }
                            }
                        } catch * {
                            error((), "Error in file: "||document-uri(root($x))||" in entry: "||serialize($x))
                        }
            }
        return
            $ul
    )
    default return
        ()
};

declare function config:get-ediarum-index-ids() as xs:string* {
    for $index in $config:ediarum-indexes?*
    return $index?id
};

declare function config:get-ediarum-index-label($ediarum-index-id as xs:string) as xs:string {
    $config:ediarum-indexes?*[?id=$ediarum-index-id]?label
};

declare function config:get-ediarum-index-file($ediarum-index-id as xs:string) as xs:string {
    let $file := $config:ediarum-indexes?*[?id=$ediarum-index-id]?file
    return if ($file!="") then
        $file
    else
        error((), "No ediarum index file defined for "||$ediarum-index-id)
};

declare function config:get-ediarum-index-collection($ediarum-index-id as xs:string) as xs:string {
    let $collection := $config:ediarum-indexes?*[?id=$ediarum-index-id]?collection
    return if ($collection!="") then
        $collection
    else
        error((), "No ediarum index collection defined for "||$ediarum-index-id)
};

declare function config:get-ediarum-routinen-scheduler() as xs:string* {
    let $resources := xmldb:get-child-resources($config:ediarum-db-path||$config:scheduler-col)
    return
        (
            for $resource in $resources
            return
                if(ends-with($resource,".xql")) then
                    substring($resource,1, string-length($resource)-4)
                else
                    ()
        )
};

declare function config:get-exist-bot-name() as xs:string {
    $config:exist-bot-name
};

(: Get the conf.xml from existdb as node. :)
declare function config:get-existdb-config() as node() {
    let $config-file := config:get-existdb-config-path()
    return
    parse-xml(file:read($config-file))
};

declare function config:get-existdb-config-path() as xs:string {
    system:get-exist-home()||"/"||$config:exist-conf-file
};

(: Get the controller-config.xml from existdb as node. :)
declare function config:get-existdb-controller-config() as node() {
    let $config-file := config:get-existdb-controller-config-path()
    return
    parse-xml(file:read($config-file))
};

declare function config:get-existdb-controller-config-path() as xs:string {
    system:get-exist-home()||$config:exist-controller-config-file
};

declare function config:get-existdb-jetty-config() as node() {
    let $config-file := config:get-existdb-jetty-config-path()
    return
    parse-xml(file:read($config-file))
};

declare function config:get-existdb-jetty-config-path() as xs:string {
    system:get-exist-home()||$config:exist-jetty-config-file
};

declare function config:get-existdb-jetty-ssl-config-path() as xs:string {
    system:get-exist-home()||$config:exist-jetty-ssl-config-file
};

declare function config:get-index($project-name as xs:string, $index-id as xs:string) as node()* {
    let $index := config:get-indexes($project-name)/index[@id eq $index-id]
    return
        $index
};

declare function config:get-indexes($project-name as xs:string) as node()* {
    try {
        doc(config:get-config-file($project-name))//config/indexes
    } catch * {
        <emptry/>
    }
};

declare function config:get-log-file($name as xs:string) as node() {
    doc($config:ediarum-db-path||"/logs/"||$name||".xml")
};

declare function config:get-projects() as xs:string* {
    for $project in xmldb:get-child-collections($config:projects-path)
    order by $project
    return
        $project
};

declare function config:get-project-routinen-scheduler() as xs:string* {
    let $resources := xmldb:get-child-resources( $config:projects-path||"/"||config:get-current-project()||"/exist"||$config:scheduler-col)
    return
        (
            for $resource in $resources
            return
                if(ends-with($resource,".xql")) then
                    substring($resource,1, string-length($resource)-4)
                else
                    ()
        )
};

(: Returns the full path of the resources. :)
declare function config:get-resources-in-collection($collection as xs:string) as xs:string* {
    for $resource in xmldb:get-child-resources($collection)
    return
        $collection || "/" || $resource
        ,
    for $coll in config:get-collections-in-collection($collection)
        for $resource in xmldb:get-child-resources($coll)
        return
            $coll || "/" || $resource
};

declare function config:get-scheduler-jobs() as node() {
    <scheduler>{
        for $project-name in config:get-projects()
        return
            <project name="{$project-name}">
                {config:get-scheduler-jobs($project-name)}
            </project>
        }
    </scheduler>
};

declare function config:get-scheduler-jobs($project-name as xs:string) as node()* {
    let $scheduler := doc(config:get-config-file($project-name))//scheduler
    return
        $scheduler/job
};

declare function config:get-setup() as node() {
    doc(".."||$config:ediarum-config-path)
};

declare function config:get-setup-property($property as xs:string) as xs:string {
    config:get-setup()/setup/property[@name=$property]/@value/string()
};

declare function config:get-synchronisation-targets($project-name as xs:string) as node() {
    doc(config:get-config-file($project-name))//config/synchronisation
};

(: Returns the path of a zotero collection in existdb :)
declare function config:get-zotero-collection($project-name as xs:string, $connection-id as xs:string) as xs:string {
    let $connection := config:get-zotero-connection-by-id($project-name, $connection-id)
    let $connection-name := $connection/label/string()
    return
        $config:projects-path||"/"||$project-name||"/external_data/zotero/"||$connection-name
};

declare function config:get-zotero-collection-items($project-name as xs:string, $connection-id as xs:string, $collection-id as xs:string, $get-all as xs:boolean) as node()* {
    let $collection := collection(config:get-zotero-collection($project-name, $connection-id))
    let $items :=
        if ($get-all) then (
            if (not($collection-id eq "")) then
                try {
                $collection//data[index-of(collections/item/string(), $collection-id)>0]
                } catch * {
                    error((), "Error in execution of config:get-zotero-collection-items("||$project-name||",  "||$connection-id||", "||$collection-id||"). Can't evaluate expression: $collection//data[not(parentItem)][index-of(collections/item/string(), $collection-id)] with collection: "||config:get-zotero-collection($project-name, $connection-id))
                }
            else
                $collection//data
        )
        else (
            if (not($collection-id eq "")) then
                try {
                $collection//data[not(parentItem)][index-of(collections/item/string(), $collection-id)>0]
                } catch * {
                    error((), "Error in execution of config:get-zotero-collection-items("||$project-name||",  "||$connection-id||", "||$collection-id||"). Can't evaluate expression: $collection//data[not(parentItem)][index-of(collections/item/string(), $collection-id)] with collection: "||config:get-zotero-collection($project-name, $connection-id))
                }
            else
                $collection//data[not(parentItem)]
        )
    return
        $items
};

declare function config:get-zotero-collections-uri($group-id as xs:string, $api-key as xs:string, $parameters as xs:string) as xs:anyURI {
    xs:anyURI($config:zotero-base-url||"/groups/"||$group-id||"/collections"||"?key="||$api-key||"&amp;v=3&amp;"||$parameters)
};

(: Returns the xml-node for a saved zotero connection :)
declare function config:get-zotero-connection($project-name as xs:string, $connection-name as xs:string) as node()? {
    config:get-zotero-connections($project-name)//connection[label=$connection-name]
};

(: Returns the xml-node for a saved zotero connection :)
declare function config:get-zotero-connection-by-id($project-name as xs:string, $connection-id as xs:string) as node() {
    let $connection := config:get-zotero-connections($project-name)//connection[@id=$connection-id]
    return
        if ($connection) then (
            $connection
        ) else (
            fn:error( (), "Can't find connection. project-name: "||$project-name||" connection-id: "||$connection-id)
        )
};

declare function config:zotero-connection-get-name() as xs:string? {
    ./label/string()
};

declare function config:get-zotero-connections($project-name as xs:string) as node()* {
    doc(config:get-config-file($project-name))//config/zotero
};

declare function config:get-zotero-connection-uri($group-id as xs:string, $api-key as xs:string) as xs:anyURI {
    xs:anyURI($config:zotero-base-url||"/groups/"||$group-id||"/items"||"?key="||$api-key||"&amp;format=keys&amp;v=3")
};

declare function config:get-zotero-connection-uri($group-id as xs:string, $api-key as xs:string, $parameters as xs:string) as xs:anyURI {
    xs:anyURI($config:zotero-base-url||"/groups/"||$group-id||"/items"||"?key="||$api-key||"&amp;v=3&amp;"||$parameters)
};

declare function config:get-zotero-item-uri($group-id as xs:string, $item-key as xs:string, $api-key as xs:string, $style as xs:string) as xs:anyURI {
    let $include := if ($style != "") then
        "include=data,citation,bib&amp;style="||$style||"&amp;"
        else ""
    return
    xs:anyURI($config:zotero-base-url||"/groups/"||$group-id||"/items/"||$item-key||"?key="||$api-key||"&amp;format=json"||$include||"&amp;v=3")
};

declare function config:get-project-index($project-name as xs:string, $project-index-id as xs:string) as node() {
    let $index := config:get-indexes($project-name)/index[@id eq $project-index-id]
    let $index-name := $index/label/string()
    let $index-collection := $index/parameter[@name eq "data-collection"]/@value/string()
    let $data-namespace := $index/parameter[@name eq "data-namespace"]/@value/string()
    let $data-node := $index/parameter[@name eq "data-node"]/@value/string()
    let $data-xmlid := $index/parameter[@name eq "data-xmlid"]/@value/string()
    let $data-span := $index/parameter[@name eq "data-span"]/@value/string()

    let $namespaces := for $ns in tokenize($data-namespace, ' ')
        let $prefix := substring-before($ns, ':')
        let $namespace-uri := substring-after($ns, ':')
        return
            util:declare-namespace($prefix, $namespace-uri)
    let $col := 
        if (ends-with($index-collection, '.xml')) then 
            doc(config:get-data-collection($project-name)||"/"||$index-collection)
        else
            collection(config:get-data-collection($project-name)||"/"||$index-collection)
    let $items := util:eval-inline($col ,'.//'||$data-node)
    let $list :=
        element {QName("http://www.tei-c.org/ns/1.0",'list')} {
            attribute type {"index"},
            attribute subtype {$index-name},
            for $item in $items
            let $item-id := util:eval('$item/'||$data-xmlid)
            let $item-span := util:eval('$item'||$data-span)
            order by lower-case(string($item-span)) ascending
            return
            element item {
                attribute xml:id { $item-id },
                element span {
                    normalize-space(string($item-span))
                }
            }
        }
    return
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <title>Index: "{$index-name}"</title>
                </titleStmt>
                <publicationStmt>
                    <p>For details see "{$project-name}" project.</p>
                </publicationStmt>
                <sourceDesc>
                    <p>Generated with ediarum.existdb.</p>
                </sourceDesc>
            </fileDesc>
        </teiHeader>
        <text>
            <body>
                {$list}
            </body>
        </text>
    </TEI>
};

declare function config:get-zotero-index($project-name as xs:string, $zotero-index-id as xs:string) as node() {
    let $index := config:get-indexes($project-name)/index[@id eq $zotero-index-id]
    let $index-name := $index/config:zotero-connection-get-name()
    let $connection-id := $index/parameter[@name eq "connection-id"]/@value/string()
    let $collection-id := $index/parameter[@name eq "collection-id"]/@value/string()
    let $zotero-group := config:get-zotero-connection-by-id($project-name, $connection-id)/group-id/string()
    let $items := config:get-zotero-collection-items($project-name, $connection-id, $collection-id, false())
    let $list :=
        element {QName("http://www.tei-c.org/ns/1.0",'list')} {
            attribute type {"index"},
            attribute subtype {$index-name},
            for $item in $items
            let $item-map := config:format-zotero-item($item)
            order by lower-case(string($item-map("span"))) ascending
            return
            element item {
                attribute xml:id { "zotero-"||$zotero-group||"-"||$item-map("key") },
                element span {
                    normalize-space(string($item-map("span")))
                }
            }
        }
    return
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <title>Index: "{$index-name}"</title>
                </titleStmt>
                <publicationStmt>
                    <p>For details see "{$project-name}" project.</p>
                </publicationStmt>
                <sourceDesc>
                    <p>Generated with ediarum.existdb.</p>
                </sourceDesc>
            </fileDesc>
        </teiHeader>
        <text>
            <body>
                {$list}
            </body>
        </text>
    </TEI>
};

declare function config:is-ediarum-index-active($project-name as xs:string, $ediarum-index-id as xs:string) as xs:boolean {
    let $index := config:get-indexes($project-name)/index[@type='ediarum' and @id=$ediarum-index-id]
    let $is-active := if ($index and $index/config:get-parameter('status') eq 'active') then (true())
        else if ($config:ediarum-indexes?*[?id=$ediarum-index-id]?active eq 'true') then (true())
        else false()
    return $is-active
};

declare function config:manage-session($action as xs:string) as xs:anyAtomicType* {
    if ($action eq 'logout') then (
        session:clear(),
        session:invalidate(),
        response:redirect-to(xs:anyURI(ediarum:get-ediarum-dir(request:get-context-path())||"/index.html"))
        )
    else if ($action eq 'login') then (
        session:create(),
        let $logname := request:get-parameter('user','')
        let $logpass := request:get-parameter('pass','')
        return (
            xmldb:login('db',$logname,$logpass),
            let $primary-group := sm:get-user-primary-group($logname)
            let $primary-project := substring-before($primary-group, $config:user-group-suffix)
            let $uri := if ($primary-group eq "dba") then (
                request:get-uri()
                )
                else (
                    xs:anyURI(ediarum:get-ediarum-dir(request:get-context-path())||"/projects/"||$primary-project||"/data.html")
                )
            return
            response:redirect-to($uri)(: request:get-uri()) :)
            )
        )
    else
    if (request:get-parameter('_cache','yes') eq 'yes')
    then
        (
        let $current-uri := request:get-uri()
        let $no-cache := '_cache=no'
        let $parameter := request:get-query-string()
        return
            if (empty($parameter))
            then
                response:redirect-to(xs:anyURI(concat($current-uri,'?',$no-cache)))
            else
                response:redirect-to(xs:anyURI(concat($current-uri,'?',$no-cache,'&amp;',$parameter)))
         )
    else
        ()
};

declare function config:mkcol($collection-uri as xs:string, $group-name as xs:string, $permissions as xs:string) as xs:boolean {
    let $target-collection-uri := functx:substring-before-last($collection-uri, "/")
    let $new-collection := functx:substring-after-last($collection-uri, "/")
    return (
        if (not(xmldb:collection-available($target-collection-uri))) then (
            config:mkcol($target-collection-uri, $group-name, $permissions)
        )
        else (),
        xmldb:create-collection($target-collection-uri, $new-collection) eq $collection-uri,
        sm:chgrp(xs:anyURI($collection-uri), $group-name),
        sm:chmod(xs:anyURI($collection-uri), $permissions)
    )
};

(: Make a new colletion with the right permissions in the project. :)
declare function config:mkcol-in-project($project-name as xs:string, $rel-collection-path as xs:string, $new-collection-name as xs:string, $group-name as xs:string, $permissions as xs:string) as xs:string? {
    xmldb:create-collection(config:project-collection-path($project-name, $rel-collection-path), $new-collection-name),
    sm:chgrp(config:project-resource-uri($project-name, concat($rel-collection-path,"/",$new-collection-name)), $group-name),
    sm:chmod(config:project-resource-uri($project-name, concat($rel-collection-path,"/",$new-collection-name)), $permissions)
};

(: Returns the path of the project :)
declare function config:project-collection-path($project-name as xs:string) as xs:string {
    $config:projects-path||"/"||$project-name
};

(: Returns the path of a collection in a project.  :)
declare function config:project-collection-path($project_name as xs:string, $rel_collection_path as xs:string) as xs:string {
    if ($rel_collection_path eq "") then
        $config:projects-path||"/"||$project_name
    else
        $config:projects-path||"/"||$project_name||"/"||$rel_collection_path
};

(: Returns the uri of a collection in a project.  :)
declare function config:project-resource-uri($project_name as xs:string, $rel_collection_path as xs:string) as xs:anyURI {
    xs:anyURI($config:projects-path||"/"||$project_name||"/"||$rel_collection_path)
};

declare function config:project-user-group($project-name as xs:string) as xs:string {
    concat($project-name, $config:user-group-suffix)
};

(:~
 : Returns the repo.xml descriptor for the current application.
 :)
declare function config:repo-descriptor() as element(repo:meta) {
    $config:repo-descriptor
};

(:~
 : Resolve the given path using the current application context.
 : If the app resides in the file system,
 :)
declare function config:resolve($relPath as xs:string) as node() {
    if (starts-with($config:app-root, "/db")) then
        doc(concat($config:app-root, "/", $relPath))
    else
        doc(concat("file://", $config:app-root, "/", $relPath))
};

declare function config:set-current-index($index-id as xs:string) as item()* {
    session:set-attribute('current-index-id', $index-id)
};

(: Write the current project to the session. :)
declare function config:set-current-project($project-name as xs:string) as item()* {
    session:set-attribute('current-project', $project-name)
};

declare function config:substring-afterlast($string as xs:string, $cut as xs:string) as xs:string{
  if (matches($string, $cut))
    then config:substring-afterlast(substring-after($string,$cut),$cut)
  else $string
};

declare function config:substring-beforelast($string as xs:string, $cut as xs:string) as xs:string {
  if (matches($string, $cut))
    then substring($string,1,string-length($string)-string-length(config:substring-afterlast($string,$cut))-string-length($cut))
  else $string
};

declare function config:synchronisation-get-filenames-in-existdb-collection($server as xs:string, $username as xs:string, $password as xs:string, $resource as xs:string) as map(*) {
    let $response := ediarum:send-authHTTP(xs:anyURI(concat($server, $resource)), $username, $password, 'GET', (), ())
    let $error := xs:integer($response/@statusCode/string())!=200
    let $result :=
        if ($error) then (
            $response
            )
        else (
            (:namespace 'http://exist.sourceforge.net/NS/exist':)
            let $exist-result := $response//httpclient:body/exist:result
            let $child-collections := $exist-result/exist:collection/exist:collection
            let $child-resources := $exist-result/exist:collection/exist:document
            return (
                for $child-resource in $child-resources
                return
                    concat($resource, '/', $child-resource/@name/string()),
                for $child-collection in $child-collections
                return
                    config:synchronisation-get-filenames-in-existdb-collection($server, $username, $password, concat($resource, '/', $child-collection/@name/string()))("result")
            )
        )
    return
        map { "error" := $error ,"result" := $result}
};

declare function config:synchronisation-pull-existdb-collections($source-server as xs:string, $source-username as xs:string, $source-password as xs:string, $source-collection as xs:string, $target-collection as xs:string, $target-group-name as xs:string, $target-mode as xs:string) as map(*) {
    (: Delete files :)
    let $remove := try { xmldb:remove($target-collection) } catch * { () }
    let $create-collection := (
        xmldb:create-collection('', $target-collection) ||
        sm:chown(xs:anyURI($target-collection), config:get-exist-bot-name()) ||
        sm:chgrp(xs:anyURI($target-collection), $target-group-name) ||
        sm:chmod(xs:anyURI($target-collection), $target-mode)
        )
    (: Get all filenames :)
    let $get-filenames-response := config:synchronisation-get-filenames-in-existdb-collection($source-server, $source-username, $source-password, $source-collection)
    return (
        if ($get-filenames-response("error")) then (
            $get-filenames-response
             )
        else
            let $resources := $get-filenames-response("result")
            let $result :=
                for $resource at $i in $resources
                    let $count := count($resources)
                    let $progress-number := number($i)
                    let $update-progressbar := try { session:set-attribute("progress", $progress-number *100 div number($count)) } catch * { () }
                    let $update-progressbar := try {session:set-attribute("progress-message", string($progress-number)||" / "||$count) } catch * { () }

                    (: Hol die Datei. :)
                    let $path := xs:anyURI(concat($source-server, $resource))
                    (: In existdb 1.4 werden CSS/Textdateien nicht korrekt ausgeliefert. :)
                    let $response := ediarum:send-authHTTP($path, $source-username, $source-password, 'GET', (), ())
                    let $type := $response//httpclient:body/@type/string()
                    let $encoding := $response//httpclient:body/@encoding/string()
                    let $mimetype := $response//httpclient:body/@mimetype/string()
                    let $textcontent := $response//httpclient:body/text()
                    let $doc := if ($type="xml") then (
                                    $response//httpclient:body/*
                                    )
                                else if ($type="binary" and $encoding="Base64Encoded" and $mimetype="application/xquery") then (
                                    xs:base64Binary($response//httpclient:body/text())
                                    )
                                else if ($type="binary" and $encoding="Base64Encoded" and $mimetype="application/x-javascript") then (
                                    xs:base64Binary($response//httpclient:body/text())
                                    )
                                else if ($type="binary" and $encoding="Base64Encoded" and $mimetype="application/octet-stream") then (
                                    xs:base64Binary($response//httpclient:body/text())
                                    )
                                else if ($type="binary" and $encoding="Base64Encoded") then (
                                    xs:base64Binary($response//httpclient:body/text())
                                    )
                                else if ($type="text" and $encoding="URLEncoded") then (
                                    util:unescape-uri($textcontent, "UTF-8")
                                    )
                                else ()
                    (: Alternative Quelle für die Dateien, statt über http. Funktioniert nur, wenn es derselbe Server ist! :)
                    (:let $source-resource-exist-path := "xmldb:exist://"||$source-server||"/exist/xmlrpc" ||$resource
                    let $login := xmldb:login($source-resource-exist-path, $source-username, $source-password)
                    let $doc := doc():)
                    (: Speichere die Datei :)
                    let $target-resource := config:substring-afterlast($resource, "/")
                    let $resource-collection := concat($target-collection,config:substring-beforelast(substring-after($resource, $source-collection), '/'))
                    let $create-collection := config:create-collection($resource-collection, config:get-exist-bot-name(), $target-group-name, $target-mode)
            (: <httpclient:response xmlns:httpclient="http://exist-db.org/xquery/httpclient" statusCode="200">
                <httpclient:headers>
                    <httpclient:header name="name" value="value"/>
                    ...
                </httpclient:headers>
                <httpclient:body type="xml|xhtml|text|binary" mimetype="returned content mimetype">
                    body content
                </httpclient:body>
            </httpclient:response> :)
                    return (
                        if (xs:string($doc)) then (
                            "Gespeicherte Datei: " || xmldb:store($resource-collection, $target-resource, $doc, $mimetype) || sm:chown(xs:anyURI($resource-collection||"/"||$target-resource), config:get-exist-bot-name()) || sm:chgrp(xs:anyURI($resource-collection||"/"||$target-resource), $target-group-name) || sm:chmod(xs:anyURI($resource-collection||"/"||$target-resource), $target-mode), <br/>
                            )
                        else (
                            "Fehler: " || $resource || "; Type: " || $type || "; Response: ", $response, <br/>
                            )
                    )
        return
            map {"result" : $result}
        )
};

(: Writes the resources in the source to the target existdb server :)
declare function config:synchronisation-push-existdb-collections($source-collection as xs:string, $target-server as xs:string, $target-username as xs:string, $target-password as xs:string, $target-collection as xs:string) as map(*) {
    (: Delete files :)
    let $path := xs:anyURI(concat($target-server, $target-collection))
    let $delete-collection := ediarum:send-authHTTP($path, $target-username, $target-password, 'DELETE', (), ())
    let $collection-deleted := map {
        "error" : index-of((200,204), xs:integer($delete-collection/@statusCode/string()))=(),
        "result" : $delete-collection
    }
    return
    if ($collection-deleted("error")) then
        $collection-deleted
    else
    (: Get all filenames :)
    let $resources := config:get-resources-in-collection($source-collection)
    let $push-resource :=
        for $resource at $i in $resources
            let $count := count($resources)
            let $progress-number := number($i)
            let $update-progressbar := try { session:set-attribute("progress", $progress-number *100 div number($count)) } catch * { () }
            let $update-progressbar := try { session:set-attribute("progress-message", string($progress-number)||" / "||$count) } catch * { () }
            (: Erstelle den Pfad. :)
            let $target-resource := $target-collection || substring-after($resource, $source-collection)
            let $path := xs:anyURI(concat($target-server, $target-resource))
            (: Synchronisation von allen Dateitypen: Fehler evtl. bei Sonderzeichen. :)
            let $content-type := xmldb:get-mime-type($resource)
            let $content := if (util:binary-doc-available($resource)) then (
                                util:binary-doc($resource)
                                )
                            else
                                doc($resource)
            (:if (util:binary-doc-available($resource)) then (
                                "application/octet-stream"
                                )
                            else
                                "application/xml":)
            (: Speichere die Datei :)
            let $response := ediarum:send-authHTTP($path, $target-username, $target-password, 'PUT', $content, $content-type)
            let $error := xs:integer($response/@statusCode/string())!=201
            let $result := if($error) then (
                                "Fehler (" || $response/@statusCode/string() || ") bei: " || $resource
                            ) else (
                                $resource || " gespeichert als " || $target-resource (:), <br/>, serialize($response):)
                            )

            return
                map {
                    "error" : $error,
                    "result" : $result
                }
    return
        map {
            "error" : distinct-values(for $map in $push-resource return if ($map("error")) then true() else ()),
            "result" : (for $map in $push-resource return ($map("result"), <br/>))
        }
};

declare function config:synchronize-zotero-connection-collections($project-name as xs:string, $connection-id as xs:string) as node() {
    let $connection := config:get-zotero-connection-by-id($project-name, $connection-id)
    let $group-id := $connection/group-id
    let $api-key := $connection/api-key
    let $limit := "100"
    let $connection-uri := config:get-zotero-collections-uri($group-id, $api-key, "format=keys")
    let $response := httpclient:get($connection-uri, false(),  ())
    let $body := $response//httpclient:body/text()
    let $txt := xmldb:decode-uri($body)
    let $resource-name := "collections.txt"
    let $collection-uri := config:get-zotero-collection($project-name, $connection-id)
    let $new-resource := xmldb:store($collection-uri, $resource-name, $txt)
    let $user-group := config:project-user-group($project-name)
    let $store := (
            sm:chgrp($new-resource, $user-group),
            sm:chmod($new-resource, "rw-rw----")
        )
    let $collection-keys := tokenize(normalize-space($txt), '\s')
    let $count := count($collection-keys)
    let $block-count := xs:integer(ceiling(number($count) div number($limit)))

    let $collection-xml :=
        <collections>
            {
                for $i in (0 to $block-count -1)
                return
                try {
                    let $parameters := "limit="||$limit||"&amp;start="||string(number($i)*number($limit))
                    let $connection-uri := config:get-zotero-collections-uri($group-id, $api-key, $parameters)
                    let $response := httpclient:get($connection-uri, false(),  ())
                    let $body := $response//httpclient:body/text()
                    let $json := util:base64-decode($body)

                    let $json-model := parse-json($json)
                    return
                        for $object at $pos in $json-model?*
                        let $progress-number := (number($i)*number($limit) + $pos)
                        let $update-progressbar := session:set-attribute("progress", $progress-number *100 div number($count))
                        let $update-progressbar := session:set-attribute("progress-message", string($progress-number)||" / "||$count)
                        let $key := $object("data")("key")
                        let $version := $object("data")("version")
                        let $name := $object("data")("name")
                        let $parentCollection := $object("data")("parentCollection")
                        return
                            <collection key="{$key}" version="{$version}" name="{$name}" parentCollection="{$parentCollection}">
                            </collection>
                } catch * {
                    ()
                }
            }
        </collections>
    let $new-resource := xmldb:store($collection-uri, "collections.xml", $collection-xml)
    let $user-group := config:project-user-group($project-name)
    let $store := (
            sm:chgrp($new-resource, $user-group),
            sm:chmod($new-resource, "rw-rw----")
        )
    return
        <result>
            <type>success</type>
            <message>Die Ordnerinformationen wurden gespeichert.</message>
        </result>
};

declare function config:synchronize-zotero-connection-in-blocks($project-name as xs:string, $connection-id as xs:string, $since as xs:integer, $delete as xs:boolean) as node() {
    let $connection := config:get-zotero-connection-by-id($project-name, $connection-id)
    let $connection-name := $connection/label/string()
    let $group-id := $connection/group-id/string()
    let $api-key := $connection/api-key/string()
    let $style := $connection/style/string()
    let $limit := "100"

    let $update-progressbar := session:set-attribute("progress", 1)
    let $parameters := "since="||$since||"&amp;format=keys"

    let $connection-uri := config:get-zotero-connection-uri($group-id, $api-key, $parameters)
    let $headers :=  <headers><header name="If-Modified-Since-Version" value="{$since}"/></headers>
    let $response := httpclient:get($connection-uri, false(),  $headers)
    let $status-code := $response/@statusCode/string()
    let $result :=
        if ($status-code eq "403") then (
            <result>
                <type>warning</type>
                <message>
                    <p>Die Verbindungsdaten sind nicht korrekt</p>
                </message>
            </result>
        )
        else if ($status-code eq "304") then (
            <result>
                <type>success</type>
                <message>
                    <p>Die Verbindung ist aktuell.</p>
                </message>
            </result>
        )
        else (
            let $collection-uri := config:get-zotero-collection($project-name, $connection-id)

            let $clear-collection :=
                if ($delete) then (
                    for $resource in xmldb:get-child-resources($collection-uri)
                    return
                        xmldb:remove($collection-uri, $resource)
                )
                else ()
            let $count := $response//httpclient:header[@name eq 'Total-Results']/@value/string()
            let $block-count := ceiling(number($count) div number($limit))
            let $message :=
                for $i in (0 to xs:integer($block-count -1))
                let $block := "block"||$i
                return
                try {
                    let $include := if ($style != "") then
                        "include=data,citation,bib&amp;style="||$style||"&amp;"
                        else ""
                    let $parameters := "since="||$since||"&amp;limit="||$limit||"&amp;"||$include||"&amp;start="||string(number($i)*number($limit))
                    let $connection-uri := config:get-zotero-connection-uri($group-id, $api-key, $parameters)
                    let $response := httpclient:get($connection-uri, false(),  ())
                    let $body := $response//httpclient:body/text()
                    let $json := util:base64-decode($body)

                    let $json-model := parse-json($json)

                    for $item at $pos in $json-model?*
                        let $progress-number := (number($i)*number($limit) + $pos)
                        let $update-progressbar := session:set-attribute("progress", $progress-number *100 div number($count))
                        let $update-progressbar := session:set-attribute("progress-message", string($progress-number)||" / "||$count)


                        let $resource-name := $item("key")||".xml"
                        let $xml := config:transform-json-to-xml($item)
                        let $new-resource := xmldb:store($collection-uri, $resource-name, $xml)
                        let $user-group := config:project-user-group($project-name)
                        let $store := (
                                sm:chgrp($new-resource, $user-group),
                                sm:chmod($new-resource, "rw-rw----")
                            )
                        return
                            <result>
                                <type>success</type>
                                <message>
                                    <p>{"Datei "||$resource-name||" gespeichert."}</p>
                                </message>
                            </result>
                  } catch * {
                    <result>
                        <type>warning</type>
                        <message>
                            <p>Fehler bei Block {$block} aufgetreten: {$err:code}, {$err:description}, {$err:value}, module: {$err:module}, ({$err:line-number}, {$err:column-number})</p>
                        </message>
                    </result>
                }
            let $synch-collections := config:synchronize-zotero-connection-collections($project-name, $connection-id)
            let $update-progressbar := session:set-attribute("progress", 100)
            let $update-progressbar := session:set-attribute("progress-message", "")
            return
                <result>
                    <type>{if (index-of(($message//type/string()), 'warning') > 0 ) then (
                        "warning"
                        )
                        else (
                            "success"
                        )
                    }</type>
                    <message>
                        <p>Die Verbindung "{$connection-name}" wurde synchronisiert! <a role="button" data-toggle="collapse" href="#result" aria-expanded="false" aria-controls="collapseExample">Mehr..</a>
                        </p>
                        <div class="collapse" id="result">
                            <div class="well">
                                {$message//message/p}
                            </div>
                        </div>
                    </message>
                </result>
        )
    return
        $result
};

declare function config:transform-json-to-xml($item) as item()* {
    <json>
        <item>
            {config:transform-map-to-xml($item)}
        </item>
    </json>
};

declare function config:transform-map-to-xml($map as map()) as item()* {
    map:for-each($map, function($key, $value){
        element {$key} {
            if (empty($value)) then
                ""
            else if ($value instance of xs:string) then
                $value
            else if ($value instance of  xs:double) then
                $value
            else if ($value instance of  xs:boolean) then
                $value
            else if ($value instance of array(*)) then
                config:transform-array-to-xml($value)
            else
                config:transform-map-to-xml($value)
        }
    })
};

declare function config:transform-array-to-xml($map as array(*)) as item()* {
    array:for-each($map, function($value){
        element item {
            if (empty($value)) then
                ""
            else if ($value instance of xs:string) then
                $value
            else if ($value instance of  xs:double) then
                $value
            else if ($value instance of  xs:boolean) then
                $value
            else if ($value instance of array(*)) then
                config:transform-array-to-xml($value)
            else
                config:transform-map-to-xml($value)
        }
    })
};

declare function config:unset-current-project() as xs:string? {
    session:remove-attribute('current-project')
};

declare function config:update-file($resource as xs:string, $contents as item()) as empty-sequence() {
    let $collection-uri := config:substring-beforelast($resource, "/")
    let $resource-name := config:substring-afterlast($resource, "/")
    let $file := xmldb:store($collection-uri, $resource-name, $contents)
    return ()
};

declare function config:update-zotero-connection-in-blocks($project-name as xs:string, $connection-id as xs:string) as node() {
    let $connection := config:get-zotero-connection-by-id($project-name, $connection-id)
    let $connection-name := $connection/config:zotero-connection-get-name()
    let $items := config:get-zotero-collection-items($project-name, $connection-id, "", true())
    let $last-version := max($items/version)
    return
        if (not($last-version)) then (
            <result>
                <type>warning</type>
                    <message>
                        <p>Update fehlgeschlagen. Bitte führen Sie eine Synchronisation der Zotero-Verbindung "{$connection-name}" durch.</p>
                    </message>
            </result>
        ) else (
            let $result :=
                config:synchronize-zotero-connection-in-blocks($project-name, $connection-id, $last-version, false())
            let $new-items := config:get-zotero-collection-items($project-name, $connection-id, "", true())
            let $new-version := max($new-items/version)
            return
                <result>
                    <type>success</type>
                    <message>
                        {$result/message/*}
                        <p>Alte Version: {$last-version}, neue Version: {$new-version}.</p>
                    </message>
                </result>
        )
};

(: config.xml - Object orientierter Ansatz :)
declare function config:get-parameter($name as xs:string) as xs:string {
    let $parameter := ./parameter[@name eq $name]
    let $value := $parameter/@value/string()
    return
        if ($parameter) then (
            $value
        )
        else (
            error((), "Can't get '"||$name||"' in "||.)
        )
};
