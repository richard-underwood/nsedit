FROM debian:jessie
MAINTAINER Yury Evtikhov <yury@evtikhov.info>
#
# This Dockerfile is intended only for test/development use.
# It will be a really BAD idea to use it for production or public services.
#

ENV DEBIAN_FRONTEND noninteractive

#
# Please set the following variables before building:
#
ENV PDNSAPIPWD mypowerdnsapipassword
ENV PDNSAPIIP 192.168.1.2
ENV PDNSAPIPORT 8081

# Update and Upgrade system
RUN apt-get -y update && \
    apt-get -y install curl git-core php5-cli php5-curl php5-json php5-sqlite && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir /app
RUN git clone --recursive https://github.com/tuxis-ie/nsedit.git /app/nsedit
RUN cp /app/nsedit/includes/config.inc.php-dist /app/nsedit/includes/config.inc.php
RUN sed "s/\$apipass = ''/\$apipass = '$PDNSAPIPWD'/" -i /app/nsedit/includes/config.inc.php && \
    sed "s/\$apiip   = ''/\$apiip = '$PDNSAPIIP'/" -i /app/nsedit/includes/config.inc.php && \
    sed "s/\$apiport = '8081'/\$apiport = '$PDNSAPIPORT'/" -i /app/nsedit/includes/config.inc.php && \
    sed "s/\$authdb  = \"\.\.\/etc\/pdns\.users\.sqlite3\"/\$authdb  = \"\/app\/pdns\.users\.sqlite3\"/" -i /app/nsedit/includes/config.inc.php

# Define working directory.
VOLUME /app/nsedit
WORKDIR /app/nsedit
EXPOSE 8080

ENTRYPOINT ["/usr/bin/php", "-S", "0.0.0.0:8080"]

#
# Usage:
#    docker build -t nseditphp .
#    docker run -d --name pdns-nsedit -p 80:8080 nseditphp
#
