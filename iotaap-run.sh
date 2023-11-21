#!/bin/bash

# Exit if any command fails
set -e
echo "Runner script version: 1.0.0"
echo "Running iotaap..."

# Check if the user is logged in to Docker
if ! docker info | grep -q "Username:"; then
    echo "You are not logged in to Docker."
    echo "Please log in to Docker to continue."
    docker login -u poliath
fi

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo "Error: docker-compose.yml not found in iotaap-docker directory."
    exit 1
fi

# Run the Docker containers in detached mode
echo "Starting Docker containers..."
sudo docker compose up -d

echo "iotaap is up and running!"
