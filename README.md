# keepalived
[![Downloads](https://img.shields.io/docker/pulls/angelnu/keepalived.svg)](https://hub.docker.com/r/angelnu/keepalived/)
[![Build Status](https://travis-ci.org/angelnu/docker-keepalived.svg?branch=master)](https://travis-ci.org/angelnu/docker-keepalived)

Keepalived as docker container for [mutiple archs](https://hub.docker.com/r/angelnu/keepalived/tags):
- arm
- arm64
- amd64

## How to run
### Docker
```
docker run -d -e KEEPALIVED_PRIORITY=$priority -e KEEPALIVED_VIRTUAL_IP=$VIP -e KEEPALIVED_PASSWORD=$password \
--net=host --privileged=true angelnu/keepalived
```
### Kubernetes
See [example](kubernetes.yaml)


## Travis
Note: if you clone this you need to set your travis env variables:

- `travis env set DOCKER_USER <your docker user>`
- `travis env set DOCKER_PASS <your docker password>`

