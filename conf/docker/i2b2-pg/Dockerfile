FROM postgres:9

# I2B2 database superuser
ENV I2B2_DB i2b2
ENV I2B2_DB_USER i2b2
ENV I2B2_DB_PWD demouser

# I2B2 superuser and database creation script will run as part of Postgres bootstrap 
COPY create_i2b2_db.sh /docker-entrypoint-initdb.d/0_create_i2b2_db.sh
