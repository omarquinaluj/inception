FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx

COPY site /var/www/html

EXPOSE 8081

CMD ["nginx", "-g", "daemon off;"]