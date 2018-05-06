# mlExide2

deploy xq-doc

```
curl --anyauth --user admin:admin -T ./data/ml-functions.xml -i \
     -H "Content-type: application/xml" \
     http://localhost:8020/v1/documents?uri=/ml-functions.xml
```
