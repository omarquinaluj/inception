*This project has been created as part of the 42 curriculum by owmarqui-.*

# Inception

## Description

**Inception** is a system administration and Docker project from the 42 curriculum. The goal is to build a small and functional infrastructure composed of several independent services, each running inside its own Docker container.

The infrastructure is built using **Docker Compose** and custom **Dockerfiles** based on Debian. The services communicate through a dedicated Docker network and persistent data is stored using Docker named volumes.

The mandatory infrastructure consists of:

- **NGINX**: the only public entry point of the infrastructure. It provides HTTPS using TLSv1.2/TLSv1.3.
- **WordPress + PHP-FPM**: provides the WordPress website and executes PHP scripts.
- **MariaDB**: provides the database used by WordPress.

The project also includes several bonus services:

- **Redis**: caching service for WordPress.
- **FTP**: provides access to the WordPress website files.
- **Adminer**: web interface for managing the MariaDB database.
- **Website**: an additional static website served by NGINX.

The complete infrastructure is isolated inside a Docker network, while WordPress files and the MariaDB database are stored in persistent named volumes.

### Architecture
![incepcion resume](sourcesRM\3_counterns.png)
![incepcion bonus](sourcesRM\bonus_incepcion.png)
![ Mixte bonus](sourcesRM\Incepcion1.png)

### Main Design Choices

Each service runs in its own container. This follows the principle that a container should have a focused responsibility instead of behaving like a virtual machine.

The images are built from Debian and the required software is installed directly inside our custom Dockerfiles. We do not rely on pre-built application images.

Docker Compose is responsible for creating and connecting the services, while the Makefile provides simple commands to build, start and stop the complete infrastructure.

Persistent WordPress files and MariaDB data are stored using Docker named volumes. This allows the containers to be recreated without losing the application data.

The services communicate through a dedicated Docker network instead of using the host network.

---

## Services

### NGINX

NGINX is the public entry point of the infrastructure.

It:

- listens on port `443`;
- uses HTTPS;
- supports TLSv1.2 and TLSv1.3;
- serves WordPress requests;
- forwards PHP requests to PHP-FPM;
- uses a self-signed SSL certificate for the project.

The public domain is:

```text
https://owmarqui.42.fr
```

### WordPress

The WordPress container contains:

- WordPress;
- PHP-FPM;
- MariaDB client utilities;
- WP-CLI.

PHP-FPM listens on port `9000` internally and communicates with NGINX through the Docker network.

WordPress is automatically configured using environment variables when the container starts.

### MariaDB

MariaDB provides the database used by WordPress.

Its database files are stored in a persistent Docker volume so that database data survives container recreation.

### Redis

Redis is used as a caching service for WordPress.

It is part of the bonus infrastructure and is intended to reduce repeated database operations by storing frequently accessed information in memory.

### FTP

The FTP service provides access to the WordPress website files.

It uses the same WordPress data volume, allowing files managed through FTP to be reflected in the WordPress installation.

### Adminer

Adminer provides a web interface for managing and inspecting the MariaDB database.

It is exposed through port `8080`.

### Static Website

The bonus website is a simple static website served by NGINX.

It does not use PHP and runs independently from the WordPress service.

It is exposed through port `8081`.

---

# Instructions

## Prerequisites

The project must be run inside a virtual machine with Docker and Docker Compose installed.

The following tools are required:

- Docker
- Docker Compose
- Make
- Git
- A Linux environment or virtual machine

The project uses a local domain:

```text
owmarqui.42.fr
```

This domain must resolve to the local IP address of the virtual machine.

For example, the `/etc/hosts` file can contain:

```text
127.0.0.1    owmarqui.42.fr
```

or the IP address assigned to the virtual machine:

```text
192.168.x.x    owmarqui.42.fr
```

depending on the network configuration.

## Environment Configuration

The project uses environment variables for configuration.

Create the required `.env` file with the database, WordPress and domain configuration.

The `.env` file must not be committed to the Git repository because it contains sensitive credentials.

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

The actual passwords must remain local and must never be stored directly inside Dockerfiles or publicly committed files.

## Build and Start

From the project root:

```bash
make
```

This builds the Docker images and starts the infrastructure in detached mode.

The equivalent Docker Compose command is:

```bash
docker compose up --build -d
```

## Stop the Infrastructure

To stop the containers:

```bash
make down
```

or:

```bash
docker compose down
```

This stops and removes the containers without removing persistent volumes.

## Check the Services

To see the current state of the containers:

```bash
docker compose ps
```

To inspect the logs:

```bash
docker compose logs
```

To inspect one service:

```bash
docker compose logs nginx
docker compose logs wordpress
docker compose logs mariadb
```

To follow the logs in real time:

```bash
docker compose logs -f
```

## Rebuild the Images

The images can be rebuilt with:

```bash
docker compose build --no-cache
```

and the infrastructure can then be started with:

```bash
docker compose up -d
```

> **Warning:** commands that remove volumes must be used carefully because the volumes contain persistent WordPress and MariaDB data.

---

# Access

## WordPress Website

The main website is available through:

```text
https://owmarqui.42.fr
```

Because the project uses a self-signed certificate, the browser may display a security warning. This is expected for the development environment.

## WordPress Administration

The WordPress administration panel is available at:

```text
https://owmarqui.42.fr/wp-admin
```

Use the administrator credentials defined in the local `.env` file.

## Adminer

Adminer is available at:

```text
http://localhost:8080
```

The database connection uses the MariaDB service name as the database host:

```text
mariadb
```

The remaining credentials are defined in the local `.env` file.

## Bonus Website

The static bonus website is available at:

```text
http://localhost:8081
```

## FTP

The FTP service is available through port:

```text
21
```

The passive data ports are:

```text
21000-21010
```

The FTP credentials are stored locally in the `.env` file.

---

# Persistent Data

The project uses two main Docker named volumes:

- `mariadb_data` — stores the MariaDB database.
- `wordpress_data` — stores the WordPress website files.

The volumes are persistent and are not removed when simply stopping the project.

They are configured to store their data under the required host directory:

```text
/home/owmarqui/data
```

This separation allows the containers themselves to be recreated without automatically losing the application data.

---

# Docker Concepts and Design Comparisons

## Virtual Machines vs Docker

A **virtual machine** emulates an entire computer system and normally contains its own operating system, kernel and system resources.

**Docker containers**, on the other hand, share the host kernel and isolate applications and their dependencies.

For this project, Docker is appropriate because each service can be isolated into a lightweight container while sharing the same host kernel.

| Virtual Machine | Docker |
|---|---|
| Includes a complete guest OS | Shares the host kernel |
| Higher resource usage | Lightweight |
| Usually slower to start | Fast startup |
| Strong system-level isolation | Application/service isolation |
| Each VM has its own OS | Containers share the host kernel |

The project itself is nevertheless required to run inside a **virtual machine**, while Docker is used inside that VM to provide the application infrastructure.

---

## Secrets vs Environment Variables

**Environment variables** are convenient for configuring containers and are useful for values such as:

- domain names;
- database names;
- usernames;
- configuration options.

However, environment variables are not an ideal mechanism for highly sensitive information because they can be exposed through container configuration or process environments.

**Docker secrets** provide a more appropriate mechanism for sensitive information such as passwords and credentials.

For this project, environment variables are mandatory and the `.env` file is used for configuration. Sensitive credentials must remain local and must not be committed to the repository.

---

## Docker Network vs Host Network

A **Docker network** provides isolated communication between containers.

Services can communicate using their Docker service names, for example:

```text
wordpress
mariadb
redis
```

This means WordPress can connect to MariaDB using:

```text
mariadb
```

without knowing the container's IP address.

Using:

```yaml
network_mode: host
```

would make containers use the host's network directly and would remove much of the network isolation provided by Docker.

For this project, a dedicated Docker network is therefore used.

---

## Docker Volumes vs Bind Mounts

A **bind mount** directly maps a host path into a container.

Example:

```text
./data:/var/lib/mysql
```

A **Docker named volume** is managed by Docker and provides persistent storage independently from the container lifecycle.

The Inception subject specifically requires Docker named volumes for:

- MariaDB data;
- WordPress website files.

The project therefore uses named volumes instead of bind mounts for these two persistent storage areas.

The volume data is stored under:

```text
/home/owmarqui/data
```

---

# Project Structure

The project follows a structure similar to:

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

Each service has its own Dockerfile and is built independently.

---

# Security

The project follows several security principles required by the subject:

- No passwords are hard-coded in Dockerfiles.
- Credentials are stored locally.
- The `.env` file is ignored by Git.
- NGINX is the only public entry point for the mandatory WordPress infrastructure.
- HTTPS is used through TLSv1.2/TLSv1.3.
- Services communicate through an isolated Docker network.
- Containers run independently rather than using host networking.
- Persistent data is separated from the container lifecycle.

---

# Bonus

The project implements the following bonus services:

### Redis

Provides caching for the WordPress installation.

### FTP

Provides file transfer access to the WordPress website volume.

### Static Website

Provides an additional static website served by NGINX without PHP.

### Adminer

Provides a graphical web interface for MariaDB administration.

The bonus services are implemented as independent Docker containers with their own Dockerfiles.

---

# Resources

The project was developed using the following types of resources:

- 42 Inception project subject.
- Docker documentation.
- Docker Compose documentation.
- Debian documentation.
- NGINX documentation.
- MariaDB documentation.
- WordPress documentation.
- PHP-FPM documentation.
- Redis documentation.
- vsftpd documentation.
- Adminer documentation.

### AI Usage

AI tools were used as a learning and development aid during the project.

They were used mainly for:

- understanding Docker and Docker Compose concepts;
- researching configuration options;
- debugging Docker build and networking problems;
- understanding NGINX, PHP-FPM and MariaDB configuration;
- reviewing shell scripts and Dockerfiles;
- explaining errors encountered during development;
- helping organize documentation;
- reviewing project requirements and identifying missing mandatory elements.

AI-generated suggestions were reviewed, tested and adapted to the project's actual implementation. The final configuration and code were validated by the project team.

# Authors
- **owmarqui-**

This project was developed as part of the **42 curriculum**.