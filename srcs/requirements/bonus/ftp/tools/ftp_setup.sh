#!/bin/bash

if ! id "$FTP_USER" >/dev/null 2>&1; then
    useradd -d /var/www/html -s /usr/sbin/nologin "$FTP_USER"
fi

echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

chown -R "$FTP_USER:$FTP_USER" /var/www/html

exec /usr/sbin/vsftpd /etc/vsftpd.conf
