# Inception - Developer Documentation

## Introduction

This document explains how to set up, build, configure and maintain the Inception project.

The infrastructure is built with Docker Compose and consists of independent containers connected through a dedicated Docker network.

Each service has its own Dockerfile and is built from Debian Bookworm.

The project is designed to comply with the requirements of the 42 Inception subject.

---

# Prerequisites

The project requires:

- A Linux environment or virtual machine.
- Docker.
- Docker Compose.
- Make.
- Git.
- Internet access during image construction and application installation.

The project is designed to run inside a virtual machine as required by the 42 Inception subject.

---

# Project Structure

```text
Inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── sourcesRM/
│   ├── 3_counterns.png
│   ├── bonus_incepcion.png
│   └── Incepcion1.png
└── srcs/
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   └── conf/
        │       └── init.sh
        │
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── nginx.conf
        │
        ├── wordpress/
        │   ├── Dockerfile
        │   └── conf/
        │       └── wp_setup.sh
        │
        └── bonus/
            ├── redis/
            │   └── Dockerfile
            │
            ├── ftp/
            │   ├── Dockerfile
            │   ├── conf/
            │   │   └── vsftpd.conf
            │   └── tools/
            │       └── ftp_setup.sh
            │
            ├── adminer/
            │   └── Dockerfile
            │
            └── website/
                ├── Dockerfile
                ├── conf/
                │   └── nginx.conf
                └── site/
                    └── index.html
```

The local `.env` file is required for execution but is intentionally not included in the repository.

It must be created locally at:

```text
srcs/.env
```

---

# Configuration

## Environment Variables

The project uses a local `srcs/.env` file to configure the infrastructure.

The file contains configuration values for:

- Domain name.
- MariaDB database.
- MariaDB users and passwords.
- WordPress administrator.
- WordPress regular user.
- FTP credentials.

The expected structure is:

```env
DOMAIN_NAME=owmarqui.42.fr

MYSQL_DATABASE=...
MYSQL_USER=...
MYSQL_PASSWORD=...
MYSQL_ROOT_PASSWORD=...

WP_ADMIN_USER=...
WP_ADMIN_PASSWORD=...
WP_ADMIN_EMAIL=...

WP_USER=...
WP_USER_PASSWORD=...
WP_USER_EMAIL=...

FTP_USER=...
FTP_PASSWORD=...
```

The actual credentials must remain local.

The `.env` file must never be committed to Git.

The repository `.gitignore` excludes environment files and other sensitive configuration files.

---

# Domain Configuration

The WordPress domain is:

```text
owmarqui.42.fr
```

The domain must resolve to the IP address of the virtual machine.

For local development, the host system can resolve the domain through `/etc/hosts`.

Example:

```text
192.168.56.101    owmarqui.42.fr
```

The IP address must be replaced if the virtual machine uses a different address.

The project itself does not hard-code the VM host address in Docker Compose.

---

# Docker Compose

The main Compose file is located at:

```text
srcs/docker-compose.yml
```

It defines the complete infrastructure.

The mandatory services are:

- `nginx`
- `wordpress`
- `mariadb`

The bonus services are:

- `redis`
- `ftp`
- `adminer`
- `website`

All services are connected to the dedicated Docker network.

The services communicate using Docker service names instead of hard-coded container IP addresses.

For example, WordPress connects to MariaDB using:

```text
mariadb
```

NGINX connects to PHP-FPM using:

```text
wordpress:9000
```

WordPress connects to Redis using:

```text
redis:6379
```

The Compose configuration also defines persistent named volumes for MariaDB and WordPress.

---

# Building the Project

The recommended way to build and start the complete infrastructure is:

```bash
make
```

The equivalent Docker Compose command is:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml up --build -d
```

To build the images without starting the containers:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml build
```

To force a complete rebuild without using Docker's build cache:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml build --no-cache
```

---

# Starting and Stopping

Start the complete project:

```bash
make
```

Stop the containers:

```bash
make down
```

Start the project directly with Docker Compose:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml up -d
```

Stop the containers:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml down
```

---

# Makefile

The Makefile provides shortcuts for managing the infrastructure.

The main commands are:

```bash
make
```

Builds the images and starts the infrastructure.

```bash
make down
```

Stops and removes the containers while preserving persistent volumes.

```bash
make clean
```

Performs the cleanup operation defined by the project's Makefile.

```bash
make fclean
```

Performs the complete cleanup operation defined by the project's Makefile.

```bash
make re
```

Rebuilds the infrastructure using the Makefile workflow.

Before using destructive cleanup commands, inspect the Makefile and verify whether persistent data must be preserved.

---

# Container Management

List running containers:

```bash
docker ps
```

List all containers:

```bash
docker ps -a
```

Check the Compose services:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml ps
```

Inspect a container:

```bash
docker inspect <container>
```

Open a shell inside a running container when required for debugging:

```bash
docker exec -it <container> /bin/bash
```

For images where Bash is unavailable, use:

```bash
docker exec -it <container> /bin/sh
```

---

# Logs

Display all service logs:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs
```

Display logs for one service:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs nginx
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs wordpress
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs mariadb
```

Follow logs continuously:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs -f
```

Logs are particularly useful when debugging:

- NGINX configuration;
- PHP-FPM;
- WordPress initialization;
- MariaDB startup;
- Redis;
- FTP;
- Docker networking.

---

# Docker Images

List Docker images:

```bash
docker images
```

Inspect an image:

```bash
docker image inspect <image>
```

The project builds its own images from custom Dockerfiles rather than using pre-built application images.

The base image used by the services is Debian Bookworm.

The project uses explicit image tags such as:

```text
inception-nginx:1.0
inception-wordpress:1.0
inception-mariadb:1.0
```

This avoids relying on the `latest` tag.

---

# Docker Volumes

The project uses two persistent named volumes:

```text
inception_mariadb_data
inception_wordpress_data
```

List volumes:

```bash
docker volume ls
```

Inspect the MariaDB volume:

```bash
docker volume inspect inception_mariadb_data
```

Inspect the WordPress volume:

```bash
docker volume inspect inception_wordpress_data
```

The volumes use Docker's local driver with host directories under:

```text
/home/owmarqui/data
```

The actual persistent directories are:

```text
/home/owmarqui/data/mariadb
/home/owmarqui/data/wordpress
```

The MariaDB volume stores the database data.

The WordPress volume stores the WordPress installation and website files.

Because the data is stored outside the container lifecycle, recreating containers does not automatically remove the persistent data.

---

# Docker Network

The project uses a dedicated Docker bridge network.

The actual Docker network created by the Compose project is:

```text
inception_inception
```

List Docker networks:

```bash
docker network ls
```

Inspect the project network:

```bash
docker network inspect inception_inception
```

The network allows the containers to communicate internally.

For example:

```text
NGINX
  |
  +--> wordpress:9000
           |
           +--> mariadb:3306
           |
           +--> redis:6379
```

The project does not use host networking or Docker links.

---

# NGINX Development

The NGINX configuration is located at:

```text
srcs/requirements/nginx/conf/nginx.conf
```

The NGINX Dockerfile is:

```text
srcs/requirements/nginx/Dockerfile
```

The SSL certificate and private key are generated during the Docker image build.

They are not stored in the repository.

The NGINX container listens on:

```text
443
```

The configuration enables:

```text
TLS 1.2
TLS 1.3
```

The mandatory WordPress infrastructure is accessed through HTTPS.

NGINX forwards PHP requests to:

```text
wordpress:9000
```

---

# WordPress Development

The WordPress Dockerfile is located at:

```text
srcs/requirements/wordpress/Dockerfile
```

The WordPress configuration script is:

```text
srcs/requirements/wordpress/conf/wp_setup.sh
```

The script is responsible for:

1. Waiting for MariaDB to become available.
2. Installing WP-CLI if necessary.
3. Downloading WordPress.
4. Creating the WordPress configuration.
5. Installing WordPress.
6. Creating the regular WordPress user.
7. Installing and activating the Redis Object Cache plugin.
8. Configuring Redis.
9. Starting PHP-FPM in the foreground.

PHP-FPM listens internally on:

```text
9000
```

WordPress does not run NGINX inside its own container.

---

# MariaDB Development

The MariaDB Dockerfile is:

```text
srcs/requirements/mariadb/Dockerfile
```

The initialization script is:

```text
srcs/requirements/mariadb/conf/init.sh
```

The script:

1. Configures MariaDB to accept connections through the Docker network.
2. Initializes the database on the first run.
3. Creates the required database and user.
4. Configures the root password.
5. Starts MariaDB as the main container process.

MariaDB listens internally on:

```text
3306
```

Port `3306` is not published to the host.

Its persistent data is stored in the MariaDB named volume.

---

# Bonus Services

## Redis

Redis provides object caching for WordPress.

Its Dockerfile is:

```text
srcs/requirements/bonus/redis/Dockerfile
```

Redis listens internally on:

```text
6379
```

WordPress communicates with Redis using the Docker service name:

```text
redis
```

---

## FTP

The FTP Dockerfile is:

```text
srcs/requirements/bonus/ftp/Dockerfile
```

Its configuration is:

```text
srcs/requirements/bonus/ftp/conf/vsftpd.conf
```

The startup script is:

```text
srcs/requirements/bonus/ftp/tools/ftp_setup.sh
```

FTP uses the WordPress persistent volume so that transferred files are available to the WordPress installation.

The exposed ports are:

```text
21
21000-21010
```

---

## Adminer

Adminer provides a web interface for managing the MariaDB database.

Its Dockerfile is:

```text
srcs/requirements/bonus/adminer/Dockerfile
```

Adminer listens on port `8080` inside its container.

Docker publishes it on host port:

```text
8082
```

Therefore it is accessed from the host through:

```text
http://localhost:8082
```

---

## Static Website

The additional static website is located under:

```text
srcs/requirements/bonus/website/
```

Its Dockerfile is:

```text
srcs/requirements/bonus/website/Dockerfile
```

The NGINX configuration is:

```text
srcs/requirements/bonus/website/conf/nginx.conf
```

The website content is:

```text
srcs/requirements/bonus/website/site/index.html
```

The static website is published on host port:

```text
8081
```

It does not use PHP or WordPress.

---

# Data Persistence

The project separates application containers from persistent data.

The two main persistent volumes are:

```text
inception_mariadb_data
inception_wordpress_data
```

The corresponding host directories are:

```text
/home/owmarqui/data/mariadb
/home/owmarqui/data/wordpress
```

The important distinction is:

```text
Container lifecycle
        !=
Persistent data lifecycle
```

Removing or recreating a container does not automatically remove its named volumes.

However, commands that explicitly remove volumes can permanently delete persistent application data.

For example:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml down -v
```

should only be used when the persistent data is intentionally being removed.

---

# Troubleshooting

## Check the complete infrastructure

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml ps
```

## Check all logs

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs
```

## Check the Docker network

```bash
docker network inspect inception_inception
```

## Check persistent volumes

```bash
docker volume ls
```

## Rebuild one service

For example:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml build nginx
```

Then recreate it:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml up -d nginx
```

## Check container processes

```bash
docker top <container>
```

This can be useful to verify that the expected main process is running inside the container.

---

# Development Workflow

A typical development workflow is:

1. Modify the relevant Dockerfile, configuration or script.
2. Build the affected service.
3. Start or recreate the service.
4. Check its logs.
5. Test the service.
6. Verify that the other services still communicate correctly.

For example:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml build nginx
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml up -d nginx
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs nginx
```

Before committing changes:

```bash
git status
```

Review the modifications:

```bash
git diff
```

Verify that sensitive files such as `srcs/.env` are not included in the commit.

---

# Data Safety

Before using destructive Docker commands, verify whether persistent data must be preserved.

Commands involving:

```bash
docker compose down -v
docker volume rm
make clean
make fclean
make re
```

may remove persistent project data depending on the Makefile operation.

Always verify the current state of the containers and volumes before deleting them.

---

# Project Maintenance

When modifying the infrastructure, each service should remain responsible for a single main purpose.

Examples:

- NGINX handles HTTPS and forwards PHP requests.
- WordPress handles PHP and the WordPress application.
- MariaDB handles database storage.
- Redis handles WordPress object caching.
- FTP handles file transfer.
- Adminer handles database administration.
- The static website serves independent static content.

This separation keeps the infrastructure modular and makes individual services easier to debug and maintain.