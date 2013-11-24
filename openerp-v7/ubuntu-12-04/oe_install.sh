#!/bin/bash
################################################################################
# Script for Installation: OpenERP 7.0 server on Ubuntu 12.04 LTS
# Author: André Schenkels, ICTSTUDIO 2013
#-------------------------------------------------------------------------------
#  
# This script will install OpenERP Server with PostgreSQL server 9.2 on
# clean Ubuntu 12.04 Server
#-------------------------------------------------------------------------------
# USAGE:
#
# oe-install
#
# EXAMPLE:
# oe-install 
#
################################################################################
 
##fixed parameters
#openerp
OE_USER="openerp"
OE_HOME="/opt/openerp"

#set the revisions you want to use
OE_WEB_REV="3941"
OE_SERVER_REV="5004"
OE_ADDONS_REV="9154"

#set the superadmin password
OE_SUPERADMIN="superadminpassword"

OE_CONFIG="openerp-server"

#postgres user and password
PG_USER="openerp"
PG_PASSWORD="password"
PG_SERVER="localhost"

#--------------------------------------------------
# Install PostgreSQL Server
#--------------------------------------------------
echo -e "\n---- Install PostgreSQL Server 9.2  ----"
sudo wget -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | sudo apt-key add -
sudo su root -c "echo 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main' >> /etc/apt/sources.list.d/pgdg.list"
sudo su root -c "echo 'Package: *' >> /etc/apt/preferences.d/pgdg.pref"
sudo su root -c "echo 'Pin: release o=apt.postgresql.org' >> /etc/apt/preferences.d/pgdg.pref"
sudo su root -c "echo 'Pin-Priority: 500' >> /etc/apt/preferences.d/pgdg.pref"
yes | sudo apt-get update
yes | sudo apt-get install pgdg-keyring
yes | sudo apt-get install postgresql-9.2

#--------------------------------------------------
# Install Dependencies
#--------------------------------------------------
echo -e "\n---- Install tool packages ----"
yes | sudo apt-get install wget subversion bzr bzrtools python-pip
	
echo -e "\n---- Install python packages ----"
yes | sudo apt-get install python-dateutil python-feedparser python-ldap \
python-libxslt1 python-lxml python-mako python-openid python-psycopg2 \
python-pybabel python-pychart python-pydot python-pyparsing python-reportlab \
python-simplejson python-tz python-vatnumber python-vobject python-webdav \
python-werkzeug python-xlwt python-yaml python-zsi python-docutils \
python-psutil python-mock python-unittest2 python-jinja2
	
echo -e "\n---- Install python libraries ----"
sudo pip install gdata
	
echo -e "\n---- Create OpenERP system user ----"
sudo adduser --system --quiet --shell=/bin/bash --home=$OE_HOME --gecos 'OpenERP' --group $OE_USER

echo -e "\n---- Create Log directory ----"
sudo mkdir /var/log/$OE_USER
sudo chown $OE_USER:$OE_USER /var/log/$OE_USER

#--------------------------------------------------
# Install OpenERP
#--------------------------------------------------
echo -e "\n==== Installing OpenERP Server ===="

echo -e "\n---- Getting latest version from bazaar or specific revision ----"
sudo su openerp -c "bzr branch lp:openobject-server/7.0 $OE_HOME/server -r $OE_SERVER_REV"
sudo su openerp -c "bzr branch lp:openobject-addons/7.0 $OE_HOME/addons -r $OE_ADDONS_REV"
sudo su openerp -c "bzr branch lp:openerp-web/7.0 $OE_HOME/web -r $OE_WEB_REV"

echo -e "\n---- Create custom module directory ----"
sudo su openerp -c "mkdir $OE_HOME/custom"

echo -e "\n---- Setting permissions on home folder ----"
sudo chown -R $OE_USER:$OE_USER $OE_HOME/*

echo -e "* Create server config file"
sudo cp $OE_HOME/server/install/openerp-server.conf /etc/$OE_CONFIG.conf
sudo chown $OE_USER:$OE_USER /etc/$OE_CONFIG.conf
sudo chmod 640 /etc/$OE_CONFIG.conf

echo -e "* Change server config file"
#sudo sed -i s/"db_user = .*"/"db_user = $PG_USER"/g /etc/$OE_CONFIG.conf
#sudo sed -i s/"db_password = .*"/"db_password = $PG_PASSWORD"/g /etc/$OE_CONFIG.conf
#sudo sed -i s/"db_host = .*"/"db_host = $PG_SERVER"/g /etc/$OE_CONFIG.conf
#sudo sed -i s/"; admin_passwd.*"/"admin_passwd = $OE_SUPERADMIN"/g /etc/$OE_CONFIG.conf

sudo su root -c "echo 'logfile = /var/log/$OE_USER/$OE_CONFIG$1.log' >> /etc/$OE_CONFIG.conf"
sudo su root -c "echo 'addons_path=$OE_HOME/addons,$OE_HOME/web/addons,$OE_HOME/custom/addons' >> /etc/$OE_CONFIG.conf"

echo -e "* Create startup file"
sudo su root -c "echo '#!/bin/sh' >> $OE_HOME/start.sh"
sudo su root -c "echo 'sudo -u $OE_USER $OE_HOME/server/openerp-server --config=/etc/$OE_CONFIG.conf' >> $OE_HOME/start.sh"
sudo chmod 755 $OE_HOME/start.sh
 
echo "Done!"

