## Introduction
This is a Dockerfile to build a container image for nginx and php-fpm to support my old but still in production fexCore framework.
### Git repository
The source files for this project can be found here: [https://github.com/olivernadj/nginx-php-fpm-for-fexcore-legacy](https://github.com/olivernadj/nginx-php-fpm-for-fexcore-legacy)

If you have any improvements please submit a pull request.
### Docker hub repository
The Docker hub build can be found here: [https://registry.hub.docker.com/u/olivernadj/nginx-php-fpm-for-fexcore-legacy/](https://registry.hub.docker.com/u/olivernadj/nginx-php-fpm-for-fexcore-legacy/)
## Versions

| Tag    | nginx  | PHP               | Ubuntu  |
|--------|--------|-------------------|---------|
| latest | 1.9.12 | 5.5.9-1ubuntu4.14 | 14.04.4 |

## Building from source
To build from source you need to clone the git repo and run docker build:
```
git clone https://github.com/olivernadj/nginx-php-fpm-for-fexcore-legacy.git
docker build -t olivernadj/nginx-php-fpm-for-fexcore-legacy:latest .
```
## Pulling from Docker Hub
Pull the image from docker hub rather than downloading the git repo. This prevents you having to build the image on every docker host:
```
docker pull olivernadj/nginx-php-fpm-for-fexcore-legacy:latest
```
## Running
To simply run the container:
```
sudo docker run --name nginx -p 8080:80 -d olivernadj/nginx-php-fpm-for-fexcore-legacy
```
You can then browse to ```http://<DOCKER_HOST>:8080``` to view the default install files.
### Volumes
If you want to link to your web site directory on the docker host to the container run:
```
sudo docker run --name nginx -p 8080:80 -v /your_code_directory:/usr/share/nginx/html -d olivernadj/nginx-php-fpm-for-fexcore-legacy
```
### Linking
Linking to containers also exposes the linked container environment variables which is useful for templating and configuring web apps.

Run MySQL container with some extra details:
```
sudo docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=yayMySQL -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wordpress_user -e MYSQL_PASSWORD=wordpress_password -d mysql
```
This exposes the following environment variables to the container when linked:
```
MYSQL_ENV_MYSQL_DATABASE=wordpress
MYSQL_ENV_MYSQL_ROOT_PASSWORD=yayMySQL
MYSQL_PORT_3306_TCP_PORT=3306
MYSQL_PORT_3306_TCP=tcp://172.17.0.236:3306
MYSQL_ENV_MYSQL_USER=wordpress_user
MYSQL_ENV_MYSQL_PASSWORD=wordpress_password
MYSQL_ENV_MYSQL_VERSION=5.6.22
MYSQL_NAME=/sick_mccarthy/mysql
MYSQL_PORT_3306_TCP_PROTO=tcp
MYSQL_PORT_3306_TCP_ADDR=172.17.0.236
MYSQL_ENV_MYSQL_MAJOR=5.6
MYSQL_PORT=tcp://172.17.0.236:3306
```
To link the container launch like this:
```
sudo docker run -v /opt/ngddeploy/:/root/.ssh -p 8080:80 --link some-mysql:mysql -d olivernadj/nginx-php-fpm-for-fexcore-legacy
```
### Enabling SSL or Special Nginx Configs
As with all docker containers its possible to link resources from the host OS to the guest. This makes it really easy to link in custom nginx default config files or extra virtual hosts and SSL enabled sites. For SSL sites first create a directory somewhere such as */opt/deployname/ssl/*. In this directory drop you SSL cert and Key in. Next create a directory for your custom hosts such as  */opt/deployname/sites-enabled*. In here load your custom default.conf file which references your SSL cert and keys at the location, for example:  */etc/nginx/ssl/xxxx.key*

Then start your container and connect these volumes like so:
```
sudo docker run -v /opt/ngddeploy/:/root/.ssh -v /opt/deployname/ssl:/etc/nginx/ssl -v /opt/deployname/sites-enabled:/etc/nginx/sites-enabled -p 8080:80 --link some-mysql:mysql -d olivernadj/nginx-php-fpm-for-fexcore-legacy
```

### Install Extra Modules
If you wish to install extras at boot time, such as extra php modules you can specify this by adding the DEBS flag, to add multiple packages you need to space separate the values:
```
sudo docker run --name nginx -e 'DEBS=php5-mongo php-json" -p 8080:80 -d olivernadj/nginx-php-fpm-for-fexcore-legacy
```
### Using environment variables
If you want to link to an external MySQL DB and not using linking you can pass variables directly to the container that will be automatically configured by the container.

Example:
```
sudo docker run -e 'MYSQL_HOST=host.x.y.z' -e 'MYSQL_USER=username' -e 'MYSQL_PASS=password' -v /opt/ngddeploy/:/root/.ssh -p 8080:80 -d olivernadj/nginx-php-fpm-for-fexcore-legacy
```

### Register PHP $_ENV and populate with OS env variables
$_ENV is only populated if php.ini allows it, which it doesn't seem to do by default, at least not in the default WAMP server installation.
```
-e REGISTER_ENV=1
```
Example:
```
sudo docker run -e 'APP_ENV=dev' -e 'VENTURE_ID=MY' -p 8080:80 -d olivernadj/nginx-php-fpm-for-fexcore-legacy
```

```
<?php 
echo $_ENV["APP_ENV"];
\\ prints dev
```
## Logging and Errors

### Logging
All logs should now print out in stdout/stderr and are available via the docker logs command:
```
docker logs <CONTAINER_NAME>
```
### Displaying Errors
If you want to display PHP errors on screen (in the browser) for debugging purposes use this feature:
```
-e ERRORS=1
```
