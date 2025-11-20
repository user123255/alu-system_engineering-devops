#!/bin/bash

# Update and install Nginx
apt update
apt install -y nginx

# Get the hostname of the server
HOSTNAME=$(hostname)

# Configure Nginx to add the custom header
cat <<EOT > /etc/nginx/conf.d/custom_header.conf
server {
    listen 80;
    server_name $HOSTNAME;

    location / {
        add_header X-Served-By "\$HOSTNAME";
        proxy_pass http://localhost:3000; # Adjust according to your application
    }
}
EOT

# Remove default server block
rm /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Restart Nginx to apply changes
systemctl restart nginx
