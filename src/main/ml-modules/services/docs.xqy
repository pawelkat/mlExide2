xquery version "1.0-ml";

module namespace app = "http://marklogic.com/rest-api/resource/docs";
declare namespace xqdoc="http://www.xqdoc.org/1.0";

import module namespace json = "http://marklogic.com/xdmp/json"
at "/MarkLogic/json/json.xqy";

declare %private function app:builtin-modules($prefix as xs:string) {
  <items type="array" xmlns="http://marklogic.com/xdmp/json/basic">
    {for $func in doc("/ml-functions.xml")//xqdoc:function
    where matches($func/xqdoc:name, concat("^(\w+:)?", $prefix))
    order by $func/xqdoc:name
    return app:describe-function($func)
    }
  </items>
};

declare %private function app:generate-help($desc as element(xqdoc:function)) {
  let $help :=
    <div class="function-help">
      <p><b>{data($desc/xqdoc:short)}</b></p>
      <p>{data($desc/xqdoc:comment/xqdoc:description)}</p>
      <dl>
        {
          for $param in $desc/xqdoc:comment/xqdoc:param
          return
            (
              <dt>{data($param/@name)}</dt>,
              <dd>{$param/text()}</dd>
            )
        }
      </dl>
      <dl>
        {
          for $exmpl in $desc/xqdoc:comment/xqdoc:example
          return
            (
              <dt>Example:</dt>,
              <dd><pre>{$exmpl/text()}</pre></dd>
            )
        }
      </dl>
    </div>
  return
    xdmp:quote($help)
};
declare %private function app:create-template($signature as xs:string) {
  string-join(
          let $signature := "substring($source, $starting, $length)"
          for $token in analyze-string($signature, "\$([^\s,\)]+)")/*
          return
            typeswitch($token)
              case element(fn:match) return
                "$${" || count($token/preceding-sibling::fn:match) + 1 || ":" || $token/fn:group || "}"
              default return
                $token/node()
  )
};

declare %private function app:describe-function($funct) {
  let $signature := data($funct/xqdoc:signature)
  return
    <item type="object" xmlns="http://marklogic.com/xdmp/json/basic">
      <signature type="string">{$signature}</signature>
      <template type="string">{app:create-template($signature)}</template>
      <help type="string">{app:generate-help($funct)}</help>
      <type type="string">function</type>
      <visibility type="string">public</visibility>
    </item>
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
  let $prefix := map:get($params, "prefix")
  let $json:=xdmp:to-json-string(json:transform-to-json(app:builtin-modules($prefix)))
  return
    (
      map:put($context, "output-types", "application/json"),
      xdmp:set-response-code(200, "OK"),
      document { ''||$json }
    )
};

declare function delete(
  $context as map:map,
  $params  as map:map
  ) as document-node()?
{
  xdmp:log("DELETE called")
};
