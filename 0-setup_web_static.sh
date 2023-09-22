#!/usr/bin/env bash
# installs nginx
sudo apt-get -y update
sudo apt-get -y install nginx
sudo sed -i '37i\rewrite ^/redirect_me http://driiis.tech permanent;' /etc/nginx/sites-available/default
sudo sed -i '38i\error_page 404 /error_404.html;' /etc/nginx/sites-available/default
sudo sed -i '/^http {/a \\tadd_header X-Served-By $hostname;' /etc/nginx/nginx.conf
# echo "Ceci n'est pas une page" > /var/www/html/custom_404.html
sudo service nginx start
sudo mkdir -p /data/web_static/releases/test/
sudo mkdir -p /data/web_static/shared/
sudo echo "This is a test" > /data/web_static/releases/test/index.html
sudo ln -sf /data/web_static/releases/test/ /data/web_static/current
sudo chown -R ubuntu:ubuntu /data/
sudo sed -i '38i\\tlocation /hbnb_static/ {\n\t\talias /data/web_static/current/;\n\t}\n' /etc/nginx/sites-available/default
sudo service nginx restart
