xquery version "1.0-ml";

module namespace load-module = "http://marklogic.com/rest-api/resource/load";
declare %private function load-module:getResource($uri, $options){
  xdmp:invoke-function(
          function(){document($uri)},
          $options
  )
};

declare %private function load-module:getContentType($uri, $options){
  xdmp:invoke-function(
          function(){xdmp:uri-content-type($uri)},
          $options
  )
};

declare function get(
  $context as map:map,
  $params  as map:map
  ) as document-node()*
{
  let $path := replace(map:get($params, "path"), "//", "/")
  let $dbName := tokenize($path, "/")[3]
  let $uri:=fn:substring-after($path, $dbName)
  let $options:=
    <options xmlns="xdmp:eval">
      <database>{xdmp:database($dbName)}</database>
    </options>
  return
    (
      map:put($context, "output-types", load-module:getContentType($uri, $options)),
      xdmp:set-response-code(200, "OK"),
      document { load-module:getResource($uri, $options) }
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
