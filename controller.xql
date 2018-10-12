xquery version "3.0";

import module namespace config="http://www.bbaw.de/telota/software/ediarum/config" at "modules/config.xqm";
import module namespace console="http://exist-db.org/xquery/console";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

declare variable $local:base-url := substring-before(request:get-url(), $exist:controller)||$exist:controller;

declare function local:forward($app-path as xs:string, $params as map(*)) {
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="views/{$app-path}">
            {map:for-each($params, function($key, $value){
                <set-attribute name="{$key}" value="{$value}"/>
            })}
        </forward>
        <view>
             <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
        <error-handler>
            <forward url="{$exist:controller}/views/static-pages/error-page.html" method="get"/>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </error-handler>
    </dispatch>
};

if ($exist:path eq "/") then
    (: forward root path to index.html :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>
else if (contains($exist:path, "/$shared/")) then
    (: für alle gemeinsamen Ressourcen :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
else if (ends-with($exist:path, ".html") and contains($exist:path, "/projects/")) then (
    (: Für die Projektunterseiten :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        {config:set-current-project(substring-before(substring-after($exist:path, "/projects/"), "/"))}
        {if (contains($exist:path, "/indexes/")) then (
                config:set-current-index(substring-before(substring-after($exist:path, "/indexes/"), "/"))
        ) else()}
        {
            let  $cuser := config:get-current-user()
            let $cproject := config:project-user-group(config:get-current-project())
            return 
                (: Wenn der Nutzer dba ist, oder der Nutzer Mitglied der Projektgruppe.. :)
                if (sm:is-dba($cuser) or ($cproject = sm:get-user-groups($cuser))) then (
                    let $admin-menu := ("user.html", "synchonisation.html", "scheduler.html", "zotero.html", "indexes.html", "development.html")
                    return 
                        (: ..und wenn eine der genannten Seiten aufgerufen wird, .. :)
                        if($exist:resource = $admin-menu) then (
                            try {
                                if(sm:is-dba($cuser) or ($cuser = sm:get-group-managers($cproject))) then (
                                    <forward url="{$exist:controller}/views/project-pages/{$exist:resource}"/>
                                ) else (
                                    <redirect url="{$local:base-url}/index.html"/>
                                )
                            } catch java:org.exist.xquery.XPathException {
                                (: sm:get-group-managers($group) wirft Exception wenn angemeldeter User nicht DBA oder group-manager ist :)
                                <redirect url="{$local:base-url}/index.html"/>
                            }
                        ) else (
                            <forward url="{$exist:controller}/views/project-pages/{$exist:resource}"/>
                        )
                    ) 
                else (
                    <redirect url="{$local:base-url}/index.html"/>
                    )
        }
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
        <error-handler>
            <forward url="{$exist:controller}/views/static-pages/error-page.html" method="get"/>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </error-handler>
    </dispatch>
    )
else if (ends-with($exist:path, ".html")) then (
    (: Genaue Seitenverweise :)
    if(sm:is-dba(config:get-current-user())) then (
        switch ($exist:path)
            case "/projects.html" return local:forward("admin-pages/projects.html", map {})
            case "/existdb.html" return local:forward("admin-pages/existdb.html", map {})
            case "/setup.html" return local:forward("admin-pages/setup.html", map {})
            case "/scheduler.html" return local:forward("admin-pages/scheduler.html", map {})
            default return local:forward("static-pages/index.html", map {})
        ) 
    else (
        switch($exist:path)
            case "/index.html" return 
                local:forward("static-pages/index.html", map {})
            default return 
                <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
                    <redirect url="{$local:base-url}/index.html"/>
                </dispatch>
        )
    )
else if (ends-with($exist:path, ".xql")) then (
    (: Alle XQuerys werden gefunden. :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/modules/{$exist:resource}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
    )
else if (ends-with($exist:path, ".css")) then (
    (: Alle CSS werden hierüber gefunden. :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/resources/css/{$exist:resource}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
    )
else if (ends-with($exist:path, ".eot") or ends-with($exist:path, ".svg") or ends-with($exist:path, ".ttf") or ends-with($exist:path, ".woff") or ends-with($exist:path, ".woff2")) then (
    (: Alle CSS werden hierüber gefunden. :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/resources/fonts/{$exist:resource}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
    )
else if (ends-with($exist:path, ".ico") or ends-with($exist:path, ".png") or ends-with($exist:path, ".gif")) then (
    (: Alle Bilder werden hierüber gefunden. :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/resources/images/{$exist:resource}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
    )
else if (ends-with($exist:path, ".js")) then (
    (: Alle JavaScripts werden hierüber gefunden. :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/resources/scripts/{$exist:resource}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
    )
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
