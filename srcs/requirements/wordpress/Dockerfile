FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    php-fpm \
    php-mysql \
    mariadb-client \
    curl \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Instalar WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Crear directorio de WordPress
RUN mkdir -p /var/www/html

COPY conf/wp_setup.sh /wp_setup.sh
RUN chmod +x /wp_setup.sh

EXPOSE 9000

ENTRYPOINT ["/wp_setup.sh"]