xquery version "1.0-ml";

module namespace app = "http://marklogic.com/rest-api/resource/results";
import module namespace pretty = "http://exist-db.org/eXide/pretty"
at "/modules/pretty-print.xqy";

(:~ Retrieve a single query result. :)
declare %private function app:retrieve($num as xs:int, $cached, $dbName) as element() {
  let $node := $cached[$num]
  let $item :=
    if ($node instance of node()) then
    (:util:expand($node, 'indent=yes'):)
      $node
    else
      $node
  let $documentURI :=if ($node instance of node()) then base-uri($node) else ()
  return
    <div class="{if ($num mod 2 eq 0) then 'even' else 'uneven'}">
      {
        if (string-length($documentURI) > 0) then
          <div class="pos">
            {
              if (string-length($documentURI) > 0) then
                <a href="/db/{$dbName||$documentURI}" data-path="/db/{$dbName||$documentURI}"
                title="Click to load source document">{$num}</a>
              else
                ()
            }
          </div>
        else
          ()
      }
      <div class="item">
        { pretty:pretty-print($item, ()) }
      </div>
    </div>
};

declare function get(
  $context as map:map,
  $params  as map:map
  ) as document-node()*
{
  let $id:=xs:int(map:get($params, "id"))
  let $path := replace(map:get($params, "base"), "//", "/")
  let $dbName := tokenize($path, "/")[3]
  let $cached:=xdmp:get-session-field("queryResults")
  return(
    map:put($context, "output-types", "application/xml"),
    xdmp:set-response-code(200, "OK"),
    document { app:retrieve($id, $cached, $dbName) }
  )
};

declare function put(
  $context as map:map,
  $params  as map:map,
  $input   as document-node()*
  ) as document-node()?
{
  xdmp:log("PUT called")
};

declare function post(
  $context as map:map,
  $params  as map:map,
  $input   as document-node()*
  ) as document-node()*
{
  xdmp:log("POST called")
};

declare function delete(
  $context as map:map,
  $params  as map:map
  ) as document-node()?
{
  xdmp:log("DELETE called")
};
