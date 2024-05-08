
### Pre-Compilation 

```sh
db2 prep basic_sql.cbl output basic_sql.bnd
```

### Compilation 
```sh
cob2 -c -I /opt/ibm/db2/V11.5.9/include/cobol_c basic_sql.bnd
```