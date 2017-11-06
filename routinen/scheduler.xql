xquery version "3.0";

declare namespace functx = "http://www.functx.com";

declare function functx:day-of-week($date as xs:anyAtomicType?) as xs:integer? {
    if (empty($date)) then
        ()
    else
        xs:integer((xs:date($date) - xs:date('1901-01-06')) div xs:dayTimeDuration('P1D')) mod 7
};

declare function local:test-cron($cron as xs:string) as xs:boolean {
    let $get-cron-param-simple :=
        function ($x as xs:string, $seq as xs:anyAtomicType*) {
            if (number($x)= $seq) then
                number($x )
            else if ($x = '*') then
                $seq
            else
                error()
        }
    let $get-cron-param :=
        function ($x as xs:string, $seq as xs:anyAtomicType*) {
            if (contains($x, "/")) then
                let $m := let $n:= number(substring-after($x, "/")) return if ($n > 0) then $n else error()
                let $x1 := let $n:= substring-before($x, "/") return if (number($n) >= 0 and number($n) < $m) then number($n) else if ($n = "*") then 0 else error
                return
                for $y in $seq
                    return
                    if (($y mod $m) = $x1) then
                        $y
                    else ()
            else
            $get-cron-param-simple($x, $seq)
        }

    let $cron-seq := let $s := tokenize($cron, '\s') return
        if( count($s) = 5) then $s else error()

    let $minute := $get-cron-param($cron-seq[1], (0 to 59))
    let $hour := $get-cron-param($cron-seq[2], (0 to 23))
    let $day-of-month := $get-cron-param($cron-seq[3], (1 to 31))
    let $month := $get-cron-param($cron-seq[4], (1 to 12))
    let $day-of-week := $get-cron-param($cron-seq[5], (0 to 6))

    let $dateTime := current-dateTime()
    let $current-minute := fn:minutes-from-dateTime($dateTime)
    let $current-hour := fn:hours-from-dateTime($dateTime)
    let $current-day := fn:day-from-dateTime($dateTime)
    let $current-month := fn:month-from-dateTime($dateTime)
    let $current-day-of-week := functx:day-of-week($dateTime)

    let $test-minute := ($current-minute = $minute)
    let $test-hour := ($current-hour = $hour)
    let $test-day-of-month := ($current-day = $day-of-month)
    let $test-month := ($current-month = $month)
    let $test-day-of-week := ($current-day-of-week = $day-of-week)
    let $test := $test-minute and $test-hour and $test-day-of-month and $test-month and $test-day-of-week
    return
        $test
};

let $projects := xmldb:get-child-collections("/db/projects")
let $report :=
    <report>{
        for $project in $projects
        let $config := doc("/db/projects/"||$project||"/config.xml")
        return
            <project name="{$project}">{
                for $job in $config//job
                let $cron := $job/@cron/string()
                let $do-test := local:test-cron($cron)
                (: let $period-length := string-length($job/@period/string())
                let $period-unit := substring($job/@period/string(),$period-length)
                let $period-value :=substring($job/@period/string(),1,$period-length -1)
                let $test := if ($period-unit="m") then
                            ((number($current-minute) mod number($period-value))=0)
                        else if ($period-unit="h") then
                            ($current-minute=0 and ((number($current-hour) mod number($period-value))=0))
                        else if ($period-unit="d") then
                            ($current-minute=0 and $current-hour=0 and ((number($current-day) mod number($period-value))=0))
                        else (false()) :)
                return
                if (not($do-test)) then () else
                let $path := if ($job/@type/string()="ediarum") then (
                            "/db/apps/ediarum/routinen/scheduler"
                            )
                        else if ($job/@type/string()="synchronisation") then (
                            "/db/apps/ediarum/routinen/scheduler"
                            )
                        else (
                            "/db/projects/"||$project||"/exist/routinen/scheduler"
                            )
                let $xql := if ($job/@type/string()="synchronisation") then (
                        "synchronisation.xql"
                        )
                    else $job/@xquery/string()||".xql"
                let $params := for $param in $job/parameter
                    return (
                        QName("", $param/@name/string()), $param/@value/string())
                let $result := try {
                            util:eval(xs:anyURI($path||"/"||$xql), false(), ($params, QName("", "project"), $project))
                        } catch * {
                            <result>
                                <type>danger</type>
                                <message>
                                    <pre>
                                        {"Job failed ("||$err:code||": "||$err:description||")"}
                                    </pre>
                                </message>
                            </result>
                        }

                return
                    <job name="{$job/@name/string()}" type="{$job/@type/string()}" when="{current-dateTime()}" class="{$result/type/string()}">{$result/message/(*|text())}</job>
            }</project>
    }</report>
let $scheduler-log := doc("/db/apps/ediarum/logs/scheduler.xml")
return
    for $project in $report/project
    return
    if (exists($scheduler-log/report/project[@name=$project/@name/string()])) then
        for $job in $project/job
        return
        if (exists($scheduler-log/report/project[@name=$project/@name/string()]/job[@name=$job/@name/string()])) then
            update replace $scheduler-log/report/project[@name=$project/@name/string()]/job[@name=$job/@name/string()] with $job
        else
            update insert $job into $scheduler-log/report/project[@name=$project/@name/string()]
    else
        update insert $project into $scheduler-log/report
