# Class: cabot::webserver
#
# Private class. Only calling cabot main class is supported.
#
class cabot::webserver inherits ::cabot {
  # puppetlabs/apache



#				# Remove default ubuntu nginx configuration
#				sudo rm -f /etc/nginx/sites-enabled/default


#				# Generate self-signed ssl certs
#				# http://wiki.nginx.org/HttpSslModule
#				sudo mkdir -p /usr/local/nginx
#				if [ ! -e /usr/local/nginx/testing.crt ]; then
#				echo 'Generating self-signed certificate'
#				cd /usr/local/nginx
#				sudo openssl genrsa -des3 -passout pass:pass -out testing.key 1024
#				(
#				echo '.' # Country 2-letter code
#				echo '.' # State/province name
#				echo '.' # Locality name
#				echo 'Arachnys' # Company name
#				echo '.' # Organizational unit name
#				echo '.' # Common name
#				echo '.' # Email address
#				echo '' # Challenge password
#				echo '' # Optional company name
#				) |
#				sudo openssl req -new -key testing.key -passin pass:pass -out testing.csr
#				sudo cp testing.key testing.key.orig
#				sudo openssl rsa -in testing.key.orig -passin pass:pass -out testing.key
#				sudo openssl x509 -req -days 1825 -in testing.csr -signkey testing.key -out testing.crt
#				sudo rm testing.key.orig testing.csr
#				cd -
#				fi


#				# Configure nginx proxy
#				echo 'Writing nginx proxy configuration'
#				if [ -e /etc/nginx/sites-available/cabot ]; then
#				echo 'WARNING: overwriting existing nginx configuration. Any local changes will be lost'
#				fi
#				sudo tee /etc/nginx/sites-available/cabot << EOF
#				server {
#				listen 80;
#				location / {
#				proxy_pass http://localhost:5000/;
#				proxy_set_header Host \$http_host;
#				proxy_set_header X-Real-IP \$remote_addr;
#				proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#				}
#				location /static/ {
#				alias /home/ubuntu/cabot/static/;
#				}


#				# Uncomment line below to force https
#				#return 301 https://\$host\$request_uri;
#				}


#				# Proxy secure traffic to cabot
#				# server {
#				# listen 443 ssl;
#				# ssl_certificate /usr/local/nginx/testing.crt;
#				# ssl_certificate_key /usr/local/nginx/testing.pem;
#				# location / {
#				# proxy_pass http://localhost:5000/;
#				# proxy_set_header Host \$http_host;
#				# proxy_set_header X-Real-IP \$remote_addr;
#				# proxy_set_header X-Forwarded-Proto https;
#				# proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
#				# proxy_redirect http:// https://;
#				# }
#				# location /static/ {
#				# alias $DEPLOY_PATH/static/;
#				# }
#				# }


#				# Enable cabot configuration and restart nginx
#				if [ ! -e /etc/nginx/sites-enabled/cabot ]; then
#				echo 'Enabling proxy in nginx configuration'
#				sudo ln -s /etc/nginx/sites-available/cabot /etc/nginx/sites-enabled/cabot
#				fi

#				sudo service nginx restart

}
