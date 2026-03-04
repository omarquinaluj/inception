#!/bin/bash

# Esperar a que MariaDB esté lista
until mysqladmin ping -h mariadb --silent; do
    echo "Esperando a MariaDB..."
    sleep 1
done

cd /var/www/html

# Instalar WP-CLI si no existe
if ! command -v wp &> /dev/null; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# Descargar WordPress si no existe
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

# Ejecutar php-fpm
php-fpm7.4 -F