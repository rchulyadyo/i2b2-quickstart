# Dockerfile to i2b2 Wildfly application server

## Building the image
```
docker build -t local/i2b2-wildfly .
```

## Running 
```
docker run -e DS_PASS=<password_for_database_user> -e DS_IP=<database_hostname> local/i2b2-wildfly  
```
