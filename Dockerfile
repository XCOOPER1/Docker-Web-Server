# Use Debian Buster as the base image
FROM debian:buster

# Install necessary packages
RUN apt-get update && apt-get install -y \
    nginx \
    mariadb-server \
    php-fpm php-mysql \
    wget \
    curl \
    unzip \
    php-json php-mbstring php-zip php-gd \
    php-curl php-xml php-intl php-soap \
    php-gettext php-xmlrpc php-bcmath

# Install WordPress
RUN mkdir -p /var/www/html/wordpress && \
    wget -q https://wordpress.org/latest.tar.gz -O /tmp/latest.tar.gz && \
    tar -xzf /tmp/latest.tar.gz --strip-components=1 -C /var/www/html/wordpress

# Install phpMyAdmin
RUN wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz -O /tmp/phpmyadmin.tar.gz && \
    tar -xzf /tmp/phpmyadmin.tar.gz -C /var/www/html/ && \
    mv /var/www/html/phpMyAdmin-*-all-languages /var/www/html/phpmyadmin

# Set up MySQL
RUN service mysql start && \
    mysql -u root -e "CREATE DATABASE wordpress;" && \
    mysql -u root -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY 'password';" && \
    mysql -u root -e "FLUSH PRIVILEGES;"

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy WordPress configuration file from the 'www' directory
COPY www/wp-config.php /var/www/html/wordpress/wp-config.php

# Expose port 80 for web access
EXPOSE 80

# Start services
CMD service mysql start && service php7.3-fpm start && nginx -g 'daemon off;'
