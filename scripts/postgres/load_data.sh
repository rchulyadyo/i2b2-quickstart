
load_demo_data(){

	echo "loading DEMO data"
	#BASE="/home/ec2-user/i2b2-install"
	BASE=$1
	DATA_BASE="$BASE/unzipped_packages/i2b2-data-master"

	PARG=$2
	IP=$3

	cd "$DATA_BASE/edu.harvard.i2b2.data/Release_1-7/NewInstall/Crcdata/"
	echo ">>>>>pwd:$PWD IP:$IP"
	#local POPTS="dbname=i2b2 options=--search_path='i2b2demodata'"
	
	cat scripts/crc_create_datamart_postgresql.sql|psql  -U i2b2demodata $PARG 
	cat scripts/crc_create_query_postgresql.sql|psql  -U i2b2demodata $PARG 
	cat scripts/crc_create_uploader_postgresql.sql|psql  -U i2b2demodata $PARG 
	cat scripts/expression_concept_demo_insert_data.sql|psql  -U i2b2demodata $PARG 
	#cat scripts/expression_obs_demo_insert_data.sql|psql  -U i2b2demodata $PARG 
	
	#limiting to load only demographics
	#for x in $(ls scripts/postgresql/*demographics*); do cat $x|psql  -U i2b2demodata $PARG;done;
	echo "installing CRC data"
	
	if [ ${ONLY_DEMO} ]; then
		cat scripts/postgresql/observation_fact_demo_demographics_insert_data.sql |psql  -U i2b2demodata $PARG
	else
		for x in $(ls scripts/postgresql/); do cat scripts/postgresql/$x|psql  -U i2b2demodata $PARG;done;
	fi	

	cd "$DATA_BASE/edu.harvard.i2b2.data/Release_1-7/NewInstall/Hivedata/"
	mkdir ~/tmp
	for x in "create_postgresql_i2b2hive_tables.sql" "work_db_lookup_postgresql_insert_data.sql" "ont_db_lookup_postgresql_insert_data.sql" "im_db_lookup_postgresql_insert_data.sql" "crc_db_lookup_postgresql_insert_data.sql"
	do
	cat scripts/$x|psql -U i2b2hive $PARG ;
	done;

	cd ../Pmdata/
	for x in "create_postgresql_i2b2pm_tables.sql" "create_postgresql_triggers.sql"
	do echo $x;cat scripts/$x|psql -U i2b2pm $PARG;done;
	cat scripts/pm_access_insert_data.sql| sed "s/localhost:9090/$IP/" |psql -U i2b2pm $PARG;


	cd "$DATA_BASE/edu.harvard.i2b2.data/Release_1-7/NewInstall/Metadata/"
	for x in $(ls scripts/*postgresql*); do echo $x;cat $x|psql -U i2b2metadata $PARG ;done;
	for x in $(ls demo/scripts/*.sql); do echo $x;cat $x|psql -U i2b2metadata $PARG ;done;

	if [ ${ONLY_DEMO} ]; then
		cat demo/scripts/postgresql/i2b2_metadata_demographics_insert_data.sql|psql -U i2b2metadata $PARG ;
	else
		for x in $(ls demo/scripts/postgresql/*); do echo $x;cat $x|psql -U i2b2metadata $PARG ;done;
	fi

	cd "$DATA_BASE/edu.harvard.i2b2.data/Release_1-7/NewInstall/Workdata/";
	x="scripts/create_postgresql_i2b2workdata_tables.sql"; echo $x;cat $x|psql -U i2b2workdata $PARG;
	x="scripts/workplace_access_demo_insert_data.sql"; echo $x;cat $x|psql -U i2b2workdata $PARG;

	echo "update crc_db_lookup set c_db_fullschema = 'i2b2demodata';\
	update work_db_lookup set c_db_fullschema = 'i2b2workdata';\
	update ont_db_lookup set c_db_fullschema = 'i2b2metadata';
	"|psql -U i2b2hive $PARG;
}

create_db_schema(){
	PARG=$2
	echo "drop database i2b2;"|psql $PARG
	cat $1/scripts/postgres/create_schemas.sql|psql $PARG 
}

#create_db_schema $1;
#load_demo_data $1;
