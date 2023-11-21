#!/bin/bash

echo "NGINX installation script version: 1.0.0"

# SSL certificate and key files
SSL_CERT="/home/ubuntu/certs/iotaap_io.crt"
SSL_KEY="/home/ubuntu/certs/iotaap_io.key"

# Check for the existence of the SSL certificate and key files
if [[ ! -f "$SSL_CERT" ]] || [[ ! -f "$SSL_KEY" ]]; then
    echo "Error: SSL certificate or key file does not exist in the expected location."
    echo "Please ensure the SSL certificate is present at $SSL_CERT"
    echo "and the SSL key is present at $SSL_KEY."
    exit 1
fi

# Ask for the domain name
read -p "Enter the subdomain name for the Nginx server (e.g., cloud.iotaap.io): " domain_name

# Ask for the storage subdomain name
read -p "Enter the storage service subdomain for the Nginx server (e.g., storage.iotaap.io): " storage_domain_name

# Ask for the ota subdomain name
read -p "Enter the OTA service subdomain for the Nginx server (e.g., ota.iotaap.io): " ota_domain_name

# Update package index
sudo apt update

# Install nginx
sudo apt install -y nginx

# Replace the default Nginx site configuration
sudo bash -c "cat > /etc/nginx/sites-available/default << 'EOF'
# Default server configuration

# HTTP redirect to HTTPS
# $domain_name
server {
    listen 80;
    listen [::]:80;
    server_name $domain_name;
    return 301 https://\$host\$request_uri;
}

# $storage_domain_name
server {
    listen 80;
    listen [::]:80;
    server_name $storage_domain_name;
    return 301 https://\$host\$request_uri;
}

# $ota_domain_name
server {
    listen 80;
    listen [::]:80;
    server_name $ota_domain_name;
    return 301 https://\$host\$request_uri;
}

# HTTPS configuration
# $domain_name
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    ssl on;
    ssl_certificate $SSL_CERT;
    ssl_certificate_key $SSL_KEY;
    ssl_prefer_server_ciphers on;
    index index.html index.php index.htm;
    server_name $domain_name;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}

# $storage_domain_name
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    ssl on;
    ssl_certificate $SSL_CERT;
    ssl_certificate_key $SSL_KEY;
    ssl_prefer_server_ciphers on;
    index index.html index.php index.htm;
    server_name $storage_domain_name;

    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}

# $ota_domain_name
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    ssl on;
    ssl_certificate $SSL_CERT;
    ssl_certificate_key $SSL_KEY;
    ssl_prefer_server_ciphers on;
    index index.html index.php index.htm;
    server_name $ota_domain_name;

    location / {
        proxy_pass http://localhost:3080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF"

# Restart nginx to apply the changes
sudo service nginx restart

echo "Nginx has been installed and configured for the following domains:"
echo "iotaap-manager: $domain_name"
echo "iotaap-storage: $storage_domain_name"
echo "iotaap-ota: $ota_domain_name"
