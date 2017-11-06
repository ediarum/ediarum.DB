xquery version "3.0";

declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:media-type "application/json";

let $progress := session:get-attribute('progress')
let $progress-message := session:get-attribute('progress-message')

return
    <result>
        <percentage>
            {if (number($progress) >= 0 and number($progress) <= 100) then
                $progress
            else
                '100'}
        </percentage>
        <message>
            {" "||$progress-message||" "}
        </message>
    </result>
