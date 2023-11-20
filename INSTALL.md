# IoTaaP Platform Installation Guide
This guide provides instructions on how to install and configure the iotaap platform on an Ubuntu server. It includes setting up the necessary environment with Docker and NGINX, and configuring the iotaap platform to run with proper certificates and environment variables.

## Prerequisites

Before you begin, ensure you have the following:

- An Ubuntu server (22.04 LTS or newer)
  - EC2 instance, c5a.large is minimum, Ubuntu 22.04 LTS
  - At least 60GB of EBS (drive) if storage service is used
- SSH access to the server
- Sudo privileges on the server
- Access to Private Docker Registry
- Domain name pointing to your server's IP address for HTTPS configuration
- SSL certificate and key for your domain (e.g., `iotaap_io.crt` and `iotaap_io.key`)
- Configured Route 53 zones (records) for subdomains pointing to the EC2 instance (you will need (at least):
  - Manager domain/subdomain, e.g. cloud.iotaap.io
  - MQTT subdomain, e.g. mqtt.iotaap.io
  - OTA subdomain, e.g. ota.iotaap.io
  - Storage subdomain, e.g. storage.iotaap.io
  - (Optionally) Influx dashboard, e.g. influx.iotaap.io
- Configured Security groups

## SSL Cetificates
Technical officer will provide you with the certificates since those certificates are used across multiple iotaap.io services (domains and subdomains).

## AWS Security Groups
We are using AWS security groups to limit access to various ports of our instance(s). In this case on AWS, there is a security group ‘IoTaaP docker deployment’. Group has Outbound rules to allow all traffic and Inbound rules to allow traffic to ports: 80 - HTTP, 443 - HTTPS, 1883 - MQTT unsecured, 8883 - MQTT secured, 3443 for secure OTA updates, and optionally 22 - SSH which must be avoided and VPN must be used. If SSH access is used directly to access the server, it must be closed as soon as all work has been done.

# Installation Steps

## SSL Certificates
Position yourself in 'HOME' directory, where all iotaap scripts should be. Create `certs` directory and place `iotaap_io.crt` and `iotaap_io.key` there. Those are certificate and key for *.iotaap.io domain.

Secure the certificates:

```sh
sudo chown root:root -R certs
sudo chmod 640 -R certs
```

## Installation
You are ready to run installation and configuration of iotaap:

```sh
chmod +x iotaap-install.sh
chmod +x iotaap-run.sh
chmod +x iotaap-update.sh
chmod +x docker-install.sh
chmod +x nginx-install.sh

sudo ./iotaap-install.sh
```
### This is the workflow:

- Docker is installed
- Nginx is installed - Here you will be prompted for a Domain name (subdomain), storage subdomain and  ota subdomain in order to configure Nginx, enter the domain without https://
- Docker images will be pulled from the private registry
- You will be prompted for API_URL - which is the same as a Domain name (subdomain), where iotaap runs, and IOTAAP_OTA_SERVICE_URL which is the subdomain where ota service runs, enter domain names but this time including https://
- All iotaap certificates will be generated and permissions configured, also .env file will be generated and all secrets will be automatically generated. Please note that generated certificates are not related to SSL certificates that we had to configure for our HTTPS access.
- Finally, all containers will start, and you will get cacert.pem content, and InfluxDB Username and password (if needed to be used internally)

## Updating
The update is also fully automated, and you have to run:

```sh
sudo ./iotaap-update.sh
```

