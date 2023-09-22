# Installs nginx and stuff like that
exec { '/usr/bin/env sudo apt-get -y update' : }
-> exec { '/usr/bin/env sudo service nginx start' : }
-> exec { '/usr/bin/env sudo mkdir -p /data/web_static/releases/test/' : }
-> exec { '/usr/bin/env sudo mkdir -p /data/web_static/shared/' : }
-> exec { '/usr/bin/env echo "This is a test" > /data/web_static/releases/test/index.html' : }
-> exec { '/usr/bin/env sudo ln -sf /data/web_static/releases/test/ /data/web_static/current' : }
-> exec { '/usr/bin/env sudo sed -i '38i\\tlocation /hbnb_static/ {\n\t\talias /data/web_static/current/;\n\t}\n' /etc/nginx/sites-available/default : }
-> exec { '/usr/bin/env sudo service nginx restart' : }
-> exec { '/usr/bin/env sudo chown -R ubuntu:ubuntu /data/' : }
