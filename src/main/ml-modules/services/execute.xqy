xquery version "1.0-ml";

module namespace app = "http://marklogic.com/rest-api/resource/execute";
declare %private function app:executeQuery($query, $options){
  try{
    let $resp:=xdmp:eval($query,(), $options)
    let $sessionQu:=xdmp:set-session-field("queryResults", $resp)
    return
      <result hits="{count($resp)}" elapsed="0.028"/>
  }catch($err){
    $err
  }
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
  xdmp:log("PUT called")
};

declare function post(
  $context as map:map,
  $params  as map:map,
  $input   as document-node()*
  ) as document-node()*
{
  let $qu:=map:get($params, "qu")
  let $path := replace(map:get($params, "base"), "//", "/")
  let $dbName := tokenize($path, "/")[3]
  let $options:=
    <options xmlns="xdmp:eval">
      <database>{xdmp:database($dbName)}</database>
    </options>
  let $result:=app:executeQuery($qu, $options)
  return
    (
      map:put($context, "output-types", "application/xml"),
      xdmp:set-response-code(200, "OK"),
      document {
        $result
      }
    )
};

declare function delete(
  $context as map:map,
  $params  as map:map
  ) as document-node()?
{
  xdmp:log("DELETE called")
};
