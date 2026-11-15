FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY site /var/www/html

EXPOSE 8081

CMD ["nginx", "-g", "daemon off;"]
