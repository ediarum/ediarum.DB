xquery version "3.0";

module namespace controller="http://www.bbaw.de/telota/software/ediarum/exist/controller";
import module namespace ediarum="http://www.bbaw.de/telota/software/ediarum/ediarum-app" at "ediarum.xql";

declare function controller:get-project-from-uri($uri) {
  ediarum:get-project-from-uri($uri)
};

declare function controller:add-root-path($node as node(), $model as map(*), $att as xs:string) {
  let $node-name := $node/name()
  let $node-attributes := $node/@*[not(starts-with(name(),'data-template') or name() = $att)]
  let $uri := string(request:get-uri())
  let $att-content := concat(substring-before($uri,"/apps/ediarum/")||"/apps/ediarum/", $node/@*[name() = $att])
  return
  element {$node-name} {
    $node-attributes,
    attribute {$att} {$att-content},
    $node/(node()|text())
  }
};
