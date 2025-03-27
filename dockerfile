# Start from the official Debian base image

FROM debian:bullseye-slim

# Set environment variables to avoid interactive prompts during package installation

ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install required packages

RUN apt-get update && apt-get install -y \

apache2 \

php \

php-mysqli \

mysql-server \

vsftpd \

curl \

wget \

gnupg2 \

lsb-release \

sudo \

unzip \

ca-certificates \

apt-transport-https \

&& apt-get clean

# Install phpMyAdmin for MySQL administration

RUN wget -qO - https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz -O /tmp/phpmyadmin.tar.gz \

&& tar -xvzf /tmp/phpmyadmin.tar.gz -C /var/www/html/ \

&& mv /var/www/html/phpMyAdmin-* /var/www/html/phpmyadmin \

&& chown -R www-data:www-data /var/www/html/phpmyadmin \

&& rm /tmp/phpmyadmin.tar.gz

# Install Webmin for system administration

RUN wget http://prdownloads.sourceforge.net/webadmin/webmin_1.981_all.deb -O /tmp/webmin.deb \

&& dpkg --install /tmp/webmin.deb \

&& apt-get -f install -y \

&& rm /tmp/webmin.deb

# Enable Apache2 and PHP modules

RUN a2enmod php7.4 \

&& a2enmod rewrite

# Configure MySQL

RUN service mysql start && \

mysql -e "CREATE DATABASE mydb;" && \

mysql -e "CREATE USER 'user'@'localhost' IDENTIFIED BY 'password';" && \

mysql -e "GRANT ALL PRIVILEGES ON mydb.* TO 'user'@'localhost';" && \

mysql -e "FLUSH PRIVILEGES;"

# Expose necessary ports

EXPOSE 80 443 3306 21 10000

# Configure vsftpd (optional: provide a custom config file)

# COPY ./vsftpd_config /etc/vsftpd.conf

# Start Apache, MySQL, and vsftpd services and keep container running

CMD service mysql start && \

service apache2 start && \

service vsftpd start && \

service webmin start && \

tail -f /dev/null
