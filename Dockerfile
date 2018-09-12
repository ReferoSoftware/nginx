FROM centos:centos7

LABEL maintainer="Adam Kirk <adamk@refero.uk>"

# Install the NGiNX web server package and clean the yum cache
RUN yum install -y epel-release
RUN yum update -y
RUN yum install -y --setopt=tsflags=nodocs nginx
RUN yum clean all

# We will add our own
RUN rm /etc/nginx/nginx.conf

COPY nginx.conf /etc/nginx/nginx.conf
COPY mime.types /etc/nginx/mime.types
COPY conf.d/default.conf.template /etc/nginx/conf.d/default.conf.template

# There is an include directive within default.conf.template in the server directive
# It includes these files allowing extra configuration to be supplied from higher up the stack
RUN mkdir /etc/nginx/conf.d/extras

# Files in here will be copied into /etc/nginx/conf.d/extras by the entrypoint
# This allows us to keep this image dumb, yet configurable
RUN mkdir /docker-entrypoint-extras.d

# As this is intended to run in openshift; sort the file ownerships
RUN touch /run/nginx.pid
RUN chown -R 1001:1001 /usr/share/nginx
RUN chown -R 1001:1001 /var/log/nginx
RUN chown -R 1001:1001 /var/lib/nginx
RUN chown -R 1001:1001 /run/nginx.pid
RUN chown -R 1001:1001 /etc/nginx
RUN chown -R 1001:1001 /etc/nginx/conf.d/extras
RUN chown -R 1001:1001 /docker-entrypoint-extras.d

# We've got a custom entrypoint script, which isn't doing much right now
# In the future it should contain a test/wait loop for the php-fpm instance
# it should only start when it can reach php-fpm
COPY entrypoint.sh /entrypoint.sh
RUN chown 1001:1001 /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER 1001

# Set the default port for applications built using this image
# This is how the default openshift NGiNX images work, so I rolled with it...
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
