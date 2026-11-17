# Inception - Developer Documentation

## Introduction

This document explains how to set up, build, configure and maintain the Inception project.

The infrastructure is built with Docker Compose and consists of independent containers connected through a dedicated Docker network.

Each service has its own Dockerfile and is built from Debian.

---

# Prerequisites

The project requires:

- A Linux environment or virtual machine.
- Docker.
- Docker Compose.
- Make.
- Git.
- Internet access during image construction.

The project is designed to run inside a virtual machine as required by the 42 Inception subject.

---

# Project Structure

```text
Inception/
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── docker-compose.yml
├── .env
└── srcs/
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

---

# Configuration

## Environment Variables

The project uses a `.env` file to configure the infrastructure.

The file contains configuration values for:

- Domain name.
- MariaDB database.
- MariaDB users.
- MariaDB passwords.
- WordPress administrator.
- WordPress regular user.
- FTP credentials.

Example structure:

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

The `.env` file must be ignored by Git:

```gitignore
.env
```

---

# Domain Configuration

The WordPress domain is:

```text
owmarqui.42.fr
```

The domain must resolve to the IP address of the local virtual machine.

For local development, the host resolution can be configured through `/etc/hosts`.

Example:

```text
192.168.x.x    owmarqui.42.fr
```

The IP address must be replaced with the actual IP address used by the virtual machine.

---

# Docker Compose

The `docker-compose.yml` file defines the complete infrastructure.

The mandatory services are:

- `nginx`
- `wordpress`
- `mariadb`

The bonus services are:

- `redis`
- `ftp`
- `adminer`
- `website`

All services are connected to the `inception` Docker network.

The services communicate using Docker service names instead of hard-coded container IP addresses.

For example, WordPress connects to MariaDB using:

```text
mariadb
```

and NGINX connects to PHP-FPM using:

```text
wordpress:9000
```

---

# Building the Project

The complete infrastructure can be built with:

```bash
make
```

The underlying Docker Compose command is:

```bash
docker compose up --build -d
```

To build without starting the containers:

```bash
docker compose build
```

To force a complete rebuild without using Docker's build cache:

```bash
docker compose build --no-cache
```

---

# Starting and Stopping

Start the project:

```bash
make
```

Stop the containers:

```bash
make down
```

Start the project directly with Docker Compose:

```bash
docker compose up -d
```

Stop the containers:

```bash
docker compose down
```

---

# Makefile

The Makefile provides shortcuts for managing the infrastructure.

Typical commands are:

```bash
make
```

Build and start the project.

```bash
make down
```

Stop and remove the containers.

```bash
make clean
```

Stop the infrastructure and remove the project's volumes.

```bash
make fclean
```

Stop the infrastructure, remove volumes and remove the project's images.

```bash
make re
```

Recreate the infrastructure from scratch.

> `make clean`, `make fclean` and `make re` can remove persistent data. They should therefore not be used casually on an installation containing data that must be preserved.

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
docker compose ps
```

Inspect a container:

```bash
docker inspect <container>
```

Open a shell inside a running container when required for debugging:

```bash
docker exec -it <container> /bin/bash
```

For minimal images where Bash is unavailable, use:

```bash
docker exec -it <container> /bin/sh
```

---

# Logs

Display all service logs:

```bash
docker compose logs
```

Display logs for one service:

```bash
docker compose logs nginx
docker compose logs wordpress
docker compose logs mariadb
```

Follow logs continuously:

```bash
docker compose logs -f
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

List project images:

```bash
docker images
```

Inspect an image:

```bash
docker image inspect <image>
```

The project builds its own images from custom Dockerfiles rather than using pre-built application images.

The base images are Debian images, with the required software installed during the Docker build.

---

# Docker Volumes

The project uses two main persistent named volumes:

```text
mariadb_data
wordpress_data
```

List volumes:

```bash
docker volume ls
```

Inspect a volume:

```bash
docker volume inspect mariadb_data
```

```bash
docker volume inspect wordpress_data
```

The persistent data must be stored under:

```text
/home/owmarqui/data
```

The MariaDB volume stores the database.

The WordPress volume stores the WordPress installation and website files.

Because these are persistent volumes, recreating containers does not automatically remove their data.

---

# Docker Network

The project uses a dedicated Docker network:

```text
inception
```

List Docker networks:

```bash
docker network ls
```

Inspect the network:

```bash
docker network inspect inception
```

The network allows the containers to communicate internally.

For example:

```text
NGINX
  |
  +--> wordpress:9000
           |
           +--> mariadb
           |
           +--> redis
```

The project does not use host networking.

---

# NGINX Development

The NGINX configuration is located at:

```text
srcs/requirements/nginx/conf/nginx.conf
```

The SSL certificate is generated during the image build.

The NGINX container exposes:

```text
443
```

The mandatory WordPress infrastructure is accessed through HTTPS.

---

# WordPress Development

The WordPress configuration script is located at:

```text
srcs/requirements/wordpress/conf/wp_setup.sh
```

The script is responsible for:

1. Waiting for MariaDB to become available.
2. Downloading WP-CLI if necessary.
3. Downloading WordPress.
4. Creating the WordPress configuration.
5. Installing WordPress.
6. Creating the regular WordPress user.
7. Starting PHP-FPM in the foreground.

PHP-FPM listens internally on:

```text
9000
```

---

# MariaDB Development

The MariaDB initialization script is located at:

```text
srcs/requirements/mariadb/conf/init.sh
```

It initializes the database and configures the required database users.

MariaDB is only accessible internally through the Docker network.

Its persistent data is stored in the MariaDB named volume.

---

# Bonus Services

## Redis

Redis provides caching functionality for the WordPress installation.

Its Dockerfile is located at:

```text
srcs/requirements/bonus/redis/Dockerfile
```

## FTP

The FTP server uses:

```text
srcs/requirements/bonus/ftp/Dockerfile
```

Its configuration is located at:

```text
srcs/requirements/bonus/ftp/conf/vsftpd.conf
```

The startup script is:

```text
srcs/requirements/bonus/ftp/tools/ftp_setup.sh
```

The FTP service shares the WordPress website volume.

## Adminer

Adminer provides a web interface for managing the MariaDB database.

Its Dockerfile is located at:

```text
srcs/requirements/bonus/adminer/Dockerfile
```

## Static Website

The additional static website is located under:

```text
srcs/requirements/bonus/website/
```

It is served by its own NGINX container.

---

# Data Persistence

The project separates application containers from persistent data.

Containers can be stopped or recreated without intentionally deleting the WordPress files or MariaDB database.

The important distinction is:

```text
Container lifecycle
        !=
Persistent data lifecycle
```

Removing a container does not necessarily remove its named volumes.

However, commands such as:

```bash
docker compose down -v
```

explicitly remove the project's volumes and can result in permanent data loss.

---

# Troubleshooting

## Check the complete infrastructure

```bash
docker compose ps
```

## Check all logs

```bash
docker compose logs
```

## Check the Docker network

```bash
docker network inspect inception
```

## Check persistent volumes

```bash
docker volume ls
```

## Rebuild one service

For example:

```bash
docker compose build nginx
```

Then recreate it:

```bash
docker compose up -d nginx
```

## Check container processes

```bash
docker top <container>
```

This can be useful to verify that the expected main process is running as PID 1 inside the container.

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
docker compose build nginx
docker compose up -d nginx
docker compose logs nginx
```

Before committing changes:

```bash
git status
```

Check that sensitive files such as `.env` are not included in the commit.

Then review the changes:

```bash
git diff
```

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

may remove persistent project data.

Always verify the current state of the volumes before deleting them.

---

# Project Maintenance

When modifying the infrastructure, each service should remain responsible for a single main purpose.

Examples:

- NGINX handles HTTPS and HTTP requests.
- WordPress handles PHP and the WordPress application.
- MariaDB handles database storage.
- Redis handles caching.
- FTP handles file transfer.
- Adminer handles database administration.
- The static website serves independent static content.

This separation keeps the infrastructure modular and makes individual services easier to debug and maintain.