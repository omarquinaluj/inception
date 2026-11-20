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
## FTP

The project includes an FTP service using `vsftpd`.  
The FTP service shares the same `wordpress_data` volume as the WordPress and Nginx containers.

### FTP connection

The FTP server is available on:

```text
Host: owmarqui.42.fr
Port: 21
```

Passive FTP ports:

```text
21000-21010
```

The FTP username and password are the same credentials configured for the WordPress environment.

### Check that the FTP container is running
```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml ps ftp
```

The container should be shown as running.

You can also check the published ports:
```bash
docker port inception-ftp-1
```
Expected ports include:

21/tcp
21000-21010/tcp

Test FTP connection

Connect from the host:
```bash
ftp owmarqui.42.fr
```
Enter the FTP credentials configured in srcs/.env.

After a successful login:

ftp> pwd
ftp> ls

The WordPress files should be accessible.

To leave the FTP session:

ftp> bye

### Test FTP from the terminal

Install the FTP client if necessary:

```bash
sudo apt-get install ftp
```

Connect to the FTP server:

```bash
ftp owmarqui.42.fr
```

Then enter the FTP credentials configured in `srcs/.env`.

Once connected, test:

```text
pwd
ls
```

You should see the WordPress files, because FTP uses the same `/var/www/html` directory as the WordPress installation.

To leave the FTP session:

```text
bye
```

### Test FTP with a file

You can also verify that FTP can access the WordPress files:

```bash
ftp owmarqui.42.fr
```

Inside the FTP session:

```text
ls
get index.php
bye
```

The `get` command downloads a file from the FTP server to the current directory.

### Verify that FTP shares the WordPress volume

Check the mounts of the FTP container:

```bash
docker inspect inception-ftp-1 --format '{{json .Mounts}}'
```

The output should show the `wordpress_data` volume mounted at:

```text
/var/www/html
```

You can compare it with the WordPress container:

```bash
docker inspect inception-wordpress-1 --format '{{json .Mounts}}'
```

Both containers should use the same `wordpress_data` volume.

### What this demonstrates

The FTP service allows access to the WordPress files through FTP.

The important point is that FTP, WordPress and Nginx share the same persistent WordPress volume:

```text
                    wordpress_data
                         │
              ┌──────────┼──────────┐
              │          │          │
          WordPress     Nginx       FTP
          /var/www/html /var/www/html /var/www/html
```

Therefore, files uploaded or modified through FTP are available to the other services using the same volume.

### Troubleshooting

If FTP does not connect, check:

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml logs ftp
```

Check that port 21 is listening:

```bash
sudo ss -lntp | grep ':21'
```

Check the FTP container:

```bash
docker ps --filter name=inception-ftp
```

Check the passive ports:

```bash
docker port inception-ftp-1
```

If the FTP container is running but authentication fails, verify the FTP credentials in:

```bash
grep '^FTP_' srcs/.env
```

Do not display or share the password during the defense.

---

### Redi test

```bash
docker compose -p inception --env-file srcs/.env -f srcs/docker-compose.yml ps redis
```

```bash
docker ps --filter name=inception-redis
```

* In redi
```bash
docker exec -it inception-redis-1 bash
```

```bash
redis-cli ping
```
You must respond
```test
PONG
```
if finish it
```bash
exit
```

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

## Persistent Data

The project uses Docker named volumes to keep important application data outside the containers.

This means that removing and recreating a container does not remove the WordPress website or the MariaDB database, as long as the persistent volumes are kept.

### Persistent Volumes

The project uses two named Docker volumes:

```bash
inception_mariadb_data
inception_wordpress_data
```

The volumes are backed by directories on the host:

```text
/home/owmarqui/data/mariadb
/home/owmarqui/data/wordpress
```

The MariaDB volume contains the database files.

The WordPress volume contains the WordPress installation, plugins, themes, uploads and other website files.

### Check the Volumes

List the project's Docker volumes:

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

The `Mountpoint` shown by Docker refers to the Docker volume. In this project, the volume uses a bind mount to the host directories under:

```text
/home/owmarqui/data
```

The actual persistent directories can also be inspected directly:

```bash
ls -lah /home/owmarqui/data/mariadb
ls -lah /home/owmarqui/data/wordpress
```

### Persistence After Stopping the Project

The normal command to stop the infrastructure is:

```bash
make down
```

This removes the containers but **keeps the persistent volumes**.

The data therefore remains available.

Start the infrastructure again with:

```bash
make
```

The same WordPress installation and MariaDB database should be available again.

### Persistence Demonstration

A simple way to demonstrate persistence is:

1. Start the project:

```bash
make
```

2. Check that all services are running:

```bash
make ps
```

3. Open WordPress:

```text
https://owmarqui.42.fr
```

4. Create or modify some persistent WordPress data, such as a post or another website setting.

5. Stop the infrastructure:

```bash
make down
```

6. Confirm that the containers have been removed:

```bash
docker ps
```

7. Start the infrastructure again:

```bash
make
```

8. Check the services:

```bash
make ps
```

9. Open WordPress again:

```text
https://owmarqui.42.fr
```

The previously created data should still be present.

This demonstrates that the application data is stored in persistent volumes rather than inside the containers themselves.

### Container vs Persistent Data

Containers are replaceable application environments.

The persistent data is stored separately:

```text
MariaDB container
       |
       v
inception_mariadb_data
       |
       v
/home/owmarqui/data/mariadb
```

and:

```text
WordPress container
       |
       v
inception_wordpress_data
       |
       v
/home/owmarqui/data/wordpress
```

Therefore:

```text
Container removed     -> data remains
Container recreated   -> data remains
make down             -> data remains
make down -v          -> data is removed
```

### Commands That Preserve Data

The following command removes the containers but keeps the persistent volumes:

```bash
make down
```

Starting the project again:

```bash
make
```

The WordPress files and MariaDB database should still be available.

### Commands That Remove Persistent Data

Be careful with commands that use `-v`.

For example:

```bash
make clean
```

uses:

```bash
docker compose down -v
```

and therefore removes the project's Docker volumes.

The `fclean` target also removes the volumes and Docker images:

```bash
make fclean
```

Therefore, these commands should only be used when the persistent application data is no longer required.

### Important Persistence Warning

Do not use:

```bash
docker compose down -v
```

or:

```bash
make clean
```

or:

```bash
make fclean
```

if you want to preserve the current WordPress and MariaDB data.

Removing the volumes can permanently delete the persistent application data.

The persistent data should be backed up before intentionally removing the volumes.
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