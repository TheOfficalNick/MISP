FROM debian:stable-slim
LABEL maintainer="Your Name <your_email@example.com>"
ARG MISP_VERSION=2.4.143

#https sources
RUN apt-get update && apt-get install -y apt-transport-https

# Install dependencies
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
    git \
    curl \
    apache2 \
    libapache2-mod-php \
    php \
    php-cli \
    php-dev \
    php-json \
    php-mysql \
    php-pear \
    php-mcrypt \
    php-gd \
    php7.3-gmp \
    php7.3-xml \
    php7.3-bcmath \
    php7.3-ldap \
    php7.3-mbstring \
    php7.3-zip \
    php-redis \
    php-intl \
    php-curl \
    php-memcached \
    gcc \
    make \
    gnupg \
    mariadb-client \
    mariadb-server \
    supervisor \
    redis-server \
    sudo \
    && apt-get clean

# Install MISP
RUN git clone --branch $MISP_VERSION https://github.com/MISP/MISP.git /var/www/MISP
WORKDIR /var/www/MISP
RUN git submodule update --init --recursive

# Configure MISP
RUN cp -a /var/www/MISP/app/Config/bootstrap.default.php /var/www/MISP/app/Config/bootstrap.php && \
    cp -a /var/www/MISP/app/Config/database.default.php /var/www/MISP/app/Config/database.php && \
    cp -a /var/www/MISP/app/Config/core.default.php /var/www/MISP/app/Config/core.php && \
    cp -a /var/www/MISP/app/Config/config.default.php /var/www/MISP/app/Config/config.php && \
    cp -a /var/www/MISP/app/Config/email.default.php /var/www/MISP/app/Config/email.php && \
    cp -a /var/www/MISP/app/Config/setup.default.php /var/www/MISP/app/Config/setup.php

# Configure Apache
RUN a2enmod rewrite && \
    a2enmod ssl && \
    a2ensite default-ssl && \
    mkdir /etc/apache2/ssl && \
    openssl req -x509 -newkey rsa:4096 -nodes -keyout /etc/apache2/ssl/misp.key -out /etc/apache2/ssl/misp.crt -days 3650 -subj "/CN=localhost"

# Configure Supervisor
ADD ./docker/misp.supervisor.conf /etc/supervisor/conf.d/misp.supervisor.conf

# Expose ports
EXPOSE 443

# Start Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
