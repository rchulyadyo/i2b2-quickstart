installs i2b2 hive and webclient on centos vm, amazon webservice and Docker  (see wiki for details)

### Quickstart

ssh to centos machine

sudo yum -y install git wget unzip patch bzip2 screen

screen

export IP_ADDRESS=[external IP ADDRESS or hostname]

git clone --depth=1 https://github.com/waghsk/i2b2-quickstart.git

cd i2b2-quickstart

sudo sh scripts/install/centos_first_install.sh $IP_ADDRESS 2>&1|tee first.log

Remember to use the **public/external IP_ADDRESS** of the instance in the cmd above.

### To verify installation see: http://[ipaddress]/webclient/


see http://ipaddress/webclient/

### Tips

to allow remote connections to database add 

listen_addresses='*'

to /var/lib/pgsql9/data/postgresql.conf

### To create i2b2 docker containers
sudo sh scripts/docker/run_docker_network.sh PUBLIC_IP

### To directly install i2b2 docker containers from docker hub
see instructions in wiki at [link](https://github.com/waghsk/i2b2-quickstart/wiki/Docker)
