xquery version "3.0";

module namespace template-pages="http://www.bbaw.de/telota/software/ediarum-app/template-pages";
import module namespace config="http://www.bbaw.de/telota/software/ediarum/config";
import module namespace ediarum="http://www.bbaw.de/telota/software/ediarum/ediarum-app";

declare namespace sm="http://exist-db.org/xquery/securitymanager";

(:~ Fürs Login. :)
declare function template-pages:login-menu($node as node(), $model as map(*)) as node() {
    let $log-action := request:get-parameter('laction','')
    let $session := config:manage-session($log-action)
    return
    if (config:get-current-user() eq 'guest') then
        <li class="dropdown">
            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Login<span class="caret"/></a>
            <ul class="dropdown-menu">
                <form action="" method="post" class="navbar-form navbar-left">
                <input type="hidden" name="laction" value="login"/>
                <li>
                    <label for="lname" class="sr-only">Name:</label><input type="text" class="form-control" placeholder="Name" name="user"/>
                </li>
                    <li>
                    <li role="separator" class="divider"/>
                    <label for="lpass" class="sr-only">Passwort:</label>
                    <input type="password" class="form-control" placeholder="Passwort" name="pass"/>
                    </li>
                    <li role="separator" class="divider"/>
                    <li> <input type="submit" class="btn btn-default" value="Einloggen"/> </li>
                </form>
            </ul>
        </li>
    else
        <li class="dropdown">
            <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Logged in as {config:get-current-user()}<span class="caret"/></a>
            <ul class="dropdown-menu">
                <form action="" method="post" class="navbar-form navbar-left">
                <li>
                    <input type="hidden" name="laction" value="logout"/>
                    <input type="hidden" name="user" value="guest"/>
                    <input type="hidden" name="pass" value="guest"/>
                    <input type="submit" class="btn btn-default" value="Logout"/>
                </li>
                </form>
            </ul>
        </li>
};

(: Interne Bereiche :)
 declare function template-pages:admin-menus($node as node(), $model as map(*)) as node()* {
    (: Das Menü wird gezeigt, wenn der Nutzer dba ist. :)
    if (sm:is-dba(config:get-current-user()) )
    then
     (<li class="dropdown">
        <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Verwaltung<span class="caret"/></a>
        <ul class="dropdown-menu">
            <li>
                <a href="{ediarum:get-ediarum-dir(request:get-context-path())}/projects.html">Projekte</a>
            </li>
            <li>
                <a href="{ediarum:get-ediarum-dir(request:get-context-path())}/existdb.html">exist-db</a>
            </li>
            <li>
                <a href="{ediarum:get-ediarum-dir(request:get-context-path())}/scheduler.html">Scheduler</a>
            </li>
            <li>
                <a href="{ediarum:get-ediarum-dir(request:get-context-path())}/setup.html">Setup</a>
            </li>
        </ul>
    </li>)
    else
        ()
 };

(: Projektmenüs :)
declare function template-pages:project-menu($node as node(), $model as map(*)) as node()* {
    (: Das Menü wird nur ausgegeben, .. :)
    if(
        (: ..wenn der Nutzer kein Gast ist.. :)
        config:get-current-user() ne 'guest' and
        (: ..und entweder das Projekt gesetzt ist oder der Nutzer kein DBA ist (und daher ein Mitglied eines Projektes). :)
        (not(sm:is-dba(config:get-current-user())) or config:get-current-project()) 
        ) then (
        (: Wenn kein Projekt gesetzt ist, wird das Hauptprojekt des Nutzers gesetzt. :)
        if(not(config:get-current-project())) then (
            config:set-current-project(substring-before(sm:get-user-primary-group(config:get-current-user()), $config:user-group-suffix))
            ) 
        else (),
        (: Alle Gruppen des Nutzer werden ausgelesen. :)
        let $groups := sm:get-user-groups(config:get-current-user())
        return
            (: Wenn der User ein Nutzer ist und mehr als einer Gruppe angehört.. :)
            if(count($groups) > 1 and not(sm:is-dba(config:get-current-user()))) then (
                (: ..wird eine Auswahlbox erzeugt. :)
                <li class="dropdown">
                    <a href="#" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">{config:get-current-project()}<span class="caret"/></a>
                    <ul class="dropdown-menu">
                        {
                            for $group in $groups
                            let $g := substring-before($group, $config:user-group-suffix)
                            return
                                <li>
                                    <a href="{ediarum:get-ediarum-dir(request:get-context-path())}/projects/{$g}/data.html">{$g}</a>
                                </li>
                        }
                    </ul>
                </li>
            ) else (
                (: Sonst wird nur der Link auf die Datenansicht erzeugt. :)
                <li>
                    <a href="{ediarum:get-ediarum-dir(request:get-context-path())}/projects/{config:get-current-project()}/data.html">{config:get-current-project()}</a>
                </li>
            ),
        (: Es werden die aktuellen Register gesucht.. :)
        let $indexes := config:get-indexes(config:get-current-project())//index
        return
            (: ..für die dann auch eine Auswahlbox erzeugt wird. :)
            <li class="dropdown{if (exists($indexes)) then () else (" disabled")}">
                <a href="#" class="dropdown-toggle{if (exists($indexes)) then () else (" disabled")}" data-toggle="dropdown" role="button"
                aria-haspopup="true" aria-expanded="false">Register<span class="caret"/></a>
                    <ul class="dropdown-menu">
                        {
                            for $index in $indexes
                            let $label := $index/label/string()
                            let $id := $index/@id/string()
                            return
                                <li>
                                    <a href="{ediarum:get-ediarum-dir(request:get-context-path())}/projects/{config:get-current-project()}/indexes/{$id}/items.html">{$label}</a>
                                </li>
                        }
                    </ul>
            </li>
    ) else ()
};

(: Projektadminmenüs :)
declare function template-pages:project-admin-menu($node as node(), $model as map(*)) as node()? {
    try {
        let  $cuser := config:get-current-user()
        let $cproject := config:project-user-group(config:get-current-project())
        return
        (: Wenn ein Projekt ausgewählt ist und der Nutzer entweder admin oder group-manager ist, zeige das Menü. :)
        if (config:get-current-project() and (sm:is-dba($cuser) or ($cuser = sm:get-group-managers($cproject)))) then (
            <li class="dropdown">
                <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button"
                aria-haspopup="true" aria-expanded="false">Projektkonfiguration<span class="caret"/></a>
                <ul class="dropdown-menu">
                    <li><a href="{ediarum:get-ediarum-dir(request:get-context-path())}/projects/{config:get-current-project()}/user.html">Benutzer</a></li>
                    <li><a href="{ediarum:get-ediarum-dir(request:get-context-path())}/projects/{config:get-current-project()}/synchronisation.html">Synchronisation</a></li>
                    <li><a href="{ediarum:get-ediarum-dir(request:get-context-path())}/projects/{config:get-current-project()}/scheduler.html">Scheduler</a></li>
                    <li><a href="{ediarum:get-ediarum-dir(request:get-context-path())}/projects/{config:get-current-project()}/zotero.html">Zotero</a></li>
                    <li><a href="{ediarum:get-ediarum-dir(request:get-context-path())}/projects/{config:get-current-project()}/indexes.html">Register</a></li>
                    <li><a href="{ediarum:get-ediarum-dir(request:get-context-path())}/projects/{config:get-current-project()}/development.html">Entwicklung</a></li>
                    <!--li role="separator" class="divider"/>
                    <li><a href="data.html?root=/db/projects/{config:get-current-project()}{$config:data-col}">Daten</a></li>
                    <li><a href="data.html?root=/db/projects/{config:get-current-project()}/data-copy">Data-Copy</a></li-->
                </ul>
            </li>
        ) else ()
    } catch * {
        (: sm:get-group-managers($group) wirft Exception wenn angemeldeter User nicht DBA oder group-manager ist :)
        <ignoreme/>
    }
};

declare function template-pages:timestamp($node as node(), $model as map(*)) as node()? {
    <span class="hidden">{current-dateTime()}</span>
};
