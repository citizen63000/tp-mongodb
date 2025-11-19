FROM ubuntu:24.04

# Mise à jour du système et installation des dépendances
RUN apt update && \
    apt dist-upgrade -y && \
    apt install -q -y \
        wget \
        unzip \
        apache2 \
        php \
        libapache2-mod-php \
        php-mongodb \
        php-zip \
        php-redis \
        php-curl && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Configuration de debconf pour éviter les prompts interactifs
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Installation de Composer
RUN wget -O /usr/local/bin/composer https://getcomposer.org/download/latest-stable/composer.phar && \
    chmod +x /usr/local/bin/composer

# Configuration d'Apache
COPY ./app.conf /etc/apache2/sites-available/app.conf
RUN a2enmod rewrite headers && \
    a2dissite 000-default.conf && \
    rm -rf /var/www/html && \
    a2ensite app.conf

# Création du répertoire de travail
RUN mkdir -p /var/www/app && \
    chown -R www-data:www-data /var/www/app

WORKDIR /var/www/app

# Point d'entrée
ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
