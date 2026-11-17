
FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y \
    php \
    php-mysql \
    wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html

RUN wget "http://www.adminer.org/latest.php" \
    -O /var/www/html/index.php

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]

