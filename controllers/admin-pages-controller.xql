xquery version "3.0";

module namespace admin-pages="http://www.bbaw.de/telota/software/ediarum-app/admin-pages";
import module namespace config="http://www.bbaw.de/telota/software/ediarum/config" at "../modules/config.xqm";
import module namespace ediarum="http://www.bbaw.de/telota/software/ediarum/ediarum-app" at "./ediarum.xql";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";

declare namespace scheduler="http://exist-db.org/xquery/scheduler";

(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with an attribute: data-template="app:test" or class="app:test" (deprecated).
 : The function has to take 2 default parameters. Additional parameters are automatically mapped to
 : any matching request or function parameter.
 :
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)

 declare function admin-pages:action-alert($node as node(), $model as map(*)) as node()* {
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
     else (),
    if (local:port-setup-is-not-active()) then (
        <div class="alert alert-warning">
            <span>Die eingestellten Ports haben sich geändert, bitte starten Sie die Datenbank neu. (Aktueller Port: {request:get-server-port()})</span>
        </div>
        )
    else ()
 };

declare function admin-pages:activate-projects-controller($node as node(), $model as map(*)) as node()? {
    if(sm:is-dba(config:get-current-user())) then (
        if (local:projects-controller-active() and local:projects-controller-is-running()) then (
            <div class="alert alert-success">
                <span>Projects Controller ist aktiv.</span>
            </div>
            )
        else if (local:projects-controller-active()) then (
            <div class="alert alert-warning">
                <span>Bitte starten Sie die Datenbank neu, um den Projects Controller zu aktivieren.</span>
            </div>
            )
        else (
            <form class="alert alert-warning" action="" method="post">
                <strong>Projects Controller ist nicht aktiv. </strong>
                <input type="hidden" name="action" value="activate-projects-controller"/>
                <button type="submit" class="btn btn-warning"><span>Anlegen!</span></button>
            </form>
            )
    ) else ()
};

declare function admin-pages:activate-scheduler($node as node(), $model as map(*)) as node()? {
    if(sm:is-dba(config:get-current-user())) then (
        if (local:scheduler-active() and local:scheduler-is-running()) then (
            <div class="alert alert-success">
                <span>Scheduler ist aktiv. Status:
                    {scheduler:get-scheduled-jobs()//scheduler:job[@name="ediarumScheduler"]//state}
                </span>
            </div>
        ) else if (local:scheduler-active()) then (
            <div class="alert alert-warning">
                <span>Bitte starten Sie die Datenbank neu, um den Scheduler zu aktivieren.</span>
            </div>
        ) else (
            <form class="alert alert-warning" action="" method="post">
                <strong>Scheduler ist nicht aktiv. </strong>
                <input type="hidden" name="action" value="activate-scheduler"/>
                <button type="submit" class="btn btn-warning"><span>Anlegen!</span></button>
            </form>
        )
    ) else ()
};

declare function admin-pages:app-info($node as node(), $model as map(*)) as node()? {
    if(sm:is-dba(config:get-current-user())) then (
        let $expath := config:expath-descriptor()
        let $repo := config:repo-descriptor()
        return
            <table class="app-info">
                <tr>
                    <td>app collection:</td>
                    <td>{$config:app-root}</td>
                </tr>
                {
                    for $attr in ($expath/@*, $expath/*, $repo/*)
                    return
                        <tr>
                            <td>{node-name($attr)}:</td>
                            <td>{$attr/string()}</td>
                        </tr>
                }
                <tr>
                    <td>Controller:</td>
                    <td>{ request:get-attribute("$exist:controller") }</td>
                </tr>
            </table>
    ) else ()
};

declare function admin-pages:projects($node as node(), $model as map(*)) as map(*) {
    if(sm:is-dba(config:get-current-user())) then (
        let $action := request:get-parameter('action','')
        let $project-name := request:get-parameter('project-name','')
        let $result :=
            if ($action eq 'new-project') then (
                if (not(index-of(config:get-projects(),$project-name))) then (
                    (: Das Projekt existiert noch nicht. :)
                    <result>
                        {local:create-new-project($project-name)}
                        <type>success</type>
                        <message>Das Projekt "{$project-name}" wurde angelegt!</message>
                    </result>
                    )
                else (
                    <result>
                        <type>alert</type>
                        <message>Das Projekt "{$project-name}" existiert nicht!</message>
                    </result>
                    )
                )
            else if ($action eq 'delete-project') then (
                if (index-of(config:get-projects(),$project-name)) then (
                    (: Das Projekt existiert. :)
                    <result>
                        {local:delete-project($project-name)}
                        <type>success</type>
                        <message>Das Projekt "{$project-name}" wurde gelöscht!</message>
                    </result>
                    )
                else
                    (: Das Projekt existiert nicht. :)
                    <result>
                        <type>alert</type>
                        <message>Das Projekt "{$project-name}" existiert nicht!</message>
                    </result>
                )
            else ()
        return
        map { "result" := $result}
        )
    else (
        map {}
        )
};

declare function admin-pages:project-list($node as node(), $model as map(*)) as node()? {
    if(sm:is-dba(config:get-current-user())) then (
        <div>
            {for $project in config:get-projects()
            return
                <nav class="navbar navbar-default">
                    <div class="container-fluid">
                        <div class="navbar-header">
                            <a class="navbar-brand" href="projects/{$project}/data.html">{$project}</a>
                        </div>
                        <div class="navbar-collapse navbar-right">
                            <!--form action="" method="post">
                                <input type="hidden" name="action" value="delete-project"/>
                                <input type="hidden" name="project-name" value="{$project}"/>
                                <button type="submit" class="btn btn-default navbar-btn">Löschen</button>
                            </form-->
                            <a type="button" href="" class="btn btn-default navbar-btn" data-toggle="modal" data-target="#modalDeleteProject" data-project-name="{$project}">Löschen</a>
                        </div>
                    </div>
                </nav>
            }
        </div>
    ) else ()
};

declare function admin-pages:scheduler($node as node(), $model as map(*)) as map(*) {
    if(sm:is-dba(config:get-current-user())) then (
        let $action := request:get-parameter('action','')
        let $result :=
            if ($action="activate-scheduler") then (
                local:activate-scheduler()
                )
            else ()
        return
            map { "result" := $result }
    ) else (
        map{}
    )
};

declare function admin-pages:server-info($node as node(), $model as map(*)) as node()? {
    if(sm:is-dba(config:get-current-user())) then (
        <div>
            <h2>Server Info</h2>
            <table>
                <tr><th colspan="2">General</th></tr>
                <tr>
                    <td>Current Time:</td><td>{current-dateTime()}</td>
                </tr>
                <tr>
                    <td>Uptime</td><td>{xs:string(system:get-uptime())}</td>
                </tr>
                <tr>
                    <td>eXist Version:</td><td>{system:get-version()}</td>
                </tr>
                <tr>
                    <td>eXist Build:</td><td>{system:get-build()}</td>
                </tr>
                <tr>
                    <td>eXist Home:</td><td>{system:get-exist-home()}</td>
                </tr>
                <tr>
                    <td>Operating System:</td><td>{concat(util:system-property("os.name"), " ", util:system-property("os.version"),
                            " ", util:system-property("os.arch"))}</td>
                </tr>
                <tr><th colspan="2">Java</th></tr>
                <tr>
                    <td>Vendor:</td><td>{util:system-property("java.vendor")}</td>
                </tr>
                <tr>
                    <td>Version:</td><td>{util:system-property("java.version")}</td>
                </tr>
                <tr>
                    <td>Implementation:</td><td>{util:system-property("java.vm.name")}</td>
                </tr>
                <tr>
                    <td>Installation:</td><td>{util:system-property("java.home")}</td>
                </tr>
                <tr>
                    <td>Temp file path:</td><td>{util:system-property("java.io.tmpdir")}</td>
                </tr>
                <tr><th colspan="2">Memory Usage</th></tr>
                <tr>
                    <td>Max. Memory:</td><td>{system:get-memory-max() idiv 1000000} MB</td>
                </tr>
                <tr>
                    <td>Current Total:</td><td>{system:get-memory-total() idiv 1000000} MB</td>
                </tr>
                <tr>
                    <td>Free memory:</td><td>{system:get-memory-free() idiv 1000000} MB</td>
                </tr>
            </table>
        </div>
    ) else ()
};

declare function admin-pages:setup($node as node(), $model as map(*)) as map(*) {
    if(sm:is-dba(config:get-current-user())) then (
        let $action := request:get-parameter('action','')
        let $new-port := request:get-parameter('new-port','')
        let $new-ssl-port := request:get-parameter('new-ssl-port','')
        let $username := request:get-parameter('username','')
        let $new-password := request:get-parameter('new-password','')
        let $result :=
            if ($action="activate-projects-controller") then (
                local:activate-projects-controller()
                )
            else if ($action="change-port") then (
                if (string(number($new-port)) != 'NaN' and number($new-port)>0 and number($new-port)<9999 and string(number($new-ssl-port)) != 'NaN' and number($new-ssl-port)>0 and number($new-ssl-port)<9999 and number($new-port)!=number($new-ssl-port)) then (
                    local:change-ports($new-port, $new-ssl-port)
                    )
                else (
                    <result>
                    <type>danger</type>
                    <message>Die Portangabe war inkorrekt.</message>
                    </result>)
                )
            else if ($action="change-password") then (
                local:change-password($username, $new-password)
                )
            else ()
        return
            map { "result" := $result }
    ) else (
        map{}
    )
};

declare function admin-pages:setup-port-configuration($node as node(), $model as map(*)) as node()? {
    if(sm:is-dba(config:get-current-user())) then (
        <div>
            <nav class="navbar navbar-default">
                <div class="container-fluid">
                    <div class="navbar-header">
                        <span class="navbar-brand">Aktuelle Ports</span>
                    </div>
                    <p class="navbar-text">{config:get-setup-property("port")} (SSL: {config:get-setup-property("sslPort")})</p>
                    <div class="navbar-collapse navbar-right">
                        <form action="" method="post">
                            <input type="hidden" name="action" value="change-port"/>
                                <a type="button" href="" class="btn btn-default navbar-btn" data-toggle="modal" data-target="#modalChangePort">Ändern</a>
                        </form>
                    </div>
                </div>
            </nav>
        </div>
    ) else ()
};

declare function admin-pages:show-scheduler-log($node as node(), $model as map(*)) as node()? {
    if(sm:is-dba(config:get-current-user())) then (
        <div>
        {for $project in config:get-log-file("scheduler")//project
        return
            <div>
                <h3>{$project/@name/string()}</h3>
                <table class="table">
                    <tr>
                        <th>Name</th>
                        <th>Typ</th>
                        <th>Letzter Aufruf</th>
                        <th>Ergebnis</th>
                    </tr>
                    {for $job in $project/job
                    return
                        <tr class="{$job/@class/string()}">
                            <td>{$job/@name/string()}</td>
                            <td>{$job/@type/string()}</td>
                            <td>{$job/@when/string()}</td>
                            <td>{$job/(*|text())}</td>
                        </tr>
                    }
                </table>
            </div>
        }
        </div>
    ) else ()
};

declare function local:activate-projects-controller() as empty-sequence() {
    if(sm:is-dba(config:get-current-user())) then (
        let $resource := "temp.xml"
        let $collection := $config:ediarum-db-path||"/setup"
        let $store := xmldb:store($collection, $resource, config:get-existdb-controller-config())
        let $conf := doc($store)
        let $insertion-element :=
            <exist:root pattern="/projects" path="xmldb:exist:///db/projects"/>
        let $update := update insert $insertion-element following $conf//exist:configuration/exist:root[@pattern="/apps"]
        let $params :=
            <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
                <output:omit-xml-declaration value="no"/>
            </output:serialization-parameters>

        let $serialize := file:serialize($conf, config:get-existdb-controller-config-path(), $params)

        let $clear := xmldb:remove($collection, $resource)

        return
            ()
    ) else ()
};

declare function local:activate-scheduler() {
    if(sm:is-dba(config:get-current-user())) then (
        let $collection := $config:ediarum-db-path||$config:routines-col
        let $resource := "temp.xml"
        let $store := xmldb:store($collection, $resource, config:get-existdb-config())
        let $conf := doc($store)
        let $scheduler-job :=
            <job type="user" name="ediarumScheduler" xquery="{$config:ediarum-db-path||$config:routines-col}/scheduler.xql" cron-trigger="0 * * * * ?"/>
        let $update := update insert $scheduler-job into $conf//scheduler
        let $params :=
            <output:serialization-parameters xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
                <output:omit-xml-declaration value="no"/>
            </output:serialization-parameters>
        let $serialize := file:serialize($conf, config:get-existdb-config-path(), $params)
        let $clear := xmldb:remove($collection, $resource)
        return
            ()
    ) else ()
};

declare function local:change-password($username, $password) {
    if(sm:is-dba(config:get-current-user())) then (
        <result>
            {sm:passwd($username, $password)}
            <type>success</type>
            <message>Das Passwort wurde geändert.</message>
        </result>
    ) else ()
};

declare function local:change-ports($port, $ssl-port) {
    if(sm:is-dba(config:get-current-user())) then (
        let $file := file:read(config:get-existdb-jetty-config-path())
        let $update-port := replace($file,'<SystemProperty name="jetty\.port" default="\d+"/>',
            concat('<SystemProperty name="jetty.port" default="',$port,'"/>'))
        let $binary := util:string-to-binary($update-port)
        let $serialize := file:serialize-binary($binary, config:get-existdb-jetty-config-path())

        let $ssl-file := file:read(config:get-existdb-jetty-ssl-config-path())
        let $update-port-ssl := replace($update-port,'<SystemProperty name="jetty\.port\.ssl" default="\d+"/>',
            concat('<SystemProperty name="jetty.ssl.port" deprecated="ssl.port" default="',$ssl-port,'"/>'))
        let $binary-ssl := util:string-to-binary($update-port-ssl)
        let $serialize-ssl := file:serialize-binary($binary-ssl, config:get-existdb-jetty-ssl-config-path())

        let $setup := config:get-setup()
        let $update-setup-port := update value $setup//property[@name="port"]/@value with $port
        let $update-setup-port-ssl := update value $setup//property[@name="sslPort"]/@value with $ssl-port

        return
        <result>
            <type>success</type>
            <message>Ports erfolgreich geändert.</message>
        </result>
    ) else ()
};

(: Copy a file to a project collection. :)
declare function local:copy_file_to_project($p, $source_path, $rel_collection_path, $file_name, $group_name, $permissions) {
    if(sm:is-dba(config:get-current-user())) then (
        xmldb:copy($source_path, config:project-collection-path($p, $rel_collection_path), $file_name),
        sm:chgrp(config:project-resource-uri($p, concat($rel_collection_path,"/",$file_name)), $group_name),
        sm:chmod(config:project-resource-uri($p, concat($rel_collection_path,"/",$file_name)), $permissions)
    ) else ()
};

(: Copy a file to the right system config colletion. :)
declare function local:copy_file_to_system_config($p, $source_path, $rel_collection_path, $file_name, $new_file_name) {
    if(sm:is-dba(config:get-current-user())) then (
        xmldb:copy($source_path, concat("/db/system/config",config:project-collection-path($p, $rel_collection_path)), $file_name),
        xmldb:rename(concat("/db/system/config",config:project-collection-path($p, $rel_collection_path)), $file_name, $new_file_name)
    ) else ()
};

(: Generates a new Projekt with groups, collections and so on. :)
declare function local:create-new-project($p) {
    if(sm:is-dba(config:get-current-user())) then (
        (: Das project-Verzeichnis wird angelegt. :)
        xmldb:create-collection($config:projects-path,$p),
        xmldb:create-collection("/db/system/config/db/projects",$p),

        (: Die Gruppe wird eingerichtet. :)
        let $nutzer-group := config:project-user-group($p)
        return (
            sm:create-group($nutzer-group),
            sm:add-group-member($nutzer-group, ("website-user")),

            config:mkcol-in-project($p, "", "data", $nutzer-group, "rwxrwx---"),
            config:mkcol-in-project($p, "data", "Briefe", $nutzer-group, "rwxrwx---"),
            config:mkcol-in-project($p, "data", "Register", $nutzer-group, "rwxrwx---"),
            config:mkcol-in-project($p, "", "external_data", $nutzer-group, "rwxrwx---"),
            config:mkcol-in-project($p, "", "oxygen", "oxygen", "rwxrwx---"),
            config:mkcol-in-project($p, "", "web", "website", "rwxr-x---"),
            config:mkcol-in-project($p, "", "druck", "website", "rwxr-x---"),
            config:mkcol-in-project($p, "", "exist", "exist", "rwxrwx---"),
            config:mkcol-in-project($p, "exist", "routinen", "dba", "rwxrwx---"),
            config:mkcol-in-project($p, "exist/routinen", "scheduler", "dba", "rwxrwx---"),

            (: Konfigurationsdateien werden kopiert. :)
            local:copy_file_to_project($p, concat($config:ediarum-db-path,"/setup"), "", "webconfig.xml", "website", "rw-r-----"),
            local:copy_file_to_project($p, concat($config:ediarum-db-path,"/setup"), "", "config.xml", "ediarum", "rw-r-----"),

            (: Beispieldateien werden kopiert. :)
            local:copy_file_to_project($p, concat($config:ediarum-db-path,"/setup"), "data/Briefe", "briefBeispiel.xml", $nutzer-group, "rw-rw----"),

            (: Neuer Ansatz für die Benutzerrechte :)
            local:copy_file_to_project($p, $config:ediarum-db-path||"/setup", "exist/routinen", "set_default_permissions.xql", "dba", "rwxrwx---"),

            (: Die Systemordner für die Collections werden eingerichtet. :)
            xmldb:create-collection(concat("/db/system/config", config:project-collection-path($p)),"data"),
            xmldb:create-collection(concat("/db/system/config", config:project-collection-path($p)),"web"),

            (: Die Indexfunktionalitäten werden vorbereitet. :)
            local:copy_file_to_project($p, $config:ediarum-db-path||"/setup", "oxygen", "ediarum.xql", "oxygen", "rwsr-x---")
        )
    ) else ()
};

(: Deletes a project and removes the groups. :)
declare function local:delete-project($p) {
    if(sm:is-dba(config:get-current-user())) then (
        if (not(contains($p,'/')))
        then (
            config:unset-current-project(),
            xmldb:remove($config:projects-path||"/"||$p),
            xmldb:remove("/db/system/config"||$config:projects-path||"/"||$p),
            let $nutzer-group := config:project-user-group($p)
            return sm:remove-group($nutzer-group))
        else ()
    ) else ()
};

declare function local:port-setup-is-not-active() {
    if(sm:is-dba(config:get-current-user())) then (
        not(string(request:get-server-port()) eq config:get-setup-property("port"))
    ) else ()
};

declare function local:projects-controller-active() {
    if(sm:is-dba(config:get-current-user())) then (
        let $existdb-controller := config:get-existdb-controller-config()
        let $projects-controller-is-active := exists($existdb-controller//exist:configuration/exist:root[@pattern="/projects"])
        return
            $projects-controller-is-active
    ) else ()
};

declare function local:projects-controller-is-running() {
    if(sm:is-dba(config:get-current-user())) then (
        let $valid-status-codes := ("401", "200")
        let $statusCode := httpclient:head(xs:anyURI(substring-before(request:get-url(),"/apps")||"/projects/"), false(), ())/@statusCode/string()        let $projects-controller-running := exists(index-of($valid-status-codes, $statusCode))
        return
            $projects-controller-running
    ) else ()
};

declare function local:scheduler-active() {
    if(sm:is-dba(config:get-current-user())) then (
        exists(config:get-existdb-config()//scheduler/job[@name='ediarumScheduler'])
    ) else ()
};

declare function local:scheduler-is-running() {
    if(sm:is-dba(config:get-current-user())) then (
        scheduler:get-scheduled-jobs()//scheduler:job[@name="ediarumScheduler"]//state/string() eq "NORMAL"
    ) else ()
};
