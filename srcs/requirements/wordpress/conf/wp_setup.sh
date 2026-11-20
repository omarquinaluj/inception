#!/bin/bash

# Wait for MariaDB to be ready
until mysqladmin ping -h mariadb --silent; do
	echo "Waiting for MariaDB..."
	sleep 1
done

cd /var/www/html

# Install WP-CLI if it is not already installed
if ! command -v wp &> /dev/null; then
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
fi

# Download WordPress if it is not already installed
if [ ! -f wp-config.php ]; then
	wp core download --allow-root
	wp config create \
		--dbname=$MYSQL_DATABASE \
		--dbuser=$MYSQL_USER \
		--dbpass=$MYSQL_PASSWORD \
		--dbhost=mariadb \
		--allow-root
	wp core install \
		--url=$DOMAIN_NAME \
		--title="Inception" \
		--admin_user=$WP_ADMIN_USER \
		--admin_password=$WP_ADMIN_PASSWORD \
		--admin_email=$WP_ADMIN_EMAIL \
		--allow-root
	wp user create \
		$WP_USER $WP_USER_EMAIL \
		--user_pass=$WP_USER_PASSWORD \
		--allow-root
fi

# Configure the Redis Object Cache plugin
if ! wp --path=/var/www/html plugin is-installed redis-cache --allow-root; then
	echo "Installing Redis Object Cache..."
	wp --path=/var/www/html plugin install redis-cache --activate --allow-root
elif ! wp --path=/var/www/html plugin is-active redis-cache --allow-root; then
	wp --path=/var/www/html plugin activate redis-cache --allow-root
fi

# Configure Redis as the object cache server
wp --path=/var/www/html config set WP_REDIS_HOST redis \
	--type=constant \
	--allow-root

wp --path=/var/www/html config set WP_REDIS_PORT 6379 \
	--type=constant \
	--raw \
	--allow-root

# Enable the Redis object cache drop-in
wp --path=/var/www/html redis enable --allow-root

# Start PHP-FPM in the foreground
exec php-fpm8.2 -F
