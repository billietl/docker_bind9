FROM debian:jessie
MAINTAINER Louis Billiet <louis.billiet59@gmail.com>

RUN apt-get update && \
    apt-get install -y bind9 && \
    rm -rf /var/lib/apt/lists/*

COPY files/named.conf* /etc/bind/
COPY files/zone.conf /data/zone.conf

EXPOSE 53/tcp 53/udp
VOLUME ['/var/cache/bind']

CMD ["/usr/sbin/named", "-f"]
