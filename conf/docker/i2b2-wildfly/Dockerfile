FROM jboss/wildfly:10.0.0.Final
LABEL maintainer=" <Kavishwar (Kavi)  Wagholikar waghsk@gmail.com>"

ENV DS_IP ${DS_IP:-i2b2-pg}
ENV DS_PORT ${DS_PORT:-5432}
ENV DS_TYPE ${DS_TYPE:-pg}
ENV DS_PASS ${DS_PASS:-demouser}

ENV ADMIN_USER ${ADMIN_USER:-admin}
ENV ADMIN_PASS ${ADMIN_USER:-demoadmin}

# Create management users 
RUN /opt/jboss/wildfly/bin/add-user.sh ${ADMIN_USER} ${ADMIN_PASS} --silent 

# App related configs
COPY jbh/standalone/configuration /opt/jboss/wildfly/standalone/configuration/

# Wildfly configs
COPY wfconfig /opt/jboss/wildfly/standalone/configuration/ 

# JDBC driver
COPY dsconfig/${DS_TYPE}/driver  /opt/jboss/wildfly/modules/

# I2b2 WAR
COPY jbh/standalone/deployments/i2b2.war /opt/jboss/wildfly/standalone/deployments/

# Expose the ports we're interested in
EXPOSE 9090 

# This will boot WildFly in the standalone mode and bind to all interface
CMD ["sh","/opt/jboss/wildfly/bin/standalone.sh","-c","standalone.xml","-b","0.0.0.0","-bmanagement", "0.0.0.0"]