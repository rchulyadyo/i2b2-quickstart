BASE=$1
SUF=$2  #i2b2-core-server

if [ $SUF == "wildfly" ]; then
	PAK="i2b2-$SUF"
	PAKTAR="i2b2-core-server" 
elif [ $SUF == "web" ]; then
		PAK="i2b2-$SUF"
		PAKTAR="i2b2-webclient" 
elif [ $SUF == "pg" ]; then
		PAK="i2b2-$SUF"
		PAKTAR="i2b2-data" 
fi

check_pass_set(){
	_PASS=$1
	echo " checking $1"
	if [ ! -v $1 ]; then
		echo "$_PASS is not set"
		exit
	else
		echo " FOUND $_PASS"
	fi
}

create_dir(){
	_TDIR=$1
	if [ -d $_TDIR ]; then
		echo "found $_TDIR"
	else
		echo "creating $_TDIR"
		mkdir -p $_TDIR
	fi;
}

write_history(){
	_PAK=$1
	_TAG=$2
	echo "$_TAG">"$HISTORY_DIR/$_PAK"
}

check_pass_set I2B2AUTO_PASS
check_pass_set DOCKER_CONTENT_TRUST_ROOT_PASSPHRASE
check_pass_set DOCKER_CONTENT_TRUST_REPOSITORY_PASSPHRASE
check_pass_set IP_ADD
check_pass_set PAKTAR


TAG=$(curl https://api.github.com/repos/i2b2/$PAKTAR/releases/latest | grep "tag_name"|cut -d: -f2|tr -d ",\" ")
echo $TAG
TDIR="$BASE/unzipped_packages/$PAKTAR-master/"
HISTORY_DIR="$BASE/history"


create_dir $TDIR;
create_dir $HISTORY_DIR;

LAST_TAG=$(cat $HISTORY_DIR/$PAK)

if [ "$LAST_TAG" == "$TAG" ]; then
	echo "latest release was already processed"
	exit
else 
	cd $TDIR
	LINK="https://github.com/i2b2/$PAKTAR/archive/$TAG.tar.gz"
	echo "downloading $LINK"
	wget -O downloaded_tar $LINK && write_history $PAK $TAG
	tar -xvzf downloaded_tar --strip 1
	rm -rf downloaded_tar
fi

cd $BASE

rm -rf $BASE/local/docker/$PAK
docker rmi -f i2b2/$SUF:release-$TAG
sh $BASE/scripts/docker/create_i2b2_network.sh  $BASE $IP_ADD |tee firstlog

IMG=$(docker images local/i2b2-$SUF --format {{.ID}})
docker tag $IMG i2b2/$PAK:release-$TAG
docker login -u i2b2auto -p "$I2B2AUTO_PASS"
docker push i2b2/$PAK:release-$TAG

docker tag $IMG i2b2/$PAK:latest
docker login -u i2b2auto -p "$I2B2AUTO_PASS"
docker push i2b2/$PAK:latest

