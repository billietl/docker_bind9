![Travis CI](https://travis-ci.org/billietl/docker_bind9.svg)

# louisbilliet/bind:latest
`Dockerfile` to create a [Docker](http://www.docker.com) container image for [BIND9](https://www.isc.org/downloads/bind/) DNS server.

## Contributing
Pull requests are welcome.
Make sure to bundle proper integration tests with your feature or I won't accept them.

# Getting started
## Installation
Automated build are soon to be published. Stay tuned.
Meanwhile, you can build this image on your own :
```bash
docker build -t bind9 .
```
## Quickstart
Start the container using :
```bash
docker run -d \
--name dns \
--publish 53/tcp \
--publish 53/udp \
bind9
```
You now have a running bind9 server listening on port 53.

You can define your own zone : bind will include `/data/zone.conf`.
All your have to do is to define your zone in a `zone.conf` file,
mount it's directory as a volume mapping `/data` and you're good to go.
