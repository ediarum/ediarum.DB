xquery version "3.1";

module namespace project-pages="http://www.bbaw.de/telota/software/ediarum-app/project-pages";
import module namespace config="http://www.bbaw.de/telota/software/ediarum/config";
declare namespace functx = "http://www.functx.com";

declare function functx:escape-for-regex($arg as xs:string?) as xs:string {
   replace($arg, '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
};

declare function functx:is-a-number($value as xs:anyAtomicType?) as xs:boolean {
    string(number($value)) != 'NaN'
};

declare function functx:substring-before-last($arg as xs:string?, $delim as xs:string) as xs:string {
    if (matches($arg, functx:escape-for-regex($delim))) then
        replace($arg,concat('^(.*)', functx:escape-for-regex($delim),'.*'),'$1')
    else
        ''
};

declare function functx:substring-after-last($arg as xs:string?, $delim as xs:string) as xs:string {
    replace ($arg,concat('^.*',functx:escape-for-regex($delim)),'')
};

declare function project-pages:action-alert($node as node(), $model as map(*)) as node()? {
    let $result := $model("result")
    let $type := $result/type
    let $message := $result/message
    return
    if ($type eq 'success') then
        <div class="alert alert-success" role="alert">{$message}</div>
    else if ($type eq 'warning') then
        <div class="alert alert-warning" role="alert">{$message}</div>
    else if ($type eq 'danger') then
        <div class="alert alert-danger" role="alert">{$message}</div>
    else ()
};

declare function project-pages:add-new-scheduler-job($node as node(), $model as map(*)) as node() {
    let $new-scheduler-job-id := max((config:get-scheduler-jobs()//job/@id[functx:is-a-number(number())]/number(),0))+1
    return
    <nav class="navbar navbar-default">
        <div class="container-fluid">
            <div class="navbar-header">
                <span class="navbar-brand">Neuer Scheduler-Job</span>
            </div>
            <div class="navbar-form">
                <div class="form-group">
                    <button type="button" class="btn btn-default" data-toggle="modal" data-target="#modalNewSchedulerJob" data-scheduler-job-id="{$new-scheduler-job-id}" data-scheduler-job-type="synchronisation" data-scheduler-job-cron="0 0 * * *">Hinzufügen!</button>
                </div>
            </div>
        </div>
    </nav>
};

declare function project-pages:data($node as node(), $model as map(*)) as empty-sequence() {
    let  $cuser := config:get-current-user()
    let $cproject := config:project-user-group(config:get-current-project())
    return if (sm:is-dba($cuser) or ($cproject = sm:get-user-groups($cuser))) then (
        let $action := request:get-parameter('action','')
        let $target-collection := request:get-parameter('target-collection','')
        let $collection := request:get-parameter('collection','')
        let $resource := request:get-parameter('resource','')
        let $target-collection-uri := $config:projects-path||"/"||config:get-current-project()||$config:data-col||"/"||$target-collection
        return
        if ($action eq 'removeResource') then (
            if ($resource eq '') then (
                let $item := xmldb:remove($target-collection-uri)
                return ()
                )
            else (
                let $item := xmldb:remove($target-collection-uri, $resource)
                return ()
                )
            )
        else if ($action eq 'newResource') then (
            let $new-resource := xmldb:store($target-collection-uri, $resource, <root></root>)
            let $user-group := config:project-user-group(config:get-current-project())
            return (
            sm:chgrp($new-resource, $user-group),
            sm:chmod($new-resource, "rw-rw----")
            ))
        else if ($action eq 'newCollection') then (
            let $new-collection := xmldb:create-collection($target-collection-uri, $collection)
            let $user-group := config:project-user-group(config:get-current-project())
            return (
            sm:chgrp($new-collection, $user-group),
            sm:chmod($new-collection, "rwxrwx---")
            ))
        else ()
        )
    else (
    )
};

declare function project-pages:development($node as node(), $model as map(*)) as map(*) {
    let  $cuser := config:get-current-user()
    let $cproject := config:project-user-group(config:get-current-project())
    return if (sm:is-dba($cuser) or ($cproject = sm:get-user-groups($cuser))) then (
        let $action := request:get-parameter('action','')
        let $project := config:get-current-project()
        let $result := ()
        return
            map { "result" := $result }
        )
    else (
        map {}
        )
};

declare function project-pages:get-current-project($node as node(), $model as map(*)) as xs:string? {
    config:get-current-project()
};

declare function project-pages:get-current-index-name($node as node(), $model as map(*)) as xs:string? {
    config:get-current-index-name()
};

declare function project-pages:get-scheduler-ediarum-routinen($node as node(), $model as map(*)) as xs:string {
    let $xqueries := config:get-ediarum-routinen-scheduler()
    return
    "{" ||
        string-join(
            for $xquery in $xqueries
            return
                " '"|| $xquery ||"' : '"|| $xquery ||"' "
            , ',')
     || "}"
};

declare function project-pages:get-scheduler-project-routinen($node as node(), $model as map(*)) as xs:string {
    let $xqueries := config:get-project-routinen-scheduler()
    return
    "{" ||
        string-join(
            for $xquery in $xqueries
            return
                " '"|| $xquery ||"' : '"|| $xquery ||"' "
            , ',')
     || "}"
};

declare function project-pages:get-scheduler-routinen-parameter($node as node(), $model as map(*)) as xs:string {
    let $ediarum-xqueries := config:get-ediarum-routinen-scheduler()
    let $project-xqueries := config:get-project-routinen-scheduler()
    return
    "{" ||
        string-join(
            (for $xquery in $ediarum-xqueries
            let $params := local:get-xquery-external-parameter($config:ediarum-db-routinen-scheduler-path||"/"||$xquery||".xql")
            return
                " '"|| $xquery ||"' : "|| $params
            ,for $xquery in $project-xqueries
            let $params := local:get-xquery-external-parameter( $config:projects-path||"/"||config:get-current-project()||"/exist"||$config:scheduler-col||"/"||$xquery||".xql")
            return
                " '"|| $xquery ||"' : "|| $params
            )
            , ","
        )
        || " }"
};

declare function project-pages:index-items($node as node(), $model as map(*)) as map(*) {
    let  $cuser := config:get-current-user()
    let $cproject := config:project-user-group(config:get-current-project())
    return if (sm:is-dba($cuser) or ($cproject = sm:get-user-groups($cuser))) then (
        let $action := request:get-parameter('action','')
        let $project := config:get-current-project()
        let $index-id := config:get-current-index-id()
        let $result :=
            if ($action eq 'update-index') then (
                let $index := config:get-index($project, $index-id)
                let $connection-id := $index/config:get-parameter("connection-id")
                let $result := local:update-zotero-connection-in-blocks($connection-id)
                return
                    if ($result/type eq "success") then (
                        <result>
                            <type>success</type>
                            <message>
                                <p>Das Register wurde erfolgreich aktualisiert.</p>
                            </message>
                        </result>
                    )
                    else (
                        <result>
                            <type>warning</type>
                            <message>
                                <p>Beim Aktualisieren ist ein Fehler aufgetreten.</p>
                            </message>
                        </result>
                    )
                )
            (: else if ($status-code eq "403") then (
                <result>
                    <type>warning</type>
                    <message>Die Verbindungsdaten sind nicht korrekt.</message>
                </result>
            ) :)
            else ()
        return
            map { "result" := $result
            (: , "connection-uri" : $connection-uri  :)
        }
        )
    else (
        map {}
        )
};

declare function project-pages:indexes($node as node(), $model as map(*)) as map(*) {
    let  $cuser := config:get-current-user()
    let $cproject := config:project-user-group(config:get-current-project())
    return if (sm:is-dba($cuser) or ($cproject = sm:get-user-groups($cuser))) then (
        let $action := request:get-parameter('action','')
        let $project := config:get-current-project()
        let $index-id := request:get-parameter('index-id','')
        let $index-type := request:get-parameter('index-type','')
        let $index-label := request:get-parameter('index-label','')
        let $connection-id := request:get-parameter('connection-id','')
        let $collection-id := request:get-parameter('collection-id','')
        let $data-collection := request:get-parameter('data-collection','')
        let $data-namespace := request:get-parameter('data-namespace','')
        let $data-node := request:get-parameter('data-node','')
        let $data-xmlid := request:get-parameter('data-xmlid','')
        let $data-span := request:get-parameter('data-span','')
        let $ediarum-index-structure := request:get-parameter('ediarum-index-structure','')
        let $result :=
            if ($action eq 'add-zotero-index') then (
                local:add-zotero-index($index-id, $index-type, $index-label, $connection-id, $collection-id)
            )
            else if ($action eq 'add-project-index') then (
                local:add-project-index($index-id, $index-type, $index-label, $data-collection, $data-namespace, $data-node, $data-xmlid, $data-span)
            )
            else if ($action eq 'remove-index') then (
                local:remove-index($index-id)
            )
            else if ($action eq 'activate-ediarum-index') then (
                local:activate-ediarum-index($index-id, $index-type, $ediarum-index-structure)
            )
            else if ($action eq 'refresh-index-api') then (
                local:refresh-index-api($project)
            )
            else ()
        return
            map { "result" := $result}
        )
    else (
        map {}
        )
};

declare function project-pages:insert-build-properties-table($node as node(), $model as map(*)) as node()* {
    let $file := "/db/apps/ediarum/setup/development/build.properties"
    let $resource := util:binary-to-string(util:binary-doc($file))
    let $lines := tokenize($resource, "\n")
    let $rows :=
        for $line in $lines
        return
            if (contains($line, "=")) then (
                let $variable := normalize-space(substring-before($line, "="))
                let $description := normalize-space(substring-after($line, "="))
                return
                    <tr>
                        <td>{$variable}</td>
                        <td>{$description}</td>
                    </tr>
            ) else ()
    let $table :=
        <table class="table table-hover">
            <row>
                <th>Variable</th>
                <th>Description</th>
            </row>
            { $rows }
        </table>
    return $table
};

declare function project-pages:list-ediarum-indexes($node as node(), $model as map(*)) as node()* {
    let $project-name := config:get-current-project()
    for $ediarum-index-id in config:get-ediarum-index-ids()
        let $label := config:get-ediarum-index-label($ediarum-index-id)
        let $is-active := config:is-ediarum-index-active($project-name, $ediarum-index-id)
        return
        if ($is-active) then (
            <nav class="navbar navbar-default">
                <div class="container-fluid">
                    <div class="navbar-header">
                        <a class="navbar-brand">{$label} {if ($is-active) then (
                            " ", <span class="label label-success">Aktiv</span>
                        )
                        else ()}</a>
                    </div>
                    <div class="navbar-form navbar-right">
                        <div class="btn-group">
                            <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">API-Links <span class="caret"></span>
                            </button>
                            <ul class="dropdown-menu">
                                <li><a href="{substring-before(request:get-url(), request:get-context-path())||request:get-context-path()||"/rest"}/db/projects/{$project-name}/oxygen/ediarum.xql?index={$ediarum-index-id}" target="_blank">GET</a></li>
                                <li><a href="{substring-before(request:get-url(), request:get-context-path())||request:get-context-path()||"/rest"}/db/projects/{$project-name}/oxygen/ediarum.xql?index={$ediarum-index-id}&amp;order=false" target="_blank">GET UNORDERED</a></li>
                            </ul>
                        </div>
                    </div>
                </div>
            </nav>
        )
        else ()
};

declare function project-pages:list-index-items($node as node(), $model as map(*)) as node()* {
    let $project-name := config:get-current-project()
    let $index := config:get-current-index()
    let $collection-id := $index/config:get-parameter("collection-id")
    let $connection-id := config:get-current-zotero-connection-id()
    let $connection := config:get-zotero-connection-by-id($project-name, $connection-id)
    let $zotero-group := $connection/group-id/string()
    let $items := config:get-zotero-collection-items(config:get-current-project(), $connection-id, $collection-id, false())
    return (
        <h2>{count($items)} Einträge</h2>,
        <ul class="list-group">
            {
                for $item in $items
                let $item-map := config:format-zotero-item($item)
                let $badge := <a class="badge" target="_blank" href="https://zotero.org/groups/{$zotero-group}/items/{$item-map('key')}">{$item-map('key')}</a>
                let $class :=
                    if ($item-map("missing-entries")) then
                        "list-group-item list-group-item-warning"
                    else
                        "list-group-item"
                order by lower-case(string($item-map("span"))) ascending
                return
                    <li class="{$class}"><span class="{$item-map('icon')}"/>{" "}{$item-map("span")}{$badge}</li>
            }
        </ul>
    )
};

declare function project-pages:list-indexes($node as node(), $model as map(*)) as node()* {
    let $project-name := config:get-current-project()
    let $indexes := config:get-indexes($project-name)//index
    return
    <div>
        {for $index in $indexes
        let $label := $index/label/string()
        let $id := $index/@id/string()
        let $type := $index/@type/string()
        order by $label
        return
        if ($type eq "ediarum") then () else
        <nav class="navbar navbar-default">
            <div class="container-fluid">
                <div class="navbar-header">
                    <a class="navbar-brand">{$label} ({$type})</a>
                </div>
                <form class="navbar-form navbar-right" action="" method="post">
                    <div class="form-group">
                        <input type="hidden" name="action" value="remove-index"/>
                        <input type="hidden" name="index-id" value="{$id}"/>
                        <button type="submit" class="btn btn-default">Entfernen</button>
                    </div>
                </form>
                <div class="navbar-form navbar-right">
                    <div class="form-group">
                        {if ($type eq 'zotero') then
                            <button type="button" class="btn btn-default"  data-toggle="modal" data-target="#modalNewZoteroIndex" data-id="{$index/@id/string()}" data-label="{$index/label/string()}" data-type="{$index/@type/string()}" data-connection-id="{$index/parameter[@name='connection-id']/@value/string()}" data-collection-id="{$index/parameter[@name='collection-id']/@value/string()}">Bearbeiten</button>
                        else
                            <button type="button" class="btn btn-default"  data-toggle="modal" data-target="#modalNewProjectIndex" data-id="{$index/@id/string()}" data-label="{$index/label/string()}" data-type="{$index/@type/string()}" data-data-collection="{$index/parameter[@name='data-collection']/@value/string()}" data-data-namespace="{$index/parameter[@name='data-namespace']/@value/string()}" data-data-node="{$index/parameter[@name='data-node']/@value/string()}" data-data-xmlid="{$index/parameter[@name='data-xmlid']/@value/string()}" data-data-span="{$index/parameter[@name='data-span']/@value/string()}">Bearbeiten</button>
                        }
                    </div>
                </div>
                <div class="navbar-form navbar-right">
                    <div class="btn-group">
                        <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">API-Links <span class="caret"></span>
                        </button>
                        {if ($type eq 'zotero') then
                            <ul class="dropdown-menu">
                                <li><a href="{substring-before(request:get-url(), request:get-context-path())||request:get-context-path()||"/rest"}/db/projects/{$project-name}/oxygen/ediarum.xql?index={$id}" target="_blank">GET</a></li>
                                <li><a href="{substring-before(request:get-url(), request:get-context-path())||request:get-context-path()||"/rest"}/db/projects/{$project-name}/oxygen/ediarum.xql?index={$id}&amp;action=update" target="_blank">UPDATE</a></li>
                                <li><a href="{substring-before(request:get-url(), request:get-context-path())||request:get-context-path()||"/rest"}/db/projects/{$project-name}/oxygen/ediarum.xql?index={$id}&amp;action=update-get" target="_blank">UPDATE and GET</a></li>
                            </ul>
                        else
                            <ul class="dropdown-menu">
                                <li><a href="{substring-before(request:get-url(), request:get-context-path())||request:get-context-path()||"/rest"}/db/projects/{$project-name}/oxygen/ediarum.xql?index={$id}" target="_blank">GET</a></li>
                            </ul>
                        }
                    </div>
                </div>
            </div>
        </nav>
        }
    </div>
};

declare function project-pages:list-pull-synchronisation-targets($node as node(), $model as map(*)) as node() {
    let $labels := config:get-synchronisation-targets(config:get-current-project())//target[@type eq "pull"]/label
    return
    <div>
        {for $label in $labels
        order by $label
        return
        <nav class="navbar navbar-default">
            <div class="container-fluid">
                <div class="navbar-header">
                    <a class="navbar-brand">{$label}</a>
                </div>
                <form class="navbar-form navbar-right" action="" method="post">
                    <div class="form-group">
                        <input type="hidden" name="action" value="remove-synchronisation"/>
                        <input type="hidden" name="synch-name" value="{$label}"/>
                        <input type="hidden" name="synch-type" value="pull"/>
                        <button type="submit" class="btn btn-default">Entfernen</button>
                    </div>
                </form>
                <div class="navbar-form navbar-right">
                    <div class="form-group">
                        <button type="button" class="btn btn-default"  data-toggle="modal" data-target="#modalNewPullSynchronisation" data-synch-name="{$label}" data-target-resource="{local:get-synchronisation-parameter($label, 'pull', 'target-resource')}" data-target-group-name="{local:get-synchronisation-parameter($label, 'pull', 'target-group-name')}" data-target-mode="{local:get-synchronisation-parameter($label, 'pull', 'target-mode')}" data-source-server="{local:get-synchronisation-parameter($label, 'pull', 'source-server')}" data-source-resource="{local:get-synchronisation-parameter($label, 'pull', 'source-resource')}" data-source-user="{local:get-synchronisation-parameter($label, 'pull', 'source-user')}" data-source-password="{local:get-synchronisation-parameter($label, 'pull', 'source-password')}">Bearbeiten</button>
                    </div>
                </div>
                <form class="navbar-form navbar-right" action="" onsubmit="$('#pleaseWaitDialog').modal()" method="post">
                    <div class="form-group">
                        <input type="hidden" name="action" value="do-synchronisation"/>
                        <input type="hidden" name="synch-name" value="{$label}"/>
                        <input type="hidden" name="synch-type" value="pull"/>
                        <button type="submit" class="btn btn-default">Ausführen!</button>
                    </div>
                </form>
            </div>
        </nav>
        }
    </div>
};

declare function project-pages:list-push-synchronisation-targets($node as node(), $model as map(*)) as node() {
    let $labels := config:get-synchronisation-targets(config:get-current-project())//target[@type eq "push"]/label
    return
    <div>
        {for $label in $labels
        order by $label
        return
        <nav class="navbar navbar-default">
            <div class="container-fluid">
                <div class="navbar-header">
                    <a class="navbar-brand">{$label}</a>
                </div>
                <form class="navbar-form navbar-right" action="" method="post">
                    <div class="form-group">
                        <input type="hidden" name="action" value="remove-synchronisation"/>
                        <input type="hidden" name="synch-name" value="{$label}"/>
                        <input type="hidden" name="synch-type" value="push"/>
                        <button type="submit" class="btn btn-default">Entfernen</button>
                    </div>
                </form>
                <div class="navbar-form navbar-right">
                    <div class="form-group">
                        <button type="button" class="btn btn-default"  data-toggle="modal" data-target="#modalNewPushSynchronisation" data-synch-name="{$label}" data-source-resource="{local:get-synchronisation-parameter($label, 'push', 'source-resource')}" data-target-server="{local:get-synchronisation-parameter($label, 'push', 'target-server')}" data-target-resource="{local:get-synchronisation-parameter($label, 'push', 'target-resource')}" data-target-user="{local:get-synchronisation-parameter($label, 'push', 'target-user')}" data-target-password="{local:get-synchronisation-parameter($label, 'push', 'target-password')}">Bearbeiten</button>
                    </div>
                </div>
                <form class="navbar-form navbar-right" action="" onsubmit="$('#pleaseWaitDialog').modal()" method="post">
                    <div class="form-group">
                        <input type="hidden" name="action" value="do-synchronisation"/>
                        <input type="hidden" name="synch-name" value="{$label}"/>
                        <input type="hidden" name="synch-type" value="push"/>
                        <button type="submit" class="btn btn-default">Ausführen!</button>
                    </div>
                </form>
            </div>
        </nav>
        }
    </div>
};

declare function project-pages:list-scheduler-jobs($node as node(), $model as map(*)) as node() {
    let $jobs := config:get-scheduler-jobs()//project[@name=config:get-current-project()]/job
    return
    <div>
        {for $job in $jobs
        let $id := $job/@id/string()
        let $name := $job/@name/string()
        let $cron := $job/@cron/string()
        let $type := $job/@type/string()
        let $xquery := $job/@xquery/string()
        let $params :=
            for $param in $job/parameter
            return
                attribute {"data-scheduler-job-param-"||$param/@name/string()} { $param/@value/string() }
        order by $name
        return
        <nav class="navbar navbar-default">
            <div class="container-fluid">
                <div class="navbar-header">
                    <span class="navbar-brand">{$name}</span>
                </div>
                <p class="navbar-text">{$type}, {$cron}</p>
                <form class="navbar-form navbar-right" action="" method="post">
                    <div class="form-group">
                        <input type="hidden" name="action" value="remove-scheduler-job"/>
                        <input type="hidden" name="scheduler-job-id" value="{$id}"/>
                        <button type="submit" class="btn btn-default">Entfernen</button>
                    </div>
                </form>
                <div class="navbar-form navbar-right">
                    <div class="form-group">
                        <button type="button" class="btn btn-default"  data-toggle="modal" data-target="#modalNewSchedulerJob" data-scheduler-job-id="{$id}" data-scheduler-job-name="{$name}" data-scheduler-job-type="{$type}" data-scheduler-job-xquery="{$xquery}" data-scheduler-job-cron="{$cron}">{$params}Bearbeiten</button>
                    </div>
                </div>
            </div>
        </nav>
        }
    </div>
};

declare function project-pages:list-zotero-connections($node as node(), $model as map(*)) as node()* {
    let $connections := config:get-zotero-connections(config:get-current-project())//connection
    return
    <div>
        {for $connection in $connections
        let $label := $connection/label/string()
        let $id := $connection/@id/string()
        order by $label
        return
        <nav class="navbar navbar-default">
            <div class="container-fluid">
                <!-- Brand and toggle get grouped for better mobile display -->
                <div class="navbar-header">
                    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-collapse-{$label}" aria-expanded="false">
                        <span class="sr-only">Toggle navigation</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>
                    <a class="navbar-brand">{$label}</a>
                </div>
                <div class="collapse navbar-collapse" id="navbar-collapse-{$label}">
                    <div class="nav navbar-nav navbar-right">
                        <form class="navbar-form navbar-left" action="" onsubmit="$('#pleaseWaitDialog').modal()" method="post">
                            <input type="hidden" name="action" value="update-zotero-connection"/>
                            <input type="hidden" name="connection-id" value="{$id}"/>
                            <button type="submit" class="btn btn-default">Update!</button>
                        </form>
                        <form class="navbar-form navbar-left" action="" onsubmit="$('#pleaseWaitDialog').modal()" method="post">
                            <input type="hidden" name="action" value="synch-zotero-connection"/>
                            <input type="hidden" name="connection-id" value="{$id}"/>
                            <button type="submit" class="btn btn-default">Synchronisieren!</button>
                        </form>
                        <button type="button" class="btn btn-default navbar-btn navbar-left"  data-toggle="modal" data-target="#modalNewZoteroConnection" data-connection-id="{$connection/@id/string()}" data-connection-name="{$connection/label/string()}" data-group-id="{$connection/group-id/string()}" data-api-key="{$connection/api-key/string()}" data-style="{$connection/style/string()}">Bearbeiten</button>
                        <form class="navbar-form navbar-left" action="" method="post">
                            <input type="hidden" name="action" value="remove-zotero-connection"/>
                            <input type="hidden" name="connection-id" value="{$id}"/>
                            <button type="submit" class="btn btn-default">Entfernen</button>
                        </form>
                    </div>
                </div>
            </div>
        </nav>
        }
    </div>,
    <nav class="navbar navbar-default">
        <div class="container-fluid">
            <div class="navbar-header">
                <span class="navbar-brand">Neue Verbindung</span>
            </div>
            <div class="navbar-form">
                <div class="form-group">
                    <button type="button" class="btn btn-default" data-toggle="modal" data-target="#modalNewZoteroConnection" data-connection-id="{util:uuid()}">Hinzufügen!</button>
                </div>
            </div>
        </div>
    </nav>
};

declare function project-pages:project-admin-list($node as node(), $model as map(*)) as node() {
    let $user := sm:get-group-managers(config:project-user-group(config:get-current-project()))
    return
    <div>
        {for $u in $user
        order by $u
        return
        <nav class="navbar navbar-default">
          <div class="container-fluid">
            <div class="navbar-header">
              <a class="navbar-brand">{$u}</a>
            </div>
            <div class="navbar-collapse navbar-right">
                <form action="" method="post">
                    <!--input type="hidden" name="project" value="{$project}"/-->
                    <input type="hidden" name="action" value="remove-project-admin"/>
                    <input type="hidden" name="user-name" value="{$u}"/>
                    <button type="submit" class="btn btn-default navbar-btn">Entfernen</button>
                </form>
            </div>
          </div>
        </nav>
        }
    </div>
};

declare function project-pages:refresh-index-api($node as node(), $model as map(*)) as node() {
    if (local:ediarum-index-api-is-up-to-date(config:get-current-project())) then (
        <div class="alert alert-success">
            <span>Die Schnittstelle zu den Registern ist aktuell.</span>
        </div>
        )
    else (
        <form class="alert alert-warning" action="" method="post">
            <strong>Die Schnittstelle zu den Registern ist nicht mehr aktuell.</strong>
            <input type="hidden" name="action" value="refresh-index-api"/>
            <button type="submit" class="btn btn-warning"><span>Update durchführen!</span></button>
        </form>
        )
};

declare function project-pages:scheduler($node as node(), $model as map(*)) as map(*) {
    let  $cuser := config:get-current-user()
    let $cproject := config:project-user-group(config:get-current-project())
    return if (sm:is-dba($cuser) or ($cproject = sm:get-user-groups($cuser))) then (
        let $action := request:get-parameter('action','')
        let $scheduler-job-id := request:get-parameter('scheduler-job-id','')
        let $parameter-names :=
            for $param in request:get-parameter-names()
            return
                if (starts-with($param, "scheduler-job-param-")) then
                    $param
                else ()
        let $scheduler-job := map {
            "id" : $scheduler-job-id,
            "name" : request:get-parameter('scheduler-job-name',''),
            "cron" : request:get-parameter('scheduler-job-cron',''),
            "type" : request:get-parameter('scheduler-job-type',''),
            "xquery" : request:get-parameter('scheduler-job-xquery',''),
            "params" : map:new (
                for $param in $parameter-names
                return
                    map:entry(substring-after($param, "scheduler-job-param-"), request:get-parameter($param, ''))
            )
        }
        let $result :=
            if ($action eq 'add-scheduler-job') then (
                local:add-scheduler-job($scheduler-job)
            ) else if ($action eq 'remove-scheduler-job') then (
                local:remove-scheduler-job($scheduler-job-id)
            ) else ()
        return
            map{ "result" := $result }
    ) else (
        map{}
    )
};

declare function project-pages:select-box-with-zotero-connections($node as node(), $model as map(*)) as node() {
    <select id="connection-id-select-box" class="form-control" name="connection-id">
        {
            let $connections := config:get-zotero-connections(config:get-current-project())//connection
            return
                for $connection in $connections
                let $label := $connection/label/string()
                let $id := $connection/@id/string()
                order by $label
                return
                    <option value="{$id}">{$label}</option>
        }
    </select>
};

declare function project-pages:select-box-with-ediarum-indexes($node as node(), $model as map(*)) as node() {
    <select class="form-control" name="index-id" id="select-ediarum-index-id">
        {
            let $project-name := config:get-current-project()
            for $ediarum-index-id in config:get-ediarum-index-ids() return
                if (config:is-ediarum-index-active($project-name, $ediarum-index-id)) then
                    ()
                else (
                    try {
                        let $ediarum-index-label := config:get-ediarum-index-label($ediarum-index-id)
                        let $ediarum-index-file := config:get-ediarum-index-file($ediarum-index-id)
                        let $ediarum-index-collection := config:get-ediarum-index-collection($ediarum-index-id)
                        return
                            <option value="{$ediarum-index-id}" data-index-type="index" data-index-file="{$ediarum-index-file}" data-index-collection="{$ediarum-index-collection}">{$ediarum-index-label}</option>
                    } catch * {
                        let $ediarum-index-label := config:get-ediarum-index-label($ediarum-index-id)
                        return
                            <option value="{$ediarum-index-id}" data-index-type="data">{$ediarum-index-label}</option>
                    }
            )
        }
    </select>
};

declare function project-pages:select-box-with-zotero-connection-collections($node as node(), $model as map(*)) as node()* {
    <select class="form-control" name="collection-id" id="select-collection-name">
        {
            <option value=""></option>,
            let $connections := config:get-zotero-connections(config:get-current-project())//connection
            return
                for $connection in $connections
                let $connection-id := $connection/@id/string()
                return
                    let $collections := collection(config:get-zotero-collection(config:get-current-project(), $connection-id))//collections/collection
                    for $collection in $collections
                    let $name := $collection/@name/string()
                    let $key := $collection/@key/string()
                    order by $name
                    return
                        <option value="{$key}" class="option-for-connection-{$connection-id}">{$name}</option>
        }
    </select>
};

declare function project-pages:synchronisation($node as node(), $model as map(*)) as map(*) {
    let  $cuser := config:get-current-user()
    let $cproject := config:project-user-group(config:get-current-project())
    return if (sm:is-dba($cuser) or ($cproject = sm:get-user-groups($cuser))) then (
        let $action := request:get-parameter('action','')
        let $project := config:get-current-project()
        let $synch-name := request:get-parameter('synch-name','')
        let $synch-type := request:get-parameter('synch-type','')
        let $source-server := request:get-parameter('source-server','')
        let $source-user :=  request:get-parameter('source-user','')
        let $source-password :=  request:get-parameter('source-password','')
        let $source-resource := request:get-parameter('source-resource','')
        let $target-server := request:get-parameter('target-server','')
        let $target-resource := request:get-parameter('target-resource','')
        let $target-user := request:get-parameter('target-user','')
        let $target-password := request:get-parameter('target-password','')
        let $target-group-name := request:get-parameter('target-group-name', '')
        let $target-mode := request:get-parameter('target-mode', '')
        let $result :=
            if ($action eq 'add-push-synchronisation') then (
                local:create-new-push-synchronisation($synch-name, $synch-type, $source-resource,
                    $target-server, $target-resource, $target-user, $target-password)
                )
            else if ($action eq 'do-synchronisation') then (
                config:do-synchronisation($synch-name, $synch-type, $project)
                )
            else if ($action eq 'remove-synchronisation') then (
                local:remove-synchronisation($synch-name, $synch-type)
                )
            else if ($action eq 'add-pull-synchronisation') then (
                local:create-new-pull-synchronisation($synch-name, $synch-type,
                    $source-server, $source-resource, $source-user, $source-password,
                    $target-resource, $target-group-name, $target-mode)
                )
            else ()
        return
            map{ "result" := $result }
        )
    else
        map{}
};

declare function project-pages:user($node as node(), $model as map(*)) as map(*) {
    let  $cuser := config:get-current-user()
    let $cproject := config:project-user-group(config:get-current-project())
    return if (sm:is-dba($cuser) or ($cproject = sm:get-user-groups($cuser))) then (
        let $action := request:get-parameter('action','')
        let $user-name := request:get-parameter('user-name','')
        let $password := request:get-parameter('password','')
        let $result :=
            if ($action eq 'new-user') then (
                local:create-new-user($user-name, $password)
                )
            else if ($action eq 'delete-user') then (
                local:delete-user($user-name)
                )
            else if ($action eq 'add-project-admin') then (
                local:add-project-admin($user-name)
                )
            else if ($action eq 'remove-project-admin') then (
                local:remove-project-admin($user-name)
                )
            else if ($action eq 'change-user-pass') then (
                local:change-user-pass($user-name, $password)
                )
            else ()
        return
            map { "result" := $result}
        )
    else (
        map {}
        )
};

declare function project-pages:user-list($node as node(), $model as map(*)) as node() {
    let $user := sm:get-group-members(config:project-user-group(config:get-current-project()))
    return
    <div>
        {for $u in $user
        order by $u
        return
        <nav class="navbar navbar-default">
            <div class="container-fluid">
                <div class="navbar-header">
                  <a class="navbar-brand">{$u}</a>
                </div>
                <form class="navbar-form navbar-right" action="" method="post">
                    <div class="form-group">
                        <!--input type="hidden" name="project" value="{$project}"/-->
                        <input type="hidden" name="action" value="delete-user"/>
                        <input type="hidden" name="user-name" value="{$u}"/>
                        {
                        (: Projektmanager dürfen nicht gelöscht werden. :)
                        if (index-of(sm:get-group-managers(config:project-user-group(config:get-current-project())), $u)>0) then ()
                        else
                            <button type="submit" class="btn btn-default">Löschen</button>
                        }
                    </div>
                </form>
                <div class="navbar-form navbar-right">
                    <div class="form-group">
                        <button type="button" class="btn btn-default" data-toggle="modal" data-target="#modalChangeUserPass" data-user-name="{$u}">Passwort ändern</button>
                    </div>
                </div>
            </div>
        </nav>
        }
    </div>
};

declare function project-pages:zotero($node as node(), $model as map(*)) as map(*) {
    let  $cuser := config:get-current-user()
    let $cproject := config:project-user-group(config:get-current-project())
    return if (sm:is-dba($cuser) or ($cproject = sm:get-user-groups($cuser))) then (
        let $action := request:get-parameter('action','')
        let $project := config:get-current-project()
        let $connection-id := request:get-parameter('connection-id','')
        let $connection-name := request:get-parameter('connection-name','')
        let $group-id := request:get-parameter('group-id','')
        let $api-key := request:get-parameter('api-key','')
        let $style := request:get-parameter('style','')
        let $result :=
            if ($action eq 'add-zotero-connection') then (
                local:add-zotero-connection($connection-id, $connection-name, $group-id, $api-key, $style)
                )
            else if ($action eq 'remove-zotero-connection') then (
                local:remove-zotero-connection($connection-id)
            )
            else if ($action eq 'synch-zotero-connection') then (
                local:synch-zotero-connection-in-blocks($connection-id)
            )
            else if ($action eq 'update-zotero-connection') then (
                local:update-zotero-connection-in-blocks($connection-id)
            )
            else ()
        return
            map { "result" := $result}
        )
    else (
        map {}
        )
};

declare function project-pages:zip-development-collection($node as node(), $model as map(*)) as map(*) {
    local:zip-development-collection(),
    let $map := map {}
    return $map
};

declare function local:activate-ediarum-index($index-id as xs:string, $index-type as xs:string, $ediarum-index-structure as xs:string) as node() {
    let $current-project := config:get-current-project()
    let $config-file := doc(config:get-config-file($current-project))
    let $parameters :=
        <parameters>
            <param name="index-id" value="{$index-id}"/>
            <param name="index-type" value="{$index-type}"/>
            <param name="index-label" value="{config:get-ediarum-index-label($index-id)}"/>
            <param name="index-status" value="active"/>
        </parameters>
    let $result := document {transform:transform($config-file, doc("project-pages/add-index.xsl"), $parameters)}
    let $index-file-name := try { config:get-ediarum-index-file($index-id) } catch * { "" }
    let $index-collection := try { config:get-ediarum-index-collection($index-id) } catch * { "" }
    let $result :=
        if ($index-file-name eq "" or $index-collection eq "") then (
            <result>
                {config:update-file(config:get-config-file($current-project), $result)}
                <type>success</type>
                <message>Das Register wurde aktiviert</message>
            </result>
        )
        else (
            let $copy-files :=
                switch($ediarum-index-structure)
                case "one-file" return (
                    config:copy($config:ediarum-db-path||"/setup/"||$index-file-name, config:get-data-collection($current-project)||"/"||$index-file-name, config:project-user-group($current-project), "rw-rw----")
                )
                case "one-file-per-letter" return (
                    not(false() = (
                        let $abc := (
                            let $string := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                            for $i in (1 to string-length($string))
                            return
                            substring($string, $i, 1)
                        )
                        for $char in $abc
                        return
                            config:copy($config:ediarum-db-path||"/setup/"||$index-file-name, config:get-data-collection($current-project)||"/"||$index-collection||"/"||$char||".xml", config:project-user-group($current-project), "rw-rw----")
                    ))
                )
                default return
                    false()
            return
            if ($copy-files) then
                <result>
                    {config:update-file(config:get-config-file($current-project), $result)}
                    <type>success</type>
                    <message>Die Registerdateien wurden kopiert und das Register aktiviert.</message>
                </result>
            else
                <result>
                    <type>warning</type>
                    <message>Das Register konnte nicht aktiviert werden.</message>
                </result>
        )
    return
        $result
};

declare function local:add-project-admin($user-name as xs:string) as node() {
    let $current-project := config:get-current-project()
    return
    if (index-of($config:protected-users, $user-name) > 0) then (
        (: Der Nutzer ist geschützt. :)
        <result>
            <type>warning</type>
            <message>{concat('Der Nutzer "', $user-name, '" ist geschützt!')}</message>
        </result>
        )
    else if (sm:user-exists($user-name) and index-of(sm:get-group-managers(config:project-user-group($current-project)), $user-name) > 0) then (
        (: Der Nutzer ist im Projekt als Manager vorhanden. :)
        <result>
            <type>warning</type>
            <message>{concat('Der Nutzer "', $user-name, '" ist bereits Projektmanager!')}</message>
        </result>
        )
    else if (sm:user-exists($user-name)) then (
        (: Der Nutzer existiert schon. :)
        <result>
            {sm:add-group-member(config:project-user-group($current-project), $user-name)}
            {sm:add-group-manager(config:project-user-group($current-project), $user-name)}
            <type>success</type>
            <message>{concat('Der Nutzer "', $user-name, '" wurde zum Projektmanager ernannt!')}</message>
        </result>
        )
    else (
        (: Der Nutzer ist noch nicht vorhanden. :)
        <result>
            <type>warning</type>
            <message>{concat('Der Nutzer "',$user-name,'" ist noch nicht vorhanden!')}</message>
        </result>
        )
};

declare function local:add-project-index($index-id as xs:string, $index-type as xs:string, $index-label as xs:string, $data-collection as xs:string, $data-namespace as xs:string, $data-node as xs:string, $data-xmlid as xs:string, $data-span as xs:string) as node() {
    let $current-project := config:get-current-project()
    let $config-file := doc(config:get-config-file(config:get-current-project()))
    let $parameters :=
        <parameters>
            <param name="index-id" value="{$index-id}"/>
            <param name="index-type" value="{$index-type}"/>
            <param name="index-label" value="{$index-label}"/>
            <param name="data-collection" value="{$data-collection}"/>
            <param name="data-namespace" value="{$data-namespace}"/>
            <param name="data-node" value="{$data-node}"/>
            <param name="data-xmlid" value="{$data-xmlid}"/>
            <param name="data-span" value="{$data-span}"/>
        </parameters>
    let $result := document {transform:transform($config-file, doc("project-pages/add-index.xsl"), $parameters)}
    return
        <result>
            {config:update-file(config:get-config-file($current-project), $result)}
            <type>success</type>
            <message>Das Register wurde eingerichtet</message>
        </result>
};

declare function local:add-scheduler-job($scheduler-job as map(*)) as node() {
    let $config := doc(config:get-config-file(config:get-current-project()))
    let $job :=
        element job {
            attribute id {$scheduler-job("id")},
            attribute name {$scheduler-job("name")},
            attribute cron {$scheduler-job("cron")},
            attribute type {$scheduler-job("type")},
            attribute xquery {$scheduler-job("xquery")},
            let $params := $scheduler-job("params")
            for $param in map:keys($params)
            return
                element parameter {
                    attribute name {$param},
                    attribute value {$params($param)}
                }
            }
    return
        <result>
            {if (exists(index-of($config//scheduler/job/@id/string(), $scheduler-job("id")))) then (
                update replace $config//scheduler/job[@id=$scheduler-job("id")] with $job
            ) else (
                update insert $job into $config//scheduler
            )
            }
            <type>success</type>
            <message>Scheduler-Aufgabe wurde eingerichtet.</message>
        </result>
};

declare function local:add-zotero-connection($connection-id as xs:string, $connection-name as xs:string, $group-id as xs:string, $api-key as xs:string, $style as xs:string) as node() {
    let $current-project := config:get-current-project()
    let $config-file := doc(config:get-config-file(config:get-current-project()))
    let $parameters :=
        <parameters>
            <param name="uuid" value="{$connection-id}"/>
            <param name="connection-name" value="{$connection-name}"/>
            <param name="group-id" value="{$group-id}"/>
            <param name="api-key" value="{$api-key}"/>
            <param name="style" value="{$style}"/>
        </parameters>
    let $result := document {transform:transform($config-file, doc("project-pages/add-zotero-connection.xsl"), $parameters)}
    return
        <result>
            {config:update-file(config:get-config-file($current-project), $result),
            config:mkcol-in-project($current-project, "external_data", "zotero", config:project-user-group($current-project), "rwxrwx---"),
            config:mkcol-in-project($current-project, "external_data/zotero", $connection-name, config:project-user-group($current-project), "rwxrwx---")}
            <type>success</type>
            <message>Die Verbindung wurde eingerichtet</message>
        </result>
};

declare function local:add-zotero-index($index-id as xs:string, $index-type as xs:string, $index-label as xs:string, $connection-id as xs:string, $collection-id as xs:string) as node() {
    let $current-project := config:get-current-project()
    let $config-file := doc(config:get-config-file(config:get-current-project()))
    let $parameters :=
        <parameters>
            <param name="index-id" value="{$index-id}"/>
            <param name="index-type" value="{$index-type}"/>
            <param name="index-label" value="{$index-label}"/>
            <param name="connection-id" value="{$connection-id}"/>
            <param name="collection-id" value="{$collection-id}"/>
        </parameters>
    let $result := document {transform:transform($config-file, doc("project-pages/add-index.xsl"), $parameters)}
    return
        <result>
            {config:update-file(config:get-config-file($current-project), $result)}
            <type>success</type>
            <message>Das Register wurde eingerichtet</message>
        </result>
};

declare function local:change-user-pass($user-name as xs:string, $password as xs:string) {
    let $current-project := config:get-current-project()
    return
    if (index-of($config:protected-users, $user-name) > 0) then (
        (: Der Nutzer ist geschützt. :)
        <result>
            <type>warning</type>
            <message>{concat('Der Nutzer "', $user-name, '" ist geschützt!')}</message>
        </result>
        )
    else if (sm:user-exists($user-name) and index-of(sm:get-user-groups($user-name), config:project-user-group($current-project)) > 0) then (
        (: Der Nutzer ist im Projekt vorhanden. :)
        <result>
            {sm:passwd($user-name, $password)}
            <type>success</type>
            <message>{concat('Das Passwort von "', $user-name, '" wurde neu gesetzt!')}</message>
        </result>
        )
    else (
        (: Der Nutzer ist noch nicht vorhanden. :)
        <result>
            <type>warning</type>
            <message>{concat('Der Nutzer "',$user-name,'" gehört nicht zum Projekt!')}</message>
        </result>
        )
};

declare function local:create-new-pull-synchronisation($synch-name as xs:string, $synch-type as xs:string, $source-server as xs:string, $source-resource as xs:string, $source-user as xs:string, $source-password as xs:string, $target-resource as xs:string, $target-group-name as xs:string, $target-mode as xs:string) as node() {
    let $config-file := doc(config:get-config-file(config:get-current-project()))
    let $parameters :=
        <parameters>
            <param name="synch-name" value="{$synch-name}"/>
            <param name="synch-type" value="{$synch-type}"/>
            <param name="source-server" value="{$source-server}"/>
            <param name="source-resource" value="{$source-resource}"/>
            <param name="source-user" value="{$source-user}"/>
            <param name="source-password" value="{$source-password}"/>
            <param name="target-resource" value="{$target-resource}"/>
            <param name="target-group-name" value="{$target-group-name}"/>
            <param name="target-mode" value="{$target-mode}"/>
        </parameters>
    let $result := document {transform:transform($config-file, doc("project-pages/add-synchronisation.xsl"), $parameters)}
    return
    <result>
        {config:update-file(config:get-config-file(config:get-current-project()), $result)}
        <type>success</type>
        <message>Der Vorgang {$synch-name} wurde eingerichtet!</message>
    </result>
};

declare function local:create-new-push-synchronisation($synch-name as xs:string, $synch-type as xs:string, $source-resource as xs:string, $target-server as xs:string, $target-resource as xs:string, $target-user as xs:string, $target-password as xs:string) as node() {
    let $config-file := doc(config:get-config-file(config:get-current-project()))
    let $parameters :=
        <parameters>
            <param name="synch-name" value="{$synch-name}"/>
            <param name="synch-type" value="{$synch-type}"/>
            <param name="source-resource" value="{$source-resource}"/>
            <param name="target-server" value="{$target-server}"/>
            <param name="target-resource" value="{$target-resource}"/>
            <param name="target-user" value="{$target-user}"/>
            <param name="target-password" value="{$target-password}"/>
        </parameters>
    let $result := document {transform:transform($config-file, doc("project-pages/add-synchronisation.xsl"), $parameters)}
    return
    <result>
        {config:update-file(config:get-config-file(config:get-current-project()), $result)}
        <type>success</type>
        <message>Der Vorgang {$synch-name} wurde eingerichtet!</message>
    </result>
};

declare function local:create-new-user($user-name as xs:string, $password as xs:string) as node() {
    let $current-project := config:get-current-project()
    return
    if (index-of($config:protected-users, $user-name) > 0) then (
        (: Der Nutzer ist geschützt. :)
        <result>
            <type>warning</type>
            <message>{concat('Der Nutzer "', $user-name, '" ist geschützt!')}</message>
        </result>
        )
    else if (sm:user-exists($user-name) and index-of(sm:get-user-groups($user-name), config:project-user-group($current-project)) > 0) then (
        (: Der Nutzer ist im Projekt vorhanden. :)
        <result>
            {sm:add-group-member(config:project-user-group($current-project), $user-name)}
            <type>warning</type>
            <message>{concat('Der Nutzer "', $user-name, '" ist bereits im Projekt vorhanden!')}</message>
        </result>
        )
    else if (sm:user-exists($user-name)) then (
        (: Der Nutzer existiert schon. :)
        <result>
            {sm:add-group-member(config:project-user-group($current-project), $user-name)}
            <type>success</type>
            <message>{concat('Der Nutzer "', $user-name, '" wurde dem Projekt hinzugefügt!')}</message>
        </result>
        )
    else (
        (: Der Nutzer ist noch nicht vorhanden. :)
        <result>
            {sm:create-account($user-name, $password, config:project-user-group($current-project), ())}
            {sm:set-umask($user-name, 0007)}
            <type>success</type>
            <message>{concat('Der Nutzer "',$user-name,'" wurde erstellt!')}</message>
        </result>
        )
};

declare function local:delete-user($user-name as xs:string) as node() {
    let $current-project := config:get-current-project()
    return
    if (index-of($config:protected-users, $user-name) > 0) then
        <result>
            (: Der Nutzer ist geschützt. :)
            <type>warning</type>
            <message>{concat('Der Nutzer "', $user-name, '" ist geschützt!')}</message>
        </result>
    else if (not(sm:user-exists($user-name))) then
        (: Der Nutzer ist nicht vorhanden. :)
        <result>
            <type>warning</type>
            <message>{concat('Der Nutzer "', $user-name, '" existiert nicht!')}</message>
        </result>
    else if (index-of(sm:get-user-groups($user-name), config:project-user-group($current-project)) > 0 and count(sm:get-user-groups($user-name)) > 1) then
        <result>
            (: Der Nutzer ist unter anderem in diesem Projekt vorhanden. :)
            {sm:remove-group-member(config:project-user-group(config:get-current-project()), $user-name)}
            <type>success</type>
            <message>{concat('Der Nutzer "', $user-name, '" wurde aus dem Projekt entfernt!')}</message>
        </result>
    else if (index-of(sm:get-user-groups($user-name), config:project-user-group($current-project)) > 0) then
        <result>
            (: Der Nutzer ist nur in diesem Projekt vorhanden. :)
            {sm:remove-account($user-name)}
            <type>success</type>
            <message>{concat('Der Nutzer "', $user-name, '" wurde entfernt!')}</message>
        </result>
    else
        <result>
            (: Der Nutzer ist nicht in diesem Projekt vorhanden. :)
            <type>warning</type>
            <message>{concat('Der Nutzer "', $user-name, '" ist nicht Mitglied des Projekts!')}</message>
        </result>
};

declare function local:ediarum-index-api-is-up-to-date($project-name as xs:string) as xs:boolean {
    let $project-api-version := util:eval(xs:anyURI($config:projects-path||"/"||$project-name||$config:project-index-api-path||$config:ediarum-index-api-file), false(), (xs:QName("show-version"),"show"))
    let $current-api-version := util:eval(xs:anyURI($config:ediarum-db-path||$config:ediarum-index-api-path||$config:ediarum-index-api-file), false(), (xs:QName("show-version"),"show"))
    return
        $project-api-version=$current-api-version
};

declare function local:get-synchronisation-parameter($synch-name as xs:string, $synch-type as xs:string, $synch-parameter as xs:string) as xs:string? {
    let $target := config:get-synchronisation-targets(config:get-current-project())//target[label=$synch-name][@type=$synch-type]
    return
    string($target/*[local-name()=$synch-parameter])
};

declare function local:get-xquery-external-parameter($xquery as xs:string){
    let $resource := util:binary-to-string(util:binary-doc($xquery))
    let $lines := tokenize($resource, "\n")
    let $params := map:new (
        for $line in $lines
        return
            if (starts-with($line, "declare variable ") and contains($line, " external;")) then (
                let $variable := substring-before(substring-after($line, " $"), " ")
                let $description := substring-before(substring-after($line, "(: "), " :)")
                return
                    map:entry($variable,""|| $description ||"")
            ) else ()
    )
    return
    "{" ||
        string-join(
            for-each(map:keys($params), function($key) {
                " '"|| $key ||"' : '"|| $params($key) ||"'"
            })
            , ", "
        )
        || " }"
};

declare function local:refresh-index-api($project-name as xs:string) {
    let $source-collection-uri := $config:ediarum-db-path||$config:ediarum-index-api-path
    let $target-collection-uri := $config:projects-path||"/"||$project-name||$config:project-index-api-path
    let $resource := $config:ediarum-index-api-file
    let $group-name := "oxygen"
    let $permissions := "rwsr-x---"
    return (
        xmldb:copy($source-collection-uri, $target-collection-uri, $resource),
        sm:chgrp(xs:anyURI($target-collection-uri||$resource), $group-name),
        sm:chmod(xs:anyURI($target-collection-uri||$resource), $permissions)
    )
};

declare function local:remove-index($index-id as xs:string) {
    let $config-file := doc(config:get-config-file(config:get-current-project()))
    let $parameters :=
        <parameters>
            <param name="index-id" value="{$index-id}"/>
        </parameters>
    let $result := document {transform:transform($config-file, doc("project-pages/remove-index.xsl"), $parameters)}
    return
    <result>
        {config:update-file(config:get-config-file(config:get-current-project()), $result)}
        <type>success</type>
        <message>Der Index "{$index-id}" wurde entfernt!</message>
    </result>
};

declare function local:remove-scheduler-job($job-id as xs:string) as node() {
    let $config := doc(config:get-config-file(config:get-current-project()))
    return
        if (exists(index-of($config//scheduler/job/@id/string(), $job-id))) then (
            <result>
                {update delete $config//scheduler/job[@id=$job-id]}
                <type>success</type>
                <message>Scheduler-Aufgabe wurde entfernt.</message>
            </result>
        ) else (
            <result>
                <type>warning</type>
                <message>Scheduler-Aufgabe konnte nicht entfernt werden.</message>
            </result>
        )
};

declare function local:remove-synchronisation($synch-name as xs:string, $synch-type as xs:string) as node() {
    let $config-file := doc(config:get-config-file(config:get-current-project()))
    let $parameters :=
        <parameters>
            <param name="synch-name" value="{$synch-name}"/>
            <param name="synch-type" value="{$synch-type}"/>
        </parameters>
    let $result := document {transform:transform($config-file, doc("project-pages/remove-synchronisation.xsl"), $parameters)}
    return
    <result>
        {config:update-file(config:get-config-file(config:get-current-project()), $result)}
        <type>success</type>
        <message>Der Vorgang "{$synch-name}" wurde entfernt!</message>
    </result>
};

declare function local:remove-project-admin($user-name as xs:string) as node() {
    let $current-project := config:get-current-project()
    return
    if (index-of($config:protected-users, $user-name) > 0) then
        <result>
            (: Der Nutzer ist geschützt. :)
            <type>warning</type>
            <message>{concat('Der Nutzer "', $user-name, '" ist geschützt!')}</message>
        </result>
    else if (not(sm:user-exists($user-name))) then
        (: Der Nutzer ist nicht vorhanden. :)
        <result>
            <type>warning</type>
            <message>{concat('Der Nutzer "', $user-name, '" existiert nicht!')}</message>
        </result>
    else if (index-of(sm:get-group-managers(config:project-user-group($current-project)), $user-name) > 0) then
        <result>
            (: Der Nutzer ist in diesem Projekt als Manager vorhanden. :)
            {sm:remove-group-manager(config:project-user-group(config:get-current-project()), $user-name)}
            <type>success</type>
            <message>{concat('Der Nutzer "', $user-name, '" wurde aus der Liste der Manager entfernt!')}</message>
        </result>
    else
        <result>
            (: Der Nutzer ist nicht in diesem Projekt als Manager vorhanden. :)
            <type>warning</type>
            <message>{concat('Der Nutzer "', $user-name, '" ist kein Manager des Projekts!')}</message>
        </result>
};

declare function local:remove-zotero-connection($connection-id as xs:string) {
    let $project-name := config:get-current-project()
    let $config-file := doc(config:get-config-file($project-name))
    let $connection-name := config:get-zotero-connection-by-id($project-name, $connection-id)/config:zotero-connection-get-name()
    let $parameters :=
        <parameters>
            <param name="connection-id" value="{$connection-id}"/>
        </parameters>
    let $result := document {transform:transform($config-file, doc("project-pages/remove-zotero-connection.xsl"), $parameters)}
    return
    <result>
        {config:update-file(config:get-config-file(config:get-current-project()), $result)}
        <type>success</type>
        <message>Die Zotero-Verbindung "{$connection-name}" wurde entfernt!</message>
    </result>
};

declare function local:replace-in-file($file-input as xs:string, $pattern as xs:string, $replacement as xs:string) as xs:string {
    local:replace-in-new-file($file-input, $file-input, $pattern, $replacement)
};

declare function local:replace-in-new-file($file-input as xs:string, $file-output as xs:string, $pattern as xs:string, $replacement as xs:string) as xs:string {
    let $input := util:binary-to-string(util:binary-doc($file-input))
    let $contents := replace($input, $pattern, $replacement)
    return
        xmldb:store-as-binary(functx:substring-before-last($file-output, "/"), functx:substring-after-last($file-output, "/"), $contents)
};

declare function local:synch-zotero-connection-in-blocks($connection-id as xs:string) as node() {
    config:synchronize-zotero-connection-in-blocks(config:get-current-project(), $connection-id, 0, true())
};

declare function local:update-zotero-connection-in-blocks($connection-id as xs:string) as node() {
    config:update-zotero-connection-in-blocks(config:get-current-project(), $connection-id)
};

declare function local:zip-development-collection() as empty-sequence() {
    let $project-name := config:get-current-project()
    let $ediarum-path := config:get-ediarum-db-path()
    let $source-collection-uri := $ediarum-path||"/setup/development"
    let $zip-collection := $ediarum-path||"/setup/zip"
    let $add-zip-col := xmldb:create-collection($ediarum-path||"/setup", "zip")
    let $copy-development-collection := xmldb:copy($source-collection-uri, $zip-collection)
    let $rename-files := (
        xmldb:rename($zip-collection||"/development", "gitignore.txt", ".gitignore"),
        xmldb:rename($zip-collection||"/development", "PROJECTNAME_dev.xpr", $project-name||"_dev.xpr"),
        xmldb:rename($zip-collection||"/development/oxygen_addon", "PROJECTNAME_addon.xpr", $project-name||"_addon.xpr")
    )
    let $change-contents := (
        local:replace-in-file($ediarum-path||"/setup/zip/development/build.properties", "%PROJECTNAME%", $project-name),
        local:replace-in-file($ediarum-path||"/setup/zip/development/"||$project-name||"_dev.xpr", "%PROJECTNAME%", $project-name),
        local:replace-in-file($ediarum-path||"/setup/zip/development/oxygen_addon/"||$project-name||"_addon.xpr", "%PROJECTNAME%", $project-name),
        local:replace-in-file($ediarum-path||"/setup/zip/development/exist/webconfig.xml.LOCAL", "%PROJECTNAME%", $project-name),
        local:replace-in-file($ediarum-path||"/setup/zip/development/exist/webconfig.xml.DEV", "%PROJECTNAME%", $project-name),
        local:replace-in-file($ediarum-path||"/setup/zip/development/exist/webconfig.xml.EDIT", "%PROJECTNAME%", $project-name)
    )
    (: TODO: This doesn't work stable with every exist-db. Further testing is required. :)
    (: let $zip := compression:zip(xs:anyURI("/db/apps/ediarum/setup/zip/development"), true(), "/db/apps/ediarum/setup/zip") :)
    (: let $store := xmldb:store(xs:anyURI("/db/apps/ediarum/setup"), "development.zip", $zip) :)
    let $remove-zip-collection := xmldb:remove($zip-collection)
    return ()
};
