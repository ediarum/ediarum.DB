xquery version "3.0";

import module namespace config="http://www.bbaw.de/telota/software/ediarum/config" at "../../modules/config.xqm";

declare variable $target external; (: Name der Synchronisation :)
declare variable $type external; (: Typ der Synchronisation :)
declare variable $project external; (: Projektname :)

try {
    let $result := config:do-synchronisation($target, $type, $project)
    return
        $result
} catch * {
    <result>
        <type>danger</type>
        <message>
            <p>Caught error {$err:code}: {$err:description}</p>
        </message>
    </result>
}
