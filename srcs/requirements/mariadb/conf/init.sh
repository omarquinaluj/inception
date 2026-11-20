#!/bin/bash

# Configure MariaDB before starting it
sed -i 's/bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Initialize the database only on the first run
if [ ! -d /var/lib/mysql/mysql ]; then
	mysqld_safe --datadir=/var/lib/mysql &

	# Wait for MariaDB to be ready
	until mysqladmin ping -h localhost --silent; do
		sleep 1
	done

	mysql -u root << EOF_SQL
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF_SQL

	mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
fi

# Run MariaDB as the main container process
exec mysqld_safe --datadir=/var/lib/mysql
