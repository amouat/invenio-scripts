#!/bin/bash

# # invoke with
# cd
# sudo /vagrant/provision_system.sh 2>&1 | tee /vagrant/provision.log

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

echo; echo "### Stop iptables"
/etc/init.d/iptables stop
chkconfig iptables off

echo; echo "### System update"
yum -y update

echo; echo "### Install wget"
yum install -y wget vim

echo; echo "### Install epel"
wget http://www.mirrorservice.org/sites/dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
rpm -Uvh epel-release-6-8.noarch.rpm
rm epel-release-6-8.noarch.rpm

echo; echo "### Install lots of packages"
yum install -y git python-pip httpd mysql mysql-server gnuplot html2text netpbm \
           python-chardet python-simplejson mod_wsgi mod_ssl MySQL-python \
           libxml2-python libxslt-python poppler ghostscript-devel \
           giflib-devel sbcl pylint pychecker pyflakes epydoc mod_xsendfile \
           python-BeautifulSoup automake16 gcc python-devel mysql-devel \
           libxslt-devel libxml2-devel gettext-devel python-magic \
           java-1.7.0-openjdk-devel redis python-redis\
           automake autoconf unzip bzip2-devel  bzip2 npm \
           zlib-dev openssl-devel sqlite-devel bzip2-devel xz-libs

echo; echo "### Groupinstall development"
yum groupinstall -y --skip-broken development

echo; echo "### Install python27"
/vagrant/_install_python2.7.sh
echo 'export PATH="/opt/python-2.7.6/bin:/usr/local/bin:$PATH"' >> /home/vagrant/.bashrc
export PATH="/opt/python-2.7.6/bin:/usr/local/bin:$PATH"

echo; echo "### Install setuptools, easy_install, pip, Babel"
wget --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-1.4.2.tar.gz
tar -xvf setuptools-1.4.2.tar.gz
(cd setuptools-1.4.2 && python2.7 setup.py install)
rm setuptools-1.4.2.tar.gz
curl https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py | python2.7 -
easy_install pip Babel

if [[ `which pip` != "/opt/python-2.7.6/bin/pip" ]]; then
   echo "!!! pip not installed or wrong path"
   exit 1
fi

pip install flower # flower is for monitoring celery tasks
