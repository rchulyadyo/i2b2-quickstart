#git clone https://github.com/waghsk/i2b2-install


BASE=$1

#sudo yum -y install git php perl wget zip unzip httpd 

install_postgres(){
	if [ -d /var/lib/pgsql/9.4/data/ ]
	then echo "postgres already installed"
	else
		#sudo yum install -y http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-redhat94-9.4-1.noarch.rpm
		#sudo yum install -y http://yum.postgresql.org/9.4/redhat/rhel-6-x86_64/pgdg-redhat94-9.4-1.noarch.rpm	
		#sudo wget https://www.dropbox.com/s/igqmyfj8boijvaz/pgdg-centos94-9.4-1.noarch.rpm
		#sudo yum -y install pgdg-centos94-9.4-1.noarch.rpm
                #sudo yum -y install postgresql94-server postgresql94-contrib		
		sudo yum install -y postgresql-server
		sudo rm -rf /var/lib/pgsql/
		sudo mkdir /var/lib/pgsql/
		chown -R postgres:postgres /var/lib/pgsql/
		sudo [ -f /usr/pgsql/bin/postgresql94-setup ] && sudo /usr/pgsql/bin/postgresql94-setup initdb || sudo service postgresql initdb
		sudo chkconfig postgresql on 
		sudo cp conf/postgresql/pg_hba.conf  /var/lib/pgsql/data/
		sudo service postgresql start
		
	fi
}

install_httpd(){
		if [ -f /etc/httpd/conf.d/i2b2_proxy.conf ]; then
			echo "httpd already installed"
		else
			#echo "ProxyPreserveHost on" > /etc/httpd/conf.d/i2b2_proxy.conf		
			echo "ProxyPass /i2b2/ http://localhost:9090/i2b2/" > /etc/httpd/conf.d/i2b2_proxy.conf		
			echo "ProxyPassReverse /i2b2/ http://localhost:9090/i2b2/" >> /etc/httpd/conf.d/i2b2_proxy.conf		
			sudo chkconfig httpd on 
			sudo service httpd start
			sudo /usr/sbin/setsebool httpd_can_network_connect 1
			sudo sed -i s/SELINUX=enforcing/SELINUX=disabled/ /etc/sysconfig/selinux 
		fi
}

#mariadb
install_mysql(){
	cp $BASE/conf/yum/mariadb_centos.repo /etc/yum.repos.d/
	sudo yum -y install mysql
}

install_vpn(){
	yum install epel-release
	sudo yum -y install openvpn
}

install_i2b2webclient(){
	BASE=$1
	IP=$2
	BASE_CORE=$BASE/unzipped_packages
	echo "BASE_CORE:$BASE_CORE"
	[ -d $BASE_CORE/i2b2-webclient-master/ ]|| echo " webclient source not found"  
	[ -d $BASE_CORE/i2b2-webclient-master/ ]||  exit 

	if [ -d /var/www/html/webclient ]
	then echo "webclient folder already exists"
	else 
		copy_webclient_dir $BASE $IP /var/www/html
	fi
}

copy_webclient_dir(){
	local BASE=$1
	local IP=$2
	local TAR=$3

	echo "received  BASE:$BASE IP:$IP TAR:$TAR"
	if [ -d $TAR ];then
		echo "found $TAR"
	else 
		 echo "dir:$TAR does not exist"  
		exit
	fi

	UNZIP_DIR=$BASE/unzipped_packages
		mkdir $TAR/admin
		mkdir $TAR/webclient/
		cp -rv $UNZIP_DIR/i2b2-webclient-master/* $TAR/admin/
		cp -rv $UNZIP_DIR/i2b2-webclient-master/* $TAR/webclient/
		cp $BASE/conf/webclient/i2b2_config_data.js $TAR/webclient/
		cp $BASE/conf/admin/i2b2_config_data.js $TAR/admin/
		sed -i -- "s/127.0.0.1/$IP/" $TAR/webclient/i2b2_config_data.js
		sed -i -- "s/127.0.0.1/$IP/" $TAR/admin/i2b2_config_data.js

}
#install_httpd
#install_webclient
#install_postgres
#load_demo_data
