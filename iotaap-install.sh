#!/bin/bash

# Exit if any command fails
set -e

echo "Installation script version: 1.0.0"
echo "Starting installation..."

# Run Docker installation script
echo "Installing Docker..."
./docker-install.sh

# Run NGINX installation script
echo "Installing NGINX..."
./nginx-install.sh

# Prompt for API_URL
read -p "Enter your application URL (e.g., https://cloud.iotaap.io): " api_url

# Extract the domain from api_url
domain=$(echo $api_url | awk -F[/:] '{print $4}')

# Prompt for iotaap OTA service URL
read -p "Enter your iotaap OTA service URL (e.g., https://ota.iotaap.io): " ota_url

# Extract the ota domain from ota_url
ota_domain=$(echo $ota_url | awk -F[/:] '{print $4}')

# Generate secrets
nextauth_secret=$(openssl rand -base64 32)
cypher_key=$(openssl rand -base64 32 | head -c 32)
r_token_iv=$(openssl rand -base64 16 | head -c 16)
iotaapsys_topic_password=$(openssl rand -base64 32 | head -c 32)
influxdb_init_user=$(openssl rand -base64 16 | head -c 16)
influxdb_init_password=$(openssl rand -base64 32 | head -c 32)
influxdb_init_admin_token=$(openssl rand -base64 32 | head -c 32)
iotaap_device_status_key=$(openssl rand -base64 32 | head -c 32)

# Create certs directory and generate certificates
mkdir -p certs
cd certs

# Generate CA key
openssl genrsa -out ca-key.pem 2048

# Generate CA certificate
openssl req -x509 -sha256 -new -nodes -key ca-key.pem -days 3650 -out cacert.pem -subj "/C=HR/ST=Croatia/L=Zagreb/O=MVT Solutions Group LTD/OU=iotaap/CN=iotaap Certification Authority/emailAddress=contact@iotaap.io"

# Generate Server Key
openssl genrsa -out key.pem 2048

# Generate CSR for the server certificate
openssl req -new -key key.pem -out server.csr -subj "/C=HR/ST=Croatia/L=Zagreb/O=MVT Solutions Group LTD/OU=iotaap/CN=${domain}/emailAddress=contact@iotaap.io"

# Generate Server Certificate
openssl x509 -req -in server.csr -CA cacert.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -days 3650

# Clean up CSR as it's no longer needed after certificate creation
rm server.csr

# Set permissions and ownership for certs directory for Next.js app
chown -R 1001:1001 .
chmod -R 755 .

# Create a copy of the certs for MQTT broker with root ownership
cd ..
mkdir -p certs_for_mqtt
cp certs/* certs_for_mqtt/
chown -R root:root certs_for_mqtt
chmod -R 755 certs_for_mqtt

# Create certs_for_ota directory and generate OTA service certificate
mkdir -p certs_for_ota
cd certs_for_ota

# Generate Key for OTA service
openssl genrsa -out key.pem 2048

# Generate CSR for OTA service certificate
openssl req -new -key key.pem -out ota_service.csr -subj "/C=HR/ST=Croatia/L=Zagreb/O=MVT Solutions Group LTD/OU=iotaap/CN=${ota_domain}/emailAddress=contact@iotaap.io"

# Generate OTA service Certificate
openssl x509 -req -in ota_service.csr -CA ../certs/cacert.pem -CAkey ../certs/ca-key.pem -CAcreateserial -out cert.pem -days 3650

# Clean up CSR as it's no longer needed after certificate creation
rm ota_service.csr

# Set permissions and ownership for certs_for_ota directory
chown -R root:root .
chmod -R 755 .

# Return to main directory
cd ..

# Create firmware directory
mkdir -p firmware

# Set permissions and ownership for firmware directory
chown -R 1001:1001 firmware
chmod -R 755 firmware

# Create logs directory and subdirectories for each service
mkdir -p logs/iotaap-manager
mkdir -p logs/iotaap-ota
mkdir -p logs/iotaap-storage

# Set permissions and ownership for each service's log directory
chown -R 1001:1001 logs/iotaap-manager
chmod -R 755 logs/iotaap-manager

chown -R 1001:1001 logs/iotaap-ota
chmod -R 755 logs/iotaap-ota

chown -R 1001:1001 logs/iotaap-storage
chmod -R 755 logs/iotaap-storage

# Fill the .env file with the provided and generated data
cat > .env <<EOF
API_URL=$api_url
NEXTAUTH_URL=$api_url
NEXTAUTH_SECRET=$nextauth_secret
MONGODB_URI=mongodb://mongo:27017/api
CYPHER_KEY=$cypher_key
R_TOKEN_IV=$r_token_iv

EMAIL_HOST=localhost
EMAIL_PORT=1025
EMAIL_USERNAME=
EMAIL_PASSWORD=
EMAIL_FROM=iotaap <noreply@iotaap.io>
EMAIL_IGNORE_TLS=true
EMAIL_SECURE=false
EMAIL_REQUIRE_TLS=false

IOTAAP_NETWORK=load_balancer
IOTAAPSYS_TOPIC=iotaapsys
IOTAAPSYS_TOPIC_PASSWORD=$iotaapsys_topic_password
IOTAAPSYS_TOPIC_PORT=1883

IOTAAP_SINGLE_REGISTRATION=true

INFLUX_URL=http://influx:8086
DOCKER_INFLUXDB_INIT_MODE=setup
DOCKER_INFLUXDB_INIT_USERNAME=$influxdb_init_user
DOCKER_INFLUXDB_INIT_PASSWORD=$influxdb_init_password
DOCKER_INFLUXDB_INIT_ORG=iotaap
DOCKER_INFLUXDB_INIT_BUCKET=iotaap-storage
DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=$influxdb_init_admin_token
DOCKER_INFLUXDB_INIT_RETENTION=180d

REDIS_URL=redis
BACKEND_URL=http://iotaap_manager:3000

IOTAAP_STORAGE_URL=http://storage_service:3001
IOTAAP_DEVICE_STATUS_KEY=$iotaap_device_status_key

IOTAAP_DEVICE_CERTIFICATE_VALIDITY=10
IOTAAP_DEVICE_AP_PASSWORD=wjp7b0gq

IOTAAP_OTA_SERVICE_URL_EXTERNAL=$ota_url
IOTAAP_OTA_SERVICE_URL_INTERNAL=http://ota_service:3080
EOF

echo "Installation and configuration have been completed successfully."

# Run iotaap
./iotaap-run.sh

# Print the CA certificate
echo "CA certificate (cacert.pem):"
cat certs/cacert.pem

# Print InfluxDB access details
echo "InfluxDB Username: $influxdb_init_user"
echo "InfluxDB Password: $influxdb_init_password"
