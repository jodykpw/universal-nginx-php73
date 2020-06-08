## Building from source
First clone the git repo:
```
git clone https://github.com/jodykpw/universal-nginx-php73.git
.git
```

To build with all available php modules run the following command:
```
docker build -t universal-nginx-php73:<tag> .
```

To build with selection of PHP extensions, you can modify the Dockerfile by remove unwanted extension @ # Persistent runtime dependencies, then run the following command:
```
docker build -t universal-nginx-php73:<tag>
```

### Available php modules
[PHP Modules](../docs/php-modules.md)