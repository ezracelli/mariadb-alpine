FROM alpine

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN apk add --update --no-cache shadow && \
  groupadd -r mysql && useradd -r -g mysql mysql

RUN apk add --update --no-cache su-exec

RUN mkdir /docker-entrypoint-initdb.d

RUN apk add --update --no-cache \
# for docker-entrypoint.sh
  bash \
  coreutils \
  tzdata \
  su-exec \
# for MYSQL_RANDOM_ROOT_PASSWORD
  pwgen \
# for mysql_ssl_rsa_setup
  openssl \
# FATAL ERROR: please install the following Perl modules before executing /usr/local/mysql/scripts/mysql_install_db:
# File::Basename
# File::Copy
# Sys::Hostname
# Data::Dumper
  perl

RUN apk add --update --no-cache mariadb mariadb-client && \
  rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld && \
  chown -R mysql:mysql /var/lib/mysql && \
  chmod 777 /var/run/mysqld

VOLUME /var/lib/mysql

# Config files
COPY config/ /etc/mysql/
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306 33060
CMD ["mysqld"]
