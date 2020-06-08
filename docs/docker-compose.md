## Using Docker Compose

Clone this repository on your Docker host:

```
git clone https://github.com/jodykpw/universal-nginx-php73.git
.git

cd universal-nginx-php73
```

For Docker environment variable please refer to [Environment Variables](../docs/env-variables.md) documentation.

#### Local Development (Vagrant + Traefik + Docker)

**Tutorial**: [Cloud Native DevOps 03B: Consistent Cross-Platform Docker Development Environment with Vagrant](https://medium.com/@jodywan/cloud-native-devops-03b-consistent-cross-platform-docker-development-environment-with-vagrant-2385211d4f8f)

Copy corresponding docker-compose file and modify.
docker-compose-default.yml
docker-compose-traefik.yml
docker-compose-vagrant.yml

Run compose up:

[docker-compose up](https://docs.docker.com/compose/reference/up/)

```
HOST=php.docker.local docker-compose up -d
```

