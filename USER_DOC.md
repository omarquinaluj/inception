# Inception - User Documentation

## Introduction

This document explains how to use the Inception infrastructure as an end user or administrator.

The project provides a WordPress website running through a Docker-based infrastructure composed of several independent services.

The mandatory WordPress infrastructure is accessed through NGINX using HTTPS on port `443`.

---

# Services

The infrastructure provides the following services:

| Service | Purpose | Access |
|---|---|---|
| NGINX | HTTPS reverse proxy and web entry point | `https://owmarqui.42.fr` |
| WordPress | Website and PHP application | `https://owmarqui.42.fr` |
| MariaDB | WordPress database | Internal |
| Redis | WordPress object cache | Internal |
| FTP | Access to WordPress files | Port `21` |
| Adminer | Database management interface | Port `8082` |
| Static Website | Additional static website | Port `8081` |

Additional ports used by the bonus services are:

- FTP control: `21`
- FTP passive mode: `21000-21010`
- Adminer: `8082`
- Static website: `8081`

MariaDB and PHP-FPM are not exposed directly to the host.

---

# Starting the Project

The recommended way to start the infrastructure is from the project root:

```bash
make
```

The Makefile builds the Docker images and starts the infrastructure in detached mode.

To verify that the services are running:

```bash
make ps
```

or:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml ps
```

All required containers should be in a running state.

The project requires a local `srcs/.env` file containing the configuration values used by MariaDB, WordPress and FTP.

---

# Stopping the Project

To stop the infrastructure:

```bash
make down
```

This stops and removes the containers while keeping the persistent Docker volumes.

The persistent data therefore remains available when the infrastructure is started again.

To remove the containers and persistent volumes, use the appropriate cleanup command from the Makefile only when the data is no longer required.

---

# Accessing WordPress

The main WordPress website is available at:

```text
https://owmarqui.42.fr
```

Because the project uses a self-signed certificate, the browser may display a certificate warning. This is expected in the development environment.

The WordPress administration interface is available at:

```text
https://owmarqui.42.fr/wp-admin
```

Use the administrator account configured during the installation.

The WordPress administrator username does not need to be the same as the Linux or GitHub username.

---

# Accessing Adminer

Adminer is available from the host at:

```text
http://localhost:8082
```

The Adminer container itself listens on port `8080`; Docker maps that container port to host port `8082`.

When connecting to the WordPress database, use:

```text
Server: mariadb
```

The database name, username and password are the values configured in the local `srcs/.env` file.

---

# Accessing the Bonus Website

The additional static website is available from the host at:

```text
http://localhost:8081
```

This website is independent from the WordPress installation and is served by its own NGINX container.

---

# FTP Access

The FTP service listens on:

```text
Port: 21
```

Passive FTP ports:

```text
21000-21010
```

The FTP username and password are stored in the local `srcs/.env` file.

The FTP service uses the same WordPress data volume as the WordPress container. Therefore, files uploaded or modified through FTP affect the files used by the WordPress website.

---

# Credentials

Sensitive credentials are stored locally in the `srcs/.env` configuration file.

The `.env` file contains values such as:

- MariaDB credentials;
- WordPress administrator credentials;
- WordPress user credentials;
- FTP credentials.

The `.env` file must **not be committed to Git** or shared publicly.

The repository does not contain the real `.env` file.

Before starting the project on a new installation, create the required file:

```text
srcs/.env
```

and configure the required environment variables according to the Docker Compose configuration.

To inspect the local configuration:

```bash
cat srcs/.env
```

Do not share or publish the contents of this file because it contains passwords.

---

# Checking the Infrastructure

To see the state of all services:

```bash
make ps
```

Alternatively:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml ps
```

To inspect the logs:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs
```

To inspect a specific service:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs nginx
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs wordpress
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs mariadb
```

To continuously follow the logs:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs -f
```

---

# Checking Persistent Data

The project uses Docker named volumes for persistent data.

List the project's Docker volumes:

```bash
docker volume ls
```

The project creates the following volumes:

```text
inception_mariadb_data
inception_wordpress_data
```

Inspect the MariaDB volume:

```bash
docker volume inspect inception_mariadb_data
```

Inspect the WordPress volume:

```bash
docker volume inspect inception_wordpress_data
```

The volumes use the local Docker driver with host directories under:

```text
/home/owmarqui/data
```

The actual persistent data directories are:

```text
/home/owmarqui/data/mariadb
/home/owmarqui/data/wordpress
```

The MariaDB directory contains the database data, while the WordPress directory contains the website files.

---

# Restarting the Infrastructure

If the containers stop unexpectedly, first check their state:

```bash
make ps
```

Then inspect the logs:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs
```

The containers are configured with Docker Compose restart policies so that they can automatically restart after a failure.

If necessary, the infrastructure can be restarted with:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml restart
```

---

# Troubleshooting

## WordPress is not accessible

Check the containers:

```bash
make ps
```

Then check NGINX and WordPress logs:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs nginx
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs wordpress
```

Check that the domain resolves correctly:

```bash
getent hosts owmarqui.42.fr
```

The domain should resolve to the IP address configured for the Inception virtual machine.

Also verify that NGINX is listening on port `443`.

---

## MariaDB is not working

Check the MariaDB container:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml ps mariadb
```

Then inspect its logs:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs mariadb
```

Do not remove the MariaDB volume unless you intentionally want to delete the persistent database.

---

## NGINX is not working

Check the NGINX logs:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs nginx
```

Verify that port `443` is available:

```bash
ss -lntp | grep ':443'
```

The NGINX configuration uses HTTPS with TLS 1.2 and TLS 1.3.

---

## Adminer is not accessible

Check the Adminer container:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml ps adminer
```

Then inspect its logs:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs adminer
```

Adminer should be accessible from the host at:

```text
http://localhost:8082
```

---

## FTP is not accessible

Check the FTP container:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml ps ftp
```

Then inspect its logs:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs ftp
```

Verify that the FTP control port and passive port range are available:

```text
21
21000-21010
```

---

# Checking Docker Resources

To see running containers:

```bash
docker ps
```

To see Docker images:

```bash
docker images
```

To see Docker volumes:

```bash
docker volume ls
```

To see Docker networks:

```bash
docker network ls
```

The project Docker network is:

```text
inception_inception
```

---

# Important Warning

Commands that remove Docker volumes can permanently delete persistent application data.

In particular, avoid using:

```bash
docker compose down -v
```

unless you intentionally want to remove the project's persistent volumes.

The Makefile also contains commands that can remove volumes and images. Use those commands carefully and only when you understand the consequences.

The WordPress and MariaDB data are stored persistently outside the containers, so removing a container does not by itself remove the persistent application data.