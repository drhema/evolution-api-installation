#!/bin/bash

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Automatically determine the Redis server IP address
REDIS_SERVER_IP=$(hostname -I | awk '{print $1}')
echo "Detected Redis server IP: $REDIS_SERVER_IP"

# Wait for 5 seconds
echo "Waiting for 5 seconds..."
sleep 5

# Prompt the user for the Redis password
echo -n "Enter Redis password (press Enter if none): "
read -s REDIS_PASSWORD
echo

# Wait for another 5 seconds
echo "Waiting for 5 seconds before testing connection..."
sleep 5

# Update UFW firewall rules
echo "Updating UFW firewall rules..."
sudo ufw allow 3000/tcp
sudo ufw allow 6379/tcp
sudo ufw allow 5432/tcp
echo "Firewall rules updated."

# Function to test Redis connectivity and operations
test_redis() {
    echo "Attempting to connect to Redis server at $REDIS_SERVER_IP..."

    # If a password is required, use the AUTH command to authenticate
    if [ -n "$REDIS_PASSWORD" ]; then
        # Check connection with authentication
        response=$(echo -e "AUTH $REDIS_PASSWORD\r\nSET testkey 'Hello, Redis!'\r\nGET testkey\r\nQUIT" | nc $REDIS_SERVER_IP 6379)
    else
        # Check connection without authentication
        response=$(echo -e "SET testkey 'Hello, Redis!'\r\nGET testkey\r\nQUIT" | nc $REDIS_SERVER_IP 6379)
    fi

    # Check if "Hello, Redis!" response was received
    if [[ $response == *"+OK"* && $response == *"Hello, Redis!"* ]]; then
        echo "Connection Successful: Test key-value pair set and retrieved successfully."
    else
        echo "Connection Failed: Unable to set or retrieve key-value pair from Redis."
        exit 1
    fi
}

# Run the test_redis function
test_redis
