# iotaap V2 Docker
This repository contains everything needed to run iotaap platform on your own server

## How to use
Scripts are handling all the work, so you just need to run them. Check [INSTALL.md](./INSTALL.md)

## Logs
Logs are stored in `logs` directory. Each service has its own log file.

## Environment variables
All environment variables are stored in `.env` file. You can change them there.

```shell
# Backend related configuration
## Pointing to the domain where app is hosted (e.g. cloud.iotaap.io)
API_URL=http://localhost:3000
## Pointing to the domain where app is hosted (e.g. cloud.iotaap.io), usually same as API_UR
NEXTAUTH_URL=http://localhost:3000
## Must be 32 characters long, used for auth cookie
NEXTAUTH_SECRET=7c4c1c50-3230-45bf-9eae-c9b2e401c768
## Do not change, pointing to mongo container
MONGODB_URI=mongodb://mongo:27017/api
## Must be 32 characters long
CYPHER_KEY=kPq7zR4XwU8JiGf2H6tLrE9oB1cYvD3m
## Must be 16 characters long
R_TOKEN_IV=8tFs8QaeqZ5FHMUm

# Email configuration
## SMTP server address (e.g. smtp.mailgun.org)
EMAIL_HOST=localhost
## SMTP server port (e.g. 465)
EMAIL_PORT=1025
## SMTP username
EMAIL_USERNAME=
## SMTP password
EMAIL_PASSWORD=
## Email address from which emails will be sent
EMAIL_FROM=iotaap <noreply@iotaap.io>
## false for no TLS, true for TLS, and 'required' for TLS & STARTTLS
EMAIL_IGNORE_TLS=true
## false for no TLS, true for TLS, and 'required' for TLS & STARTTLS
EMAIL_SECURE=false
## false for no TLS, true for TLS, and 'required' for TLS & STARTTLS
EMAIL_REQUIRE_TLS=false

# MQTT and 'iotaapsys' topic configuration
## MQTT broker address, without protocol. Do not change (for Docker: load_balancer)
IOTAAP_NETWORK=load_balancer
## Topic root (iotaapsys is always default)
IOTAAPSYS_TOPIC=iotaapsys
## iotaapsys topic password, must be 32 characters long
IOTAAPSYS_TOPIC_PASSWORD=Kr3StTr4l16KRFuiMsfd66RWwNTkeZMz
## iotaapsys topic port (default 1883, communication between containers)
IOTAAPSYS_TOPIC_PORT=1883

# On-premise configuration
## If true, only one (admin) user can register
IOTAAP_SINGLE_REGISTRATION=true

# InfluxDB configuration
## InfluxDB URL, do not change (for Docker: influx)
INFLUX_URL=http://influx:8086
## InfluxDB automatic configuration
DOCKER_INFLUXDB_INIT_MODE=setup
## InfluxDB dashboard username
DOCKER_INFLUXDB_INIT_USERNAME=root
## InfluxDB dashboard password
DOCKER_INFLUXDB_INIT_PASSWORD=password
## InfluxDB default organization
DOCKER_INFLUXDB_INIT_ORG=iotaap
## InfluxDB default bucket (iotaap-storage)
DOCKER_INFLUXDB_INIT_BUCKET=iotaap-storage
## InfluxDB admin token, must be 32 characters long
DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=Kr3StTr4l16KRFuiMsfd66RWwNTkeZMz
## InfluxDB default retention policy (180 days for storage)
DOCKER_INFLUXDB_INIT_RETENTION=180d

# Redis configuration
## Redis URL, do not change (for Docker: redis)
REDIS_URL=redis

# Storage service configuration
## Backend URL, do not change (for Docker: http://iotaap_manager:3000)
BACKEND_URL=http://iotaap_manager:3000
## Storage service API (for Docker: http://storage_service:3001)
IOTAAP_STORAGE_URL=http://storage_service:3001
## Storage service API key, must be 32 characters long
IOTAAP_DEVICE_STATUS_KEY=Kr3StTr4l16KRFuiMsfd66RWwNTkeZMz

# Device configuration
## Device certificate validity in years
IOTAAP_DEVICE_CERTIFICATE_VALIDITY=10
## Device default WiFi AP password, must be 8 characters long
IOTAAP_DEVICE_AP_PASSWORD=wjp7b0gq

# OTA configuration
## OTA service API (for Docker: http://localhost:3080)
IOTAAP_OTA_SERVICE_URL_EXTERNAL=http://localhost:3080
## Internal service for OTA (for Docker: http://ota_service:3080)
IOTAAP_OTA_SERVICE_URL_INTERNAL=http://ota_service:3080

```