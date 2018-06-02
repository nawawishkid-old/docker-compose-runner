FROM php:7.2-fpm

RUN apt-get update && \
    apt-get install -y mysql-client

RUN docker-php-ext-install mysqli

COPY ./load-wpcli.sh ${PWD}

RUN bash ${PWD}/load-wpcli.sh

RUN chown -R www-data:www-data /var/www

WORKDIR /var/www