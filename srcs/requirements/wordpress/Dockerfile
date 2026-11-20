FROM debian:bookworm

RUN apt-get update && \
	apt-get install -y \
	php-fpm \
	php-mysql \
	mariadb-client \
	curl \
	wget && \
	rm -rf /var/lib/apt/lists/*

# Configure PHP-FPM to listen on port 9000
RUN sed -i 's|listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

# Create the required PHP runtime directory
RUN mkdir -p /run/php

RUN mkdir -p /var/www/html

COPY conf/wp_setup.sh /wp_setup.sh
RUN chmod +x /wp_setup.sh

EXPOSE 9000

ENTRYPOINT ["/wp_setup.sh"]
