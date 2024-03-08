#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Prompt for Redis password
read -sp "Enter Redis password: " PASSWORDPASSWORD
echo

# Create a directory for Redis server configuration
mkdir -p redis-server && cd redis-server

# Create docker-compose.yml with the user's password
cat <<EOF >docker-compose.yml
version: '3.7'
services:
  redis:
    image: redis:latest
    restart: always
    command: redis-server --requirepass $PASSWORDPASSWORD --appendonly yes
    ports:
      - "6379:6379"
    volumes:
      - ./data:/data
EOF

# Update apt repository and install Docker Compose
sudo apt-get update
sudo apt-get install docker-compose -y

# Start Redis container
docker-compose up -d
