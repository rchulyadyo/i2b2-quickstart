FROM jboss/wildfly:10.0.0.Final
LABEL maintainer=" <Kavishwar (Kavi)  Wagholikar waghsk@gmail.com>"

# Datasource IP or hostname
ENV DS_IP i2b2-pg

# Datasource port
ENV DS_PORT 5432

# Datasource password
ENV DS_PASS demouser

# Datasource type
# only pg is supported at this time for DS_TYPE
ENV DS_TYPE pg

# Download URL of JDBC driver
ENV DS_DRIVER_URL http://search.maven.org/remotecontent?filepath=org/postgresql/postgresql/9.4-1204-jdbc4/postgresql-9.4-1204-jdbc4.jar

# Wildfly admin user
ENV ADMIN_USER admin

# Wildfly admin password
ENV ADMIN_PASS demoadmin

# Create management users 
RUN /opt/jboss/wildfly/bin/add-user.sh ${ADMIN_USER} ${ADMIN_PASS} --silent 

# App related configs
COPY standalone/configuration/crcapp /opt/jboss/wildfly/standalone/configuration/crcapp
COPY standalone/configuration/ontologyapp /opt/jboss/wildfly/standalone/configuration/ontologyapp
COPY standalone/configuration/workplaceapp /opt/jboss/wildfly/standalone/configuration/workplaceapp

# Standalone configuration tailred to database source type
COPY standalone/configuration/standalone-${DS_TYPE}.xml /opt/jboss/wildfly/standalone/configuration/standalone.xml


# JDBC driver download 
RUN mkdir -p /opt/jboss/wildfly/modules/i2b2jdbc/main/ && \
    curl --location --silent --output /opt/jboss/wildfly/modules/i2b2jdbc/main/i2b2-jdbc.jar --url ${DS_DRIVER_URL}

# To install datasource driver as a module
COPY modules/i2b2jdbc/main/module.xml /opt/jboss/wildfly/modules/i2b2jdbc/main/module.xml

# I2b2 WAR
COPY standalone/deployments/i2b2.war.zip /tmp 
RUN unzip -q /tmp/i2b2.war.zip -d /opt/jboss/wildfly/standalone/deployments/ \
   && touch /opt/jboss/wildfly/standalone/deployments/i2b2.war.dodeploy

# Expose the ports we're interested in
EXPOSE 9090 

# This will boot WildFly in the standalone mode and bind to all interface
CMD ["sh","/opt/jboss/wildfly/bin/standalone.sh","-c","standalone.xml","-b","0.0.0.0","-bmanagement", "0.0.0.0"]
