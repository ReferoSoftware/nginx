#! /bin/sh

_APP_ROOT=${APP_ROOT:-/opt/app-root/public}
_LISTEN_PORT=${LISTEN_PORT:-8080}
_PHP_FPM_HOST=${PHP_FPM_HOST:-phpfpm}
_PHP_FPM_PORT=${PHP_FPM_PORT:-9000}

# Replace the comnfigurable host and port by replacing the 
sed -e "s/__LISTEN_PORT__/$_LISTEN_PORT/g" /etc/nginx/conf.d/default.conf.template |\
	sed -e "s/__PHP_FPM_HOST__/$_PHP_FPM_HOST/g" \
	sed -e "s/__PHP_FPM_PORT__/$_PHP_FPM_PORT/g" \
	sed -e "s/__APP_ROOT__/$_APP_ROOT/g" \
	> /etc/nginx/conf.d/default.conf

cp /docker-entrypoint-extras.d/*.conf /etc/nginx/conf.d/extras

chown -R 1001:1001 /etc/nginx/conf.d/extras

# This will run a check, which should be designed to wait until the app dependencies are available
# i.e. `while ! mysqladmin ping -h"$DB_HOST" --silent; do; sleep 1; done`
# The actual script should ideally use your application code to connect to the dependent service in the usual manner
# This helps make the applications more resilient by avoiding race conditions
# If the file doesn't exist, this will do nothing...
if [ -f $_APP_DIR/readiness-probe ]; then
	chmod +x $_APP_DIR/readiness-probe

	$_APP_DIR/readiness-probe

	if [ $? -ne 0 ]; then
		echo 'The application is not ready, and could not be started';
		exit 1;
	fi
fi

# This is required so we can change the command run upon starting up
if [ "$#" -gt "0" ]; then
	$@
	exit "$?"
fi

nginx