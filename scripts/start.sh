#!/usr/bin/env bash

# Disable Strict Host checking for non interactive git clones

mkdir -p -m 0700 /root/.ssh
echo -e "Host *\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

# Setup git variables
if [ ! -z "$GIT_EMAIL" ]; then
 git config --global user.email "$GIT_EMAIL"
fi
if [ ! -z "$GIT_NAME" ]; then
 git config --global user.name "$GIT_NAME"
 git config --global push.default simple
fi

# Install Extras
if [ ! -z "$DEBS" ]; then
 apt-get update
 apt-get install -y $DEBS
fi

# Display PHP error's or not
if [[ "$ERRORS" != "1" ]] ; then
  sed -i -e "s/error_reporting =.*=/error_reporting = E_ALL/g" /etc/php5/fpm/php.ini
  sed -i -e "s/display_errors =.*/display_errors = On/g" /etc/php5/fpm/php.ini
fi

# Tweak nginx to match the workers to cpu's

procs=$(cat /proc/cpuinfo |grep processor | wc -l)
sed -i -e "s/worker_processes 5/worker_processes $procs/" /etc/nginx/nginx.conf

# Let's register $_ENV when PHP starts up
echo '' > /etc/nginx/env_params
if [[ "$REGISTER_ENV" == "1" ]]; then
  for i in $(env | grep _)
  do
    if [[ "$variable" != '%s' ]] ; then
      variable=$(echo "$i" | cut -d'=' -f1)
      value=$(echo "$i" | cut -d'=' -f2)
      echo -e "fastcgi_param\t$variable\t'$value';" >> /etc/nginx/env_params
    fi
  done
  sed -i -e "s/variables_order =.*/variables_order = \"EGPCS\"/g" /etc/php5/fpm/php.ini
fi

# Again set the right permissions (needed when mounting from a volume)
chown -Rf www-data.www-data /usr/share/nginx/html/

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisord.conf
