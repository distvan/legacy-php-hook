FROM php:8.3.1-fpm

# Update dependencies and install required packages, including MariaDB-related ones
RUN apt update \
    && apt install -y zlib1g-dev g++ git libicu-dev zip libzip-dev libxml2-dev \ 
    curl \ 
    ca-certificates \ 
    unzip \
    libcurl4-openssl-dev \ 
    && update-ca-certificates \
    libxml2-dev \
    && docker-php-ext-install intl opcache \
    && docker-php-ext-install dom xml xmlwriter \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip 

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Copy custom PHP configuration
COPY custom-php.ini /usr/local/etc/php/conf.d/custom-php.ini

#Set CA file expicitly
RUN echo "openssl.cafile=/etc/ssl/certs/ca-certificates.crt" >> /usr/local/etc/php/php.ini && \
    echo "curl.cainfo=/etc/ssl/certs/ca-certificates.crt" >> /usr/local/etc/php/php.ini


# Set the working directory for your app
WORKDIR /var/www/html

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer