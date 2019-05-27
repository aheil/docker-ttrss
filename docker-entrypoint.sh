#!/bin/bash

# exit script if any command errors
set -eo pipefail 

# create config.php if it does not exist
if [ ! -f /var/www/html/config.php ]; then
	echo "Initializing config.php"
	cp /var/www/html/config.php-dist /var/www/html/config.php
fi

# let any paramter be set at container runtime 
# not all options are supported, yet
[[ "${DB_TYPE+x}" ]] && sed -i "s|\s*define('DB_TYPE',.*|\tdefine('DB_TYPE', '$DB_TYPE');|g" /var/www/html/config.php
[[ "${DB_HOST+x}" ]] && sed -i "s|\s*define('DB_HOST',.*|\tdefine('DB_HOST', '$DB_HOST');|g" /var/www/html/config.php
[[ "${DB_USER+x}" ]] && sed -i "s|\s*define('DB_USER',.*|\tdefine('DB_USER', '$DB_USER');|g" /var/www/html/config.php
[[ "${DB_NAME+x}" ]] && sed -i "s|\s*define('DB_NAME',.*|\tdefine('DB_NAME', '$DB_NAME');|g" /var/www/html/config.php
[[ "${DB_PASS+x}" ]] && sed -i "s|\s*define('DB_PASS',.*|\tdefine('DB_PASS', '$DB_PASS');|g" /var/www/html/config.php
[[ "${DB_PORT+x}" ]] && sed -i "s|\s*define('DB_PORT',.*|\tdefine('DB_PORT', '$DB_PORT');|g" /var/www/html/config.php
[[ "${SELF_URL_PATH+x}" ]] && sed -i "s|\s*define('SELF_URL_PATH',.*|\tdefine('SELF_URL_PATH', '$SELF_URL_PATH');|g" /var/www/html/config.php
[[ "${REG_NOTIFY_ADDRESS+x}" ]] && sed -i "s|\s*define('REG_NOTIFY_ADDRESS',.*|\tdefine('REG_NOTIFY_ADDRESS', '$REG_NOTIFY_ADDRESS');|g" /var/www/html/config.php
[[ "$SMTP_FROM_ADDRESS+x}" ]] && sed -i "s|\s*define('SMTP_FROM_ADDRESS',.*|\tdefine('SMTP_FROM_ADDRESS', '$SMTP_FROM_ADDRESS');|g" /var/www/html/config.php


function database_init() {
	output=$(psql "dbname='$DB_NAME' user='$DB_USER' password='$DB_PASS' host='$DB_HOST' port='$DB_PORT'" -t -c "SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'ttrss_version') THEN 1 ELSE 0 END;" 2>/dev/null)

	# if DB is not initialized 
	if [ $output -eq 0 ]; then
		echo "[aheilde/ttrss] Initializing database..."
		psql "dbname='$DB_NAME' user='$DB_USER' password='$DB_PASS' host='$DB_HOST' port='$DB_PORT'" -f /var/www/html/schema/ttrss_schema_$DB_TYPE.sql
		echo "[aheilde/ttrss] Database initialization finished"
	else
		echo "[aheilde/ttrss] Database already initialized"
	fi
}

function database_ready() {
  return_value=$(psql "dbname='$DB_NAME' user='$DB_USER' password='$DB_PASS' host='$DB_HOST' port='$DB_PORT'" -t -c "SELECT CASE WHEN EXISTS (SELECT 1 FROM pg_roles WHERE rolname='$DB_USER') THEN 1 ELSE 0 END;" 2>/dev/null)
  return $return_value
}

# wait for database 
maxcounter=30
counter=1

while [ database_ready -eq 0 ]; do
	echo "[aheilde/ttrss] Waiting for DB to come up..."
    sleep 2
    counter=`expr $counter + 1`
        if [ $counter -gt $maxcounter ]; then
            echo "[aheilde/ttrss] Database not available. Aborting."
            exit 1
        fi
done

# make sure database is initialized 
database_init


# configure PHP location 
sed -i "s|\s*define('PHP_EXECUTABLE',.*|\tdefine('PHP_EXECUTABLE', '/usr/local/bin/php');|g" /var/www/html/config.php
# start feed updater
php /var/www/html/update.php --daemon --feeds &

# redirect input variables 
exec "$@"