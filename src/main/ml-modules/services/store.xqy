xquery version "1.0-ml";

module namespace app = "http://marklogic.com/rest-api/resource/store";

declare %private function app:storeResource($input, $uri, $options){
  xdmp:invoke-function(
          function(){xdmp:document-insert($uri, $input), xdmp:commit()},
          $options
  )
};

declare function get(
  $context as map:map,
  $params  as map:map
  ) as document-node()*
{
  xdmp:log("GET called")
};

declare function put(
  $context as map:map,
  $params  as map:map,
  $input   as document-node()*
  ) as document-node()?
{
  let $path := replace(map:get($params, "path"), "//", "/")
  let $dbName := tokenize($path, "/")[3]
  let $uri:=fn:substring-after($path, $dbName)
  let $options:=
    <options xmlns="xdmp:eval">
      <transaction-mode>update</transaction-mode>
      <database>{xdmp:database($dbName)}</database>
    </options>
  return(
    try{
      let $response:=app:storeResource($input, $uri, $options)
      return
        (
          map:put($context, "output-types", "application/json"),
          xdmp:set-response-code(200, "OK"),
          document { '{"response" : "Saved"}' }
        )

    }catch ($exception) {
      map:put($context, "output-types", "application/json"),
      xdmp:set-response-code(404, "ERROR"),
      document {'{"response" : "Problem saving the item '|| $exception ||'}' }
    }
  )
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
