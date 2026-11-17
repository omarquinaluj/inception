# Inception - User Documentation

## Introduction

This document explains how to use the Inception infrastructure as an end user or administrator.

The project provides a WordPress website running through a Docker-based infrastructure composed of several independent services.

---

# Services

The infrastructure provides the following services:

| Service | Purpose | Access |
|---|---|---|
| NGINX | HTTPS reverse proxy and web entry point | `https://owmarqui.42.fr` |
| WordPress | Website and PHP application | `https://owmarqui.42.fr` |
| MariaDB | WordPress database | Internal |
| Redis | WordPress cache | Internal |
| FTP | Access to WordPress files | Port `21` |
| Adminer | Database management interface | Port `8080` |
| Static Website | Additional static website | Port `8081` |

The mandatory WordPress infrastructure is accessed through NGINX on port `443`.

---

# Starting the Project

From the project root, run:

```bash
make
```

This builds the Docker images and starts the infrastructure in detached mode.

To verify that the services are running:

```bash
docker compose ps
```

All required containers should be in a running state.

---

# Stopping the Project

To stop the infrastructure:

```bash
make down
```

This stops and removes the containers while keeping the persistent Docker volumes.

The persistent data should therefore remain available when the infrastructure is started again.

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

---

# Accessing Adminer

Adminer is available at:

```text
http://localhost:8080
```

The database server should be specified as:

```text
mariadb
```

The database name, username and password are the values configured in the local `.env` file.

---

# Accessing the Bonus Website

The additional static website is available at:

```text
http://localhost:8081
```

This website is independent from the WordPress installation.

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

The FTP username and password are stored in the local `.env` file.

The FTP service points to the WordPress website files, so files uploaded or modified through FTP affect the WordPress website volume.

---

# Credentials

Sensitive credentials are stored locally in the `.env` configuration file.

The `.env` file contains values such as:

- MariaDB credentials;
- WordPress administrator credentials;
- WordPress user credentials;
- FTP credentials.

The `.env` file must **not be committed to Git**.

To inspect the local configuration:

```bash
cat .env
```

Do not share or publish the contents of this file because it contains passwords.

---

# Checking the Infrastructure

To see the state of all services:

```bash
docker compose ps
```

To inspect the logs:

```bash
docker compose logs
```

To inspect a specific service:

```bash
docker compose logs nginx
docker compose logs wordpress
docker compose logs mariadb
```

To continuously follow the logs:

```bash
docker compose logs -f
```

---

# Checking Persistent Data

The project uses Docker named volumes for persistent data.

List the project's volumes:

```bash
docker volume ls
```

Inspect a volume:

```bash
docker volume inspect mariadb_data
```

or:

```bash
docker volume inspect wordpress_data
```

The persistent data is stored under the required host directory:

```text
/home/owmarqui/data
```

The MariaDB volume contains the database data, while the WordPress volume contains the website files.

---

# Restarting the Infrastructure

If the containers stop unexpectedly, check their state:

```bash
docker compose ps
```

Then inspect the logs:

```bash
docker compose logs
```

The containers are configured to restart after a crash according to the Docker Compose configuration.

If necessary, the infrastructure can be restarted with:

```bash
docker compose restart
```

---

# Troubleshooting

## WordPress is not accessible

Check the containers:

```bash
docker compose ps
```

Then check NGINX and WordPress logs:

```bash
docker compose logs nginx
docker compose logs wordpress
```

Check that the domain resolves correctly:

```bash
getent hosts owmarqui.42.fr
```

---

## MariaDB is not working

Check the MariaDB container:

```bash
docker compose ps mariadb
```

Then inspect its logs:

```bash
docker compose logs mariadb
```

Do not remove the MariaDB volume unless you intentionally want to delete the persistent database.

---

## NGINX is not working

Check:

```bash
docker compose logs nginx
```

Verify that port `443` is available and that the SSL configuration is correct.

---

## Checking Docker Resources

To see running containers:

```bash
docker ps
```

To see images:

```bash
docker images
```

To see volumes:

```bash
docker volume ls
```

To see networks:

```bash
docker network ls
```

---

# Important Warning

Commands that remove Docker volumes can permanently delete persistent application data.

In particular, avoid using commands such as:

```bash
docker compose down -v
```

unless you intentionally want to remove the project's persistent volumes.

The Makefile also contains commands that can remove volumes and images. Use them carefully.