xquery version "3.0";

import module namespace config="http://www.bbaw.de/telota/software/ediarum/config" at "modules/config.xqm";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

declare function local:forward($web-path as xs:string, $app-path as xs:string) {
    if ($exist:path eq $web-path) then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="views/{$app-path}"/>
            <view>
                <forward url="{$exist:controller}/modules/view.xql"/>
            </view>
            <error-handler>
    			<forward url="{$exist:controller}/views/static-pages/error-page.html" method="get"/>
    			<forward url="{$exist:controller}/modules/view.xql"/>
        	</error-handler>
        </dispatch>
    else
        ()
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
        {if (index-of(xmldb:get-user-groups(xmldb:get-current-user()), "dba")>0 or
            index-of(xmldb:get-user-groups(xmldb:get-current-user()), config:project-user-group(config:get-current-project()))>0
        ) then (
            <forward url="{$exist:controller}/views/project-pages/{$exist:resource}"/>
            )
        else (
            (: TODO: Weiterleitung für Nutzer. :)
            <redirect url="/index.html"/>
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
    local:forward("/index.html", "static-pages/index.html"),
    local:forward("/dokumentation.html", "static-pages/dokumentation.html"),
    local:forward("/projects.html", "admin-pages/projects.html"),
    local:forward("/existdb.html", "admin-pages/existdb.html"),
    local:forward("/setup.html", "admin-pages/setup.html"),
    local:forward("/scheduler.html", "admin-pages/scheduler.html")
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
