
IP=$1


if [[ $IP ]];then
	echo "using given IP"
else
	IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
	echo "IP:$IP"
fi

sudo yum -y install ant tar sed bzip2 git php perl wget zip unzip httpd patch
setenforce 0
service iptables stop

sudo yum install java-1.8.0-openjdk-devel
 
sudo -u nobody bash -c : && RUNAS="sudo -u $SUDO_USER"

$RUNAS bash << _
#git clone https://github.com/waghsk/i2b2-install
#cd i2b2-install
source scripts/install/install.sh
download_i2b2_source $(pwd)
unzip_i2b2core $(pwd)
_


BASE=$(pwd)
source scripts/install/centos_sudo_install.sh
install_httpd
install_i2b2webclient $(pwd) $IP

install_postgres

$RUNAS bash << _
if psql -U postgres -lqt | cut -d \| -f 1 |grep "i2b2";then
	echo "i2b2 db exists in postgres"
else
	source scripts/postgres/load_data.sh $(pwd)
	create_db_schema $(pwd) "-U postgres";
	load_demo_data $(pwd) " -d i2b2 " $IP 
fi
_

$RUNAS bash << _
source scripts/install/install.sh
check_homes_for_install $(pwd)
compile_i2b2core $(pwd)  
run_wildfly $(pwd)
_
