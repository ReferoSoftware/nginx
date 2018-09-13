#! /bin/sh

_APP_ROOT=${APP_ROOT:-/opt/app-root/public}
_LISTEN_PORT=${LISTEN_PORT:-8080}
_PHP_FPM_HOST=${PHP_FPM_HOST:-phpfpm}
_PHP_FPM_PORT=${PHP_FPM_PORT:-9000}
_EXTRAS_COUNT=$(find /docker-entrypoint-extras.d -type f -name *.conf | wc -l | tr -d ' ')

# Replace the configurable variables
sed -e "s/__LISTEN_PORT__/$_LISTEN_PORT/g" /etc/nginx/conf.d/default.conf.template |\
	sed -e "s/__PHP_FPM_HOST__/$_PHP_FPM_HOST/g" |\
	sed -e "s/__PHP_FPM_PORT__/$_PHP_FPM_PORT/g" |\
	sed -e "s|__APP_ROOT__|$_APP_ROOT|g" \
	> /etc/nginx/conf.d/default.conf

# If there aren't any we get errors from the entrypoint
if [ "$_EXTRAS_COUNT" -gt "0" ]; then 
	cp /docker-entrypoint-extras.d/*.conf /etc/nginx/conf.d/extras
fi

# This is required so we can change the command that is run when starting up
if [ "$#" -gt "0" ]; then
	$@
	exit "$?"
fi

nginx