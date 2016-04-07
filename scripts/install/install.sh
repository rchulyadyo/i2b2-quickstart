
PWD=$(pwd)
BASE=$PWD
#LOCAL HOME
LOCAL=$BASE/local

#CONFIGURE
JBOSS_HOME=$LOCAL/jboss-as-7.1.1.Final
JAVA_HOME=$LOCAL/jdk1.7.0_51
AXIS_HOME=$LOCAL/axis
ANT_HOME=$LOCAL/ant
##########

echo "in INSTALL FILE PWD:$PWD"

AXIS_FILE=axis2-1.6.2-war.zip
JDK_FILE=jdk-7u51-linux-x64.tar.gz
ANT_FILE=apache-ant-1.9.6-bin.tar.bz2
JBOSS_FILE=jboss-as-7.1.1.Final.tar.gz

#check if the home directories are found as specified by user, or use default dirs
[ -d $JAVA_HOME ] || JAVA_HOME=$LOCAL/jdk1.7.0_51;#$LOCAL/${JDK_FILE/\.tar\.gz/}
[ -d $JBOSS_HOME ] || JBOSS_HOME=$LOCAL/${JBOSS_FILE/\.tar\.gz/}
[ -d $ANT_HOME ] || ANT_HOME=$LOCAL/${ANT_FILE/-bin\.tar\.bz2/}
[ -d $AXIS_HOME ] || AXIS_HOME=$LOCAL/axis

alias ant=$ANT_HOME/bin/ant
alias java="$JAVA_HOME/bin/java"

export JAVA_HOME=$JAVA_HOME

echo ">>JBOSS_HOME:$JBOSS_HOME"
[ -d $BASE/packages ] || mkdir -p $BASE/packages

echo ">>>ran config"



check_homes_for_install(){
	[ -d $LOCAL ] || mkdir $LOCAL	

	[ -d $JAVA_HOME ] && echo "found JAVA_HOME:$JAVA_HOME"|| install_java
	[ -d $ANT_HOME ] && echo "found ANT_HOME:$ANT_HOME"|| install_ant
	[ -d $AXIS_HOME ] && echo "found AXIS_HOME:$AXIS_HOME"|| download_axis_jar;
	[ -d $JBOSS_HOME ] && echo "found JBOSS_HOME:$JBOSS_HOME"|| download_wildfly && install_wildfly	
}
 
download_i2b2_source(){
	BASE=$1
	cd $BASE/packages;
	for x in i2b2-webclient i2b2-core-server i2b2-data; do
	#for x in i2b2-webclient i2b2-data; do
	 echo " downloading $x"
	[ -f  $x.zip ] || wget -v https://github.com/i2b2/$x/archive/master.zip -O $x.zip
	done
}

unzip_i2b2core(){
	[ -d $BASE/unzipped_packages ] || mkdir $BASE/unzipped_packages
	cd $BASE/unzipped_packages
	for x in $(ls ../packages/i2b2*.zip | xargs -n 1 basename); do 
		f=${x/\.zip/-master}
		echo "unzipping $x from $f";
		 [ -d $f ] || unzip ../packages/$x
	done
	
	cd i2b2-core-server-master/edu.harvard.i2b2.crc/src/server;
	patch -p1 < ../../../../../packages/patch_crc_PDOcall
}

install_java(){
	echo "installing java"
	cd $BASE/packages
	if [ -f $JDK_FILE ]
	then echo "FOUND $JDK_FILE" 
	else
		curl --create-dirs -L --cookie "oraclelicense=accept-securebackup-cookie; gpw_e24=http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html" http://download.oracle.com/otn-pub/java/jdk/7u51-b13/$JDK_FILE -o $JDK_FILE
	fi

	cd $LOCAL	
	if [ -f $BASE/packages/$JDK_FILE ]; then echo "found jdk file";
		tar -xvzf $BASE/packages/$JDK_FILE
	else 
		echo "ERROR: could not find: $BASE/packages/$JDK_FILE" 1>&2
		exit 75;
	fi
}

install_ant(){
	cd $BASE/packages
	if [ -f $ANT_FILE ]
	then echo "Found $ANT_FILE"
	else
		wget http://apache.mirrors.ionfish.org//ant/binaries/$ANT_FILE
	fi
	cd $BASE
	if [ -d $ANT_HOME ];then echo "FOUND ANT_HOME:$ANT_HOME"
	else	
		cd $LOCAL	
		tar -xvjf $BASE/packages/$ANT_FILE 
	fi
	cd $BASE
}


download_axis_jar(){
	cd $BASE/packages
	if [ -f $AXIS_FILE ]
	then echo ""
	else
		wget https://www.i2b2.org/software/projects/installer/$AXIS_FILE	
	fi

		
	if [ -d $BASE/packages/$AXIS_FILE ]; then echo "found axis dir";
	else	
		cd $LOCAL
		mkdir axis
		cd axis
		echo "AF:$AXIS_FILE"
		unzip $BASE/packages/$AXIS_FILE
		cp  axis2.war axis2.zip
	fi
	cd $BASE
}

download_wildfly(){
	cd $BASE/packages
	if [ -f $JBOSS_FILE ]
	then echo "FOUND $JBOSS_FILE"
	else
		wget http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/$JBOSS_FILE
	fi
	cd $BASE
}

install_wildfly(){
	cd $LOCAL || echo "error local home not found" 
	if [ -d $JBOSS_HOME ]
	then echo "FOUND $JBOSS_HOME"
	else
		tar -xvzf $BASE/packages/$JBOSS_FILE
		
		mkdir -p $JBOSS_HOME/standalone/deployments/i2b2.war

		cd "$JBOSS_HOME/standalone/deployments/i2b2.war"
		unzip $AXIS_HOME/axis2.zip
		echo ""> $JBOSS_HOME/standalone/deployments/i2b2.war.dodeploy
		sed -i -e s/port-offset:0/port-offset:1010/  "$JBOSS_HOME/standalone/configuration/standalone.xml"

	fi
}


compile_i2b2core(){
	local BASE_CORE="$BASE/unzipped_packages/i2b2-core-server-master"
	local CONF_DIR=$BASE/conf
	local DB=postgres	

	local TAR_DIR="$BASE_CORE/edu.harvard.i2b2.server-common"
	cd $TAR_DIR
	echo "jboss.home=$JBOSS_HOME" >> "$TAR_DIR/build.properties"
	export PATH="$PATH:$ANT_HOME/bin/:$JAVA_HOME/bin:"
	ant clean dist deploy jboss_pre_deployment_setup

	echo "PWD:$PWD"

	local CELL_NAME="pm"
	local TAR_DIR="$BASE_CORE/edu.harvard.i2b2.${CELL_NAME}"
	cd $TAR_DIR
	echo "jboss.home=$JBOSS_HOME" >> "$TAR_DIR/build.properties"
	cp -rv "$CONF_DIR/$CELL_NAME"/etc-jboss/$DB/* etc/jboss/
	ant -f master_build.xml clean build-all deploy

	#etc/jboss/*-ds.xml dataSourceconfig files are finally placed into deployment dir
	#etc/spring/*.properties file finally go into $JBOSS_HOME/standalone/configuration/*/ 
	
	#default ontology.properties is used
	#ontology_application_directory.properties is appended : edu.harvard.i2b2.ontology.applicationdir=/YOUR_JBOSS_HOME_DIR/standalone/configuration/ontologyapp
	#JBOSS home is appended to build.properties
	#data source config files is copied
	CELL_NAME="ontology"
	TAR_DIR="$BASE_CORE/edu.harvard.i2b2.${CELL_NAME}"
	cd $TAR_DIR
	echo "jboss.home=$JBOSS_HOME" >> "$TAR_DIR/build.properties"
	echo "edu.harvard.i2b2.ontology.applicationdir=$JBOSS_HOME/standalone/configuration/ontologyapp" >> "$TAR_DIR/etc/spring/ontology_application_directory.properties"
	cp -rv "$CONF_DIR/$CELL_NAME"/etc-jboss/$DB/* etc/jboss/
	ant -f master_build.xml clean build-all deploy


	#default /etc/spring/crc.properties is used
	#crc_application_directory.properties is appended : edu.harvard.i2b2.crc.applicationdir=/YOUR_JBOSS_HOME_DIR/standalone/configuration/crcapp
	#JBOSS home is appended to build.properties
	#data source config files is copied
	export CELL_NAME="crc"
	export TAR_DIR="$BASE_CORE/edu.harvard.i2b2.${CELL_NAME}"
	cd $TAR_DIR
	echo "jboss.home=$JBOSS_HOME" >> "$TAR_DIR/build.properties"
	cp -rv "$CONF_DIR/$CELL_NAME"/etc-jboss/$DB/* etc/jboss/
	echo "edu.harvard.i2b2.crc.applicationdir=$JBOSS_HOME/standalone/configuration/crcapp" >> "$TAR_DIR/etc/spring/crc_application_directory.properties"
	ant -f master_build.xml clean build-all deploy

	#default /etc/spring/workplace.properties is used
	#workplace_application_directory.properties is appended : edu.harvard.i2b2.workplace.applicationdir=/YOUR_JBOSS_HOME_DIR/standalone/configuration/workplaceapp
	#JBOSS home is appended to build.properties
	#data source config files is copied
	export CELL_NAME="workplace"
	export TAR_DIR="$BASE_CORE/edu.harvard.i2b2.${CELL_NAME}"
	cd $TAR_DIR
	echo "jboss.home=$JBOSS_HOME" >> "$TAR_DIR/build.properties"
	cp -rv "$CONF_DIR/$CELL_NAME"/etc-jboss/$DB/* etc/jboss/
	echo "edu.harvard.i2b2.workplace.applicationdir=$JBOSS_HOME/standalone/configuration/workplaceapp" >> "$TAR_DIR/etc/spring/workplace_application_directory.properties"
	ant -f master_build.xml clean build-all deploy


}
run_wildfly(){

#	cd $JBOSS_HOME
	sh $JBOSS_HOME/bin/standalone.sh
}

#check_homes_for_install $(pwd)
#compile_i2b2core $(pwd)
#run_wildfly $(pwd)


#download_i2b2_source
#unzip_i2b2core
#exit
#check_homes_for_install

#create_tables_and_load_data_postgres
#compile_i2b2core
#run_wildfly

#change path to cells in the hive after logging in as admin
