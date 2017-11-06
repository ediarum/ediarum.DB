xquery version "3.0";

import module namespace config="http://www.bbaw.de/telota/software/ediarum/config" at "../../modules/config.xqm";

declare variable $project external;
declare variable $connection external;

try {
    let $result := config:synchronize-zotero-connection-in-blocks($project, $connection, 0, true())
    return
        $result
} catch * {
    <span>Caught error {$err:code}: {$err:description}</span>
}
