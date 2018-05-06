xquery version "1.0-ml";

module namespace app = "http://marklogic.com/rest-api/resource/compile";
(:declare %private function app:performCheck($query, $options){
  let $staticCheck:=
    try{
      xdmp:eval(xs:string($query,(), $options))
    }catch($exception){
        $exception
    }
  return
    if ($staticCheck="") then
      (<json/>)
    else
      ($staticCheck)
};:)

declare %private function app:checkQuery($query, $options){
  try{
    let $check:=xdmp:eval($query,(), $options)
    return
      '{"result":"pass"}'
  }catch($err){
    let $frame1:=$err/error:stack/error:frame[1]
    let $code:=replace($err/error:format-string/text(), '"', "'")
    let $line:=if ($frame1/error:line) then ($frame1/error:line/text()) else ("1")
    let $column:=if ($frame1/error:column) then ($frame1/error:column/text()) else ("1")
    let $text:=$err/error:data/error:datum/text()
    return
      '{
      "result": "fail",
      "error": {
        "code": "'||$code||'",
        "line": "'||$line||'",
        "column": "'||$column||'",
        "#text": "'||$code||'"
        }
      }'
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
  let $path := replace(map:get($params, "base"), "//", "/")
  let $dbName := tokenize($path, "/")[3]
  (:let $dbName:="Documents":)
  let $options:=
    <options xmlns="xdmp:eval">
      <database>{xdmp:database($dbName)}</database>
      <static-check>true</static-check>
    </options>
  let $result:=app:checkQuery(xdmp:quote($input), $options)
  return
    (
      map:put($context, "output-types", "application/json"),
      xdmp:set-response-code(200, "OK"),
      document {
        $result
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
