FROM debian:jessie

RUN apt-get update && \
    apt-get -yq install apache2
RUN a2enmod proxy proxy_fcgi
RUN rm -v /etc/apache2/sites-enabled

COPY ./php-fpm-default.conf /etc/apache2/sites-available
COPY ./docker-entrypoint.sh ${PWD}

CMD [ "bash", "docker-entrypoint.sh" ]