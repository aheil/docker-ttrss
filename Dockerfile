FROM php:7.2-fpm-alpine

RUN apk add --no-cache --virtual .build-deps \
      autoconf \
      curl-dev \
      freetype-dev \
      g++ \
      icu-dev \
      imagemagick-dev \
      libjpeg-turbo-dev \
      libmcrypt-dev \
      libpng-dev \
      libxml2-dev \
      make \
      openldap-dev \
      postgresql-dev \
    && \
    docker-php-ext-configure gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr && \
    docker-php-ext-configure ldap && \
    docker-php-ext-install \
    	curl \
    	dom \
    	gd \
    	iconv \
    	intl \
    	ldap \
    	mysqli \
      # mysqlnd \
    	pcntl \
    	pdo_mysql \
    	posix \
      pdo \
      pdo_pgsql \
      pgsql \
    && \
    pecl install APCu-5.1.17 && \
    pecl install mcrypt-1.0.2 && \
    docker-php-ext-enable \
      apcu \
      mcrypt \
    && \
    runDeps="$( \
        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
            | tr ',' '\n' \
            | sort -u \
            | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
    )" && \
    apk add --no-cache $runDeps && \
    apk add --no-cache bash postgresql-client && \
    apk del .build-deps

RUN wget -q https://git.tt-rss.org/fox/tt-rss/archive/master.tar.gz -O - | tar xzf - -C /var/www/html --strip-components=1 && \
    chown -R www-data:www-data /var/www/html

USER www-data

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["php-fpm", "-d", "expose_php=0"]
