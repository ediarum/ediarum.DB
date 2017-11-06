xquery version "3.0";

let $file-path := request:get-parameter("file","")
let $file := doc($file-path)
return
    $file