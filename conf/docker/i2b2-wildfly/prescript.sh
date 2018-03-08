#!/bin/bash

echo ">>>running prescript"
echo "DS_TYPE:$DS_TYPE"
echo "DS_IP:$DS_IP"
echo "DS_CRC_IP:$DS_CRC_IP"
echo "DS_ONT_IP:$DS_ONT_IP"

#echo "copying datasources for particular type of db:$DSTYPE"
cp -rv /opt/jboss/config/$DSTYPE/* /opt/jboss/wildfly/standalone/deployments/


cd /opt/jboss/wildfly/standalone/deployments/;

for x in $(find -iname '*.xml');
 do
        echo ">>>$x"
        echo ${DS_IP}
        y="/opt/jboss/wildfly/standalone/deployments/$x"
        ls -hla $y;
        cat $y|sed  "s/localhost:5432/$DS_IP:$DS_PORT/" >tmp
        mv tmp $y;
#sed -i  s/localhost:5432/${DS_IP}:${DS_PORT}/ \"$x\";
done


DsDIR="/configtemp/dsconfig/$DS_TYPE"
TarPrefix="/opt/jboss/wildfly/standalone/deployments/"
cat $DsDIR/crc-ds.xml| sed  "s/DS_CRC_IP:DS_CRC_PORT/$DS_CRC_IP:$DS_CRC_PORT/" | sed  "s/DS_CRC_USER/$DS_CRC_USER/" | sed  "s/DS_CRC_PASS/$DS_CRC_PASS/" > $TarPrefix/crc-ds.xml

cat $DsDIR/im-ds.xml| sed  "s/DS_IM_IP:DS_IM_PORT/$DS_IM_IP:$DS_IM_PORT/" | sed  "s/DS_IM_USER/$DS_IM_USER/" | sed  "s/DS_IM_PASS/$DS_IM_PASS/" > $TarPrefix/im-ds.xml

cat $DsDIR/ont-ds.xml| sed  "s/DS_ONT_IP:DS_ONT_PORT/$DS_ONT_IP:$DS_ONT_PORT/" | sed  "s/DS_ONT_USER/$DS_ONT_USER/" | sed  "s/DS_ONT_PASS/$DS_ONT_PASS/" > $TarPrefix/ont-ds.xml

cat $DsDIR/pm-ds.xml| sed  "s/DS_PM_IP:DS_PM_PORT/$DS_PM_IP:$DS_PM_PORT/" | sed  "s/DS_PM_USER/$DS_PM_USER/" | sed  "s/DS_PM_PASS/$DS_PM_PASS/" > $TarPrefix/pm-ds.xml

cat $DsDIR/work-ds.xml| sed  "s/DS_WD_IP:DS_WD_PORT/$DS_WD_IP:$DS_WD_PORT/" | sed  "s/DS_WD_USER/$DS_WD_USER/" | sed  "s/DS_WD_PASS/$DS_WD_PASS/" > $TarPrefix/work-ds.xml


for x in $(ls $JBOSS_HOME/standalone/deployments/*-ds.xml)
              do sed -i -e 's/postgresql\-9\.2\-1002\.jdbc4\.jar/postgresql\-42\.1\.4\.jar/g' $x ;
       done;

cd /opt/jboss/wildfly/standalone/deployments/;

/opt/jboss/wildfly/bin/standalone.sh -b 0.0.0.0

exit

