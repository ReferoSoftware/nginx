# NGiNX

An NGiNX docker image designed to run on the openshift container platform.

This is designed to work with php-fpm, so the default configuration will direct requests to the php-fpm cgi, through a host and port (not a socket).

---

## default.conf.template

If you look in `default.conf.template` you'll notice that it uses an couple off off directives, something like `listen __LISTEN_PORT__`. It is created this way so that this image is portable, we should be able to run this image in almost any environment by configuring environment variables. Before the NGiNX process is started, the `./conf.d/default.conf.template` file is run through a simple sed script which replaces the corresponding placeholders with the supplied environment variables. See the `./entrypoint.sh` script to see how this is done.

The pattern to use this is very simple, remove the prefixed and suffixed '__' from the placeholder name and that is the name of the environment variable you need to supply to override these.

---

## Configurable environment variables

This image is aware of the following environment variables:

| Environment variable | Default value   | Description |
|----------------------|-----------------|-------------|
| `LISTEN_PORT`        | `8080`          | Changes the port in the listen directive for NGiNX to the supplied value. |
| `PHP_FPM_PORT`       | `9000`          | Changes the port that NGiNX expects php-fpm to be listening on. |
| `PHP_FPM_HOST`       | `phpfpm`        | Changes the host that NGiNX expects to find the php-fpm service. |
| `APP_ROOT`           | `/opt/app-root/public` | This defines where the application root directory is, which NGiNX should serve requests from. |

All of these variables will be replaced (where applicable) before starting the NGiNX process.

---

## Openshift container engine

This image is designed to run on the openshift container engine, which is the primary reason it extends the `centos:centos7` image as opposed to the official `nginx:*` distributions. The main restriction this places upon the image is the user and file permissions, please see the openshift documentation to learn more about writing images for use in that ecosystem.

---

## Looking forward

This image isn't as configurable as I'd like...it can only really work with a php-fpm service. As you should know NGiNX can serve just static content or potentially use many different server directives for things such as proxies. I would like to make this image more intelligent by having some different configurations which will be used dependent upon whether certain environment variables are set.

This will allow us to maintain only a single NGiNX image, without having to make the image extremely large and have too many purposes. This NGiNX image should only ever be configured to serve one site; in the docker ecosystem you should use another instance of this container rather than serving multiple sites through the same container.