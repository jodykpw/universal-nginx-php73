## Using Composer

Composer comes pre-installed.

#### Run PHP composer inside a docker container
```
composer
```

#### Docker container exec

```
docker exec -it <container_id_or_name> /bin/bash -c composer
```

Example Via Laravel Installer

```
docker exec -it <container_id_or_name> /bin/sh -c 'cd /var/www && composer global require laravel/installer'
```

