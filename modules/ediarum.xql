xquery version "3.1";


module namespace ediarum="http://www.bbaw.de/telota/software/ediarum/ediarum-app";
import module namespace http = "http://expath.org/ns/http-client";


declare namespace xdb="http://exist-db.org/xquery/xmldb";
declare namespace sm="http://exist-db.org/xquery/securitymanager";
declare variable $ediarum:datacopyDir:= doc("../setup/setup.xml")//property[@name='datacopyDir']/@value/data(.);
declare variable $ediarum:ediarum-dir:= doc("../setup/setup.xml")//property[@name='ediarumDir']/@value/string(.);

declare variable $ediarum:project_dir:= doc("../setup/setup.xml")//property[@name='projectDir']/@value/string(.);

declare function ediarum:get-bot-name() as xs:string {
    doc("../setup/setup.xml")//property[@name='botName']/@value/data(.)
};

declare function ediarum:get-bot-pass() as xs:string {
     doc("../setup/setup.xml")//property[@name='botPass']/@value/data(.)
};

declare function ediarum:send-authHTTP($url as xs:anyURI, $username, $password, $request-type, $content, $content-type) {
  let $req :=
    <http:request href="{ $url }"
                  method="{ $request-type }"
                  username="{ $username }"
                  password="{ $password }"
                  auth-method="basic"
                  send-authorization="true">
    </http:request>
  let $req-with-content :=
    <http:request href="{ $url }"
                  method="{ $request-type }"
                  username="{ $username }"
                  password="{ $password }"
                  auth-method="basic"
                  send-authorization="true">
      <http:body media-type="{ $content-type }"/>
    </http:request>

  return
    if ($request-type='PUT') 
    then http:send-request($req-with-content, (), $content)
    else if ($request-type='GET') 
    then http:send-request($req)
    else if ($request-type='DELETE') 
    then http:send-request($req)
    else ()
};

declare function ediarum:substring-afterlast($string as xs:string, $cut as xs:string){
  if (matches($string, $cut))
    then ediarum:substring-afterlast(substring-after($string,$cut),$cut)
  else $string
};

declare function ediarum:substring-beforelast($string as xs:string, $cut as xs:string){
  if (matches($string, $cut))
    then substring($string,1,string-length($string)-string-length(ediarum:substring-afterlast($string,$cut))-string-length($cut))
  else $string
};

declare function ediarum:trim-whitespace($string) {
  replace(replace($string,'^\s+',''),'\s+$','')
};

declare function ediarum:bot-login($uri as xs:string) {
  xdb:login($uri, ediarum:get-bot-name(), ediarum:get-bot-pass())
};

declare function ediarum:get-project-from-path($uri as xs:string) {
    if (starts-with($uri, $ediarum:project_dir))
    then
        let $s := substring-after($uri, $ediarum:project_dir)
        return if (contains($s, '/'))
        then substring-before($s, '/')
        else $s
    else
        false()
};

declare function ediarum:get-project-from-uri($uri as xs:string) {
    let $s := substring-after($uri, "/projects/")
    return if (contains($s, '/'))
    then substring-before($s, '/')
    else $s
};

declare function ediarum:current-data-copy-dir($uri) {
   concat($ediarum:project_dir,'/',ediarum:get-project-from-path($uri),'/data_copy')
};

declare function ediarum:get-current-project() {
    ediarum:get-project-from-uri(request:get-uri())
};

declare function ediarum:get-ediarum-dir($context) {
    $context||$ediarum:ediarum-dir
};

(: Interessante Funktion !!
declare function local:strip-namespace($e as element()) as element() {
  element { xs:QName(local-name($e)) }
    {
     for $child in $e/(@*,node())
     return
       if ($child instance of element())
       then local:strip-namespace($child)
       else $child
    }
}; :)
