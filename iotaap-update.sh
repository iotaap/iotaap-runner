#!/bin/bash

# Exit if any command fails
set -e

echo "Starting update..."

# Pull the latest changes from the main branch
echo "Pulling the latest iotaap docker-compose.yml..."
git pull origin main

echo "Update has been completed successfully."

# Run iotaap
./iotaap-run.sh