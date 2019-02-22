# Dockerfile to i2b2 Wildfly application server

## Pre-requisities
Following files must be present:
### WAR archive of i2b2-web
Compile and create the WAR from https://github.com/i2b2/i2b2-core-server.Or, take reference from https://github.com/waghsk/i2b2-quickstart/wiki/create-Docker-images

jbh/standalone/deployments/
├── i2b2.war

### Configuration files from i2b2 web app 
Take reference from https://github.com/waghsk/i2b2-quickstart/wiki/create-Docker-images to get these files.

jbh/standalone/configuration/
├── crcapp
│   ├── CRCApplicationContext.xml
│   ├── CRCLoaderApplicationContext.xml
│   ├── crc.properties
│   └── edu.harvard.i2b2.crc.loader.properties
├── ontologyapp
│   ├── OntologyApplicationContext.xml
│   └── ontology.properties
└── workplaceapp
    └── workplace.properties

## Building the image
```
docker build -t local/i2b2-wildfly .
```

## Running 
```
docker run -e DS_PASS=<password_for_database_user> -e DS_IP=<database_hostname> local/i2b2-wildfly  
```
