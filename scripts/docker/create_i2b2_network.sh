#!/bin/sh
BASE=$1
DOCKER_HOME=$BASE/local/docker

DIP=$2
alias docker=" docker"

echo "DIP:$DIP"

docker network create i2b2-net

echo "PWD;$(pwd)"

	source $BASE/scripts/install/install.sh $BASE
	check_homes_for_install $BASE
	download_i2b2_source $BASE
	unzip_i2b2core $BASE
#Docker App Path
APP=i2b2-wildfly
DAP=$DOCKER_HOME/$APP
if [ -d $DAP ]; then
	echo "found $DAP"
else
	mkdir -p "$DAP" & echo "created $DAP"
	
	mkdir -p $DAP/jbh
	
	cp -rv $BASE/conf/docker/$APP/* $DAP

	
	JBOSS_HOME=$DAP/jbh
	echo "JBOSS_HOME=$JBOSS_HOME"
	copy_axis_to_wildfly $JBOSS_HOME	
	copy_axis2_to_wildfly_i2b2war $BASE $JBOSS_HOME	

	compile_i2b2core $BASE $JBOSS_HOME $JBOSS_HOME /opt/jboss/wildfly
	cd  $DAP/jbh/standalone/
	for x in $(find -iname *.properties); do
		echo "prop##### $x"
		sed -i  s/9090/8080/ "$x"
	done
	tar -cvjf deploy.tar.bz2 deployments/*
	tar -cvjf config.tar.bz2 configuration/*
	
	cd $BASE


	docker stop $APP;docker rm $APP; docker rmi i2b2/$APP
	docker build  -t local/i2b2-wildfly $DAP/
	docker run -d -p 8080:8080 --net i2b2-net --name $APP local/i2b2-wildfly
	

fi

APP=i2b2-web
DAP="$DOCKER_HOME/$APP"

if [ -d $DAP ]; then
	echo "found $DAP"
else
	mkdir -p "$DAP" && echo "created $DAP"
	echo "BASE:$BASE DIP:$DIP DAP:$DAP"
	source $BASE/scripts/install/centos_sudo_install.sh $BASE
	DIP=$2
	copy_webclient_dir $BASE $DIP $DAP

	cp -rv $BASE/conf/httpd/* $DAP
	cp -rv $BASE/conf/docker/$APP/* $DAP
#	sed -i  s/9090/8080/ $DAP/i2b2_proxy.conf
#	sed -i  s/localhost/$DIP/ $DAP/i2b2_proxy.conf
#	sed -i  s/localhost/i2b2-wildfly/ $DAP/i2b2_proxy.conf

	docker stop $APP;docker rm $APP; docker rmi i2b2/$APP
	docker build  -t local/i2b2-web $DAP/
	docker run -d  -p 443:443 -p 80:80 --net i2b2-net -e APP_IP="$DIP" --name i2b2-web local/i2b2-web /run-httpd.sh 
fi


APP=i2b2-pg
DAP="$DOCKER_HOME/$APP"


if [ -d $DAP ]; then
	echo "found $DAP"
else
	mkdir -p "$DAP" & echo "created $DAP"
	docker rm -f i2b2-pg-empty;
	docker stop $APP;docker rm $APP; docker rmi i2b2/$APP

	export PGIP=0.0.0.0
		
	
	cp -rv $BASE/conf/docker/$APP/* $DAP
	
	docker build  -t local/i2b2-pg $DAP/
	docker run -d  -p 5432:5432 --net i2b2-net --name i2b2-pg   -e 'DB_USER=i2b2' -e 'DB_PASS=pass' -e 'DB_NAME=i2b2' local/i2b2-pg

	source $BASE/scripts/postgres/load_data.sh $(pwd) 

	USERT=" -U i2b2 -d i2b2 -h $PGIP ";
	echo "USERT=$USERT"
#	#echo "\dt+;"|psql $USERT
	sleep 25
	export PGPASSWORD=demouser;echo "\dt+;"|psql -h $PGIP -U i2b2 -d i2b2
	create_db_schema $(pwd) "$USERT";
        load_demo_data $(pwd) " -h $PGIP -d i2b2 " $DIP

	#docker rm -f i2b2/i2b2-pg
	#docker run -d  -p 5432:5432 --net i2b2-net --name i2b2-pg   i2b2/i2b2-pg:latest
	#sleep 5;
	#docker tag i2b2
	CID=$(docker ps -aqf "name=i2b2-empty")
	docker commit $CID local/i2b2-pg
	docker exec -it i2b2-pg bash -c "export PUBLIC_IP=$IP_ADD;sh update_pm_cell_data.sh; "


fi


