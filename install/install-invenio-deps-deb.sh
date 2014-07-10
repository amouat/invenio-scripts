#!/bin/bash
#run as root
apt-get update
apt-get install -y git
apt-get install -y python-pip
apt-get install -y aptitude
easy_install -U distribute
apt-get install -y libmysqlclient-dev
aptitude install -y python-dev apache2-mpm-prefork \
              mysql-server mysql-client python-mysqldb \
              python-4suite-xml python-simplejson python-xml \
              python-libxml2 python-libxslt1 gnuplot poppler-utils \
              gs-common clisp gettext libapache2-mod-wsgi unzip \
              pdftk html2text giflib-tools \
              pstotext netpbm python-chardet sudo
aptitude install -y sbcl cmucl pylint pychecker pyflakes \
              python-profiler python-epydoc libapache2-mod-xsendfile \
              openoffice.org python-utidylib python-beautifulsoup \
apt-get install -y automake1.9 make python-gnuplot python-openid \
              python-magic ffmpeg libxml2-dev libxslt-dev
#configure apache
aptitude install ssl-cert
mkdir /etc/apache2/ssl

## disable Debian's default web site:
/usr/sbin/a2dissite default

## enable SSL module:
/usr/sbin/a2enmod ssl

#These are required by below branch but not in reqs.txt
pip install celery rq Flask-Script pyparsing numpy Babel workflow \
              pyRXP rauth pyPdf fixture

#Check out next branch of invenio
git config --global http.sslVerify false
git clone -v -b next https://github.com/EUDAT-B2SHARE/invenio.git

cd invenio
git fetch # just in case, to get then new tags
git checkout tags/b2share-v2 -b bshare-v2
#may need to remove libxml lines from requirements.txt
pip install -r requirements.txt
pip install -r requirements-extras.txt
pip install -r requirements-flask.txt --allow-external=twill --allow-unverified=twill
pip install -r requirements-flask-ext.txt

#think these might be needed now
aptitude install rabbitmq-server
/usr/lib/rabbitmq/bin/rabbitmq-activate-plugins rabbitmq_management
rabbitmqctl add_user www-data vagrant
rabbitmqctl add_vhost myvhost
rabbitmqctl set_permissions -p myvhost www-data ".*" ".*" ".*"
rabbitmqctl set_user_tags www-data management
rabbitmqctl change_password guest guest
service rabbitmq-server restart

pip install flower
pip install validate_email
pip install pyDNS

# create locatedb -- required for installation
updatedb
