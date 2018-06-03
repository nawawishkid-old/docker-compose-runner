FROM debian:jessie

# Install apache2
RUN apt-get update && \
    apt-get -y install apache2

# Enable module for php-fpm
RUN a2enmod proxy proxy_fcgi

# Copy default vhost config for php-fpm
COPY ./php-fpm-default.conf /etc/apache2/sites-available
COPY ./docker-entrypoint.sh /etc/apache2

# Disable all site
RUN rm -v /etc/apache2/sites-enabled/*

# Enable default site for php-fpm, then restart apache2
RUN a2ensite php-fpm-default && \ 
    service apache2 restart

WORKDIR /var/www

CMD [ "bash", "/etc/apache2/docker-entrypoint.sh" ]