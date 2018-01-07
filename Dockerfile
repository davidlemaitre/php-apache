FROM php:7.0.26-apache
LABEL maintainer="David Lemaitre"

# Install dependencies
RUN echo "deb http://deb.debian.org/debian stretch main" > /etc/apt/sources.list.d/stretch.list
RUN apt-get update && apt-get install -y --no-install-recommends \
    imagemagick \
    mysql-client \
    locales \
    libxml2-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    zlib1g-dev \
    libicu-dev \
    libcurl4-gnutls-dev \
    libxslt-dev \
# Fix outdated PCRE bug in Debian 8
    && apt-get install -y -t stretch libpcre3 libpcre3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install \
    mysqli \
    pdo \
    pdo_mysql \
    soap \
    intl \
    mcrypt \
    gd \
    mbstring \
    zip \
    curl \
    json \
    xsl
    
# Enable Apache mods
RUN a2enmod rewrite alias headers expires

# Enable SSL
RUN a2enmod ssl && a2ensite default-ssl

# Set timezone
RUN echo "Europe/Paris" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata

# Reconfigure locales
RUN dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8

RUN echo 'fr_FR.UTF-8 UTF-8' >> /etc/locale.gen && locale-gen

# Custom PHP configuration
RUN echo "always_populate_raw_post_data = -1" >> $PHP_INI_DIR/conf.d/custom.ini
RUN echo "max_execution_time = 240" >> $PHP_INI_DIR/conf.d/custom.ini
RUN echo "max_input_vars = 1500" >> $PHP_INI_DIR/conf.d/custom.ini
RUN echo "upload_max_filesize = 32M" >> $PHP_INI_DIR/conf.d/custom.ini
RUN echo "post_max_size = 32M" >> $PHP_INI_DIR/conf.d/custom.ini
RUN echo "memory_limit = 256M" >> $PHP_INI_DIR/conf.d/custom.ini
RUN echo "date.timezone = Europe/Paris" >> $PHP_INI_DIR/conf.d/custom.ini

# Export ports
EXPOSE 443
