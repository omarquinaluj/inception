FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    php-fpm \
    php-mysql \
    mariadb-client \
    curl \
    wget && \
    rm -rf /var/lib/apt/lists/*

# Hacer que escuche por puerto 9000
RUN sed -i 's|listen = .*|listen = 9000|' /etc/php/7.4/fpm/pool.d/www.conf

# Crear carpeta runtime necesaria
RUN mkdir -p /run/php

RUN mkdir -p /var/www/html

COPY conf/wp_setup.sh /wp_setup.sh
RUN chmod +x /wp_setup.sh

# Copiar y ejecutar script FTP/SFTP
COPY ../ftp/setup_ssh.sh /setup_ssh.sh
RUN chmod +x /setup_ssh.sh && /setup_ssh.sh

EXPOSE 9000

ENTRYPOINT ["/wp_setup.sh"]