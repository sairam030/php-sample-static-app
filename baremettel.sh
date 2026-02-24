#!/bin/bash
set -e

echo "Disabling all existing Apache sites..."

for site in /etc/apache2/sites-enabled/*.conf; do
    sudo a2dissite $(basename $site)
done

SRC_DIR="$WORKSPACE"
DEST_DIR="/var/www/html/phpstatic"
APACHE_CONF="/etc/apache2/sites-available/phpstatic.conf"

echo "Starting deployment..."

sudo mkdir -p $DEST_DIR
sudo apt-get update -y
sudo apt-get install -y apache2 rsync

echo "Copying files..."
sudo rsync -av --delete --exclude=".git" "$SRC_DIR/" "$DEST_DIR/"

echo "Setting permissions..."
sudo chown -R www-data:www-data $DEST_DIR
sudo chmod -R 755 $DEST_DIR

echo "Creating Apache config..."
sudo bash -c "cat > $APACHE_CONF" <<EOF
<VirtualHost *:80>
    ServerAdmin admin@localhost
    DocumentRoot $DEST_DIR
    <Directory $DEST_DIR>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

sudo a2ensite phpstatic.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

echo "Deployment successful!"
