#!/bin/bash

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Install necessary packages
echo "Installing Nginx and Certbot for SSL..."
apt-get update -qq
apt-get install -y nginx certbot python3-certbot-nginx snapd

# Ask user for the server name
read -p "Enter the server name (subdomain): " SERVER_NAME

# Update firewall rules as requested
echo "Updating firewall rules..."
ufw allow 3000/tcp
ufw allow 6379/tcp
ufw allow 5432/tcp
ufw allow 'Nginx Full'
ufw allow OpenSSH
ufw --force enable

# Obtain SSL certificates from Let's Encrypt
echo "Obtaining SSL certificates from Let's Encrypt for $SERVER_NAME..."
certbot --nginx -d $SERVER_NAME --non-interactive --agree-tos --email your-email@example.com --redirect

# Check if the SSL certificate was successfully obtained and nginx config was adjusted
if [ $? -ne 0 ]; then
    echo "Failed to obtain SSL certificate."
    exit 1
fi

# Create Nginx configuration for your application
CONFIG_PATH="/etc/nginx/sites-available/$SERVER_NAME"
ln -s $CONFIG_PATH /etc/nginx/sites-enabled/

# Update the Nginx configuration
echo "Configuring Nginx to serve your application over SSL..."
cat > $CONFIG_PATH <<EOF
server {
    listen 443 ssl;
    server_name $SERVER_NAME;

    ssl_certificate /etc/letsencrypt/live/$SERVER_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$SERVER_NAME/privkey.pem;

    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Check for syntax errors and restart Nginx
echo "Checking Nginx configuration for syntax errors..."
nginx -t && systemctl restart nginx

if [ $? -ne 0 ]; then
    echo "Nginx configuration error. Check your configuration!"
    exit 1
else
    echo "Nginx is configured and restarted successfully."
fi

echo "Installation and configuration completed successfully."
