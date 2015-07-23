#!/usr/bin/env bash

echo "---------------------"
echo "setting up Ubuntu"
echo "---------------------"
#Installing and setting up Apache
apt-get update
apt-get install -y apache2
#Removing /var/www and making it a soft link to /vagrant because /vagrant is shared with the VM host
#Then replace apache user, and group. www-data to vagrant.
#Then changing owner permissions and ownership data.
rm -rf /var/www
ln -fs /vagrant /var/www
sed -i 's/APACHE_RUN_USER=www-data/APACHE_RUN_USER=vagrant/' /etc/apache2/envvars
sed -i 's/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=vagrant/' /etc/apache2/envvars
chmod -R 777 /vagrant
chown -R vagrant:vagrant /var/lock/apache2
# setup apache hosts file entry
VHOST=$(cat <<EOF
<VirtualHost *:80>
    DocumentRoot "/vagrant"
    <Directory "/vagrant">
	Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)
#add it to the default conf file.
echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf
#start installing php and mysql.
echo "---------------------"
echo "Install PHP and MySQL"
echo "---------------------"
apt-get install -y php5 php5-cli libapache2-mod-php5 php5-mysql php5-imagick php-pear php5-curl php5-gd php5-dev  libpcre3-dev gcc make
apt-get install -y curl
apt-get install -y unzip git-core subversion
#setup mysql username and password
echo mysql-server mysql-server/root_password password tempass | sudo debconf-set-selections
echo mysql-server mysql-server/root_password_again password tempass | sudo debconf-set-selections
apt-get install -y mysql-server
#fetch and untar WordPress
cd /vagrant
echo "---------------------"
echo "Machine for deving WordPress Project(s)"
echo "---------------------"
echo "Installing WordPress"
wget http://WordPress.org/latest.tar.gz
tar -xzvf latest.tar.gz
#setting up mysql database, and user to use with WordPress
echo "---------------------"
echo "Setting up database for WordPress"
echo "---------------------"
echo "Setting up MySQL Database"
echo "CREATE USER 'wpdatabaseuser'@'localhost' IDENTIFIED BY 'wpdatabasepassword'" | mysql -uroot -puksites
echo "CREATE DATABASE wpdatabase" | mysql -uroot -puksites
echo "GRANT ALL ON wpdatabaseuser.* TO 'wpdatabase'@'localhost'" | mysql -uroot -puksites
echo "FLUSH PRIVILEGES" | mysql -uroot -puksites
#enable mod_rewrite and restart apache
sudo a2enmod rewrite
sudo service apache2 restart
echo "---------------------"
echo "WordPress dev environment all ready to go."
echo "---------------------"
