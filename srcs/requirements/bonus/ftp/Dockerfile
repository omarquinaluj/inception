FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y vsftpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/vsftpd/empty

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/ftp_setup.sh /ftp_setup.sh

RUN chmod +x /ftp_setup.sh

EXPOSE 21
EXPOSE 21000-21010

ENTRYPOINT ["/ftp_setup.sh"]
