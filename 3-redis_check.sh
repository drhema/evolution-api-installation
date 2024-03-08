#!/bin/bash

# Automatically determine the Redis server IP address
REDIS_SERVER_IP=$(hostname -I | awk '{print $1}')

# Prompt the user for the Redis password
echo -n "Enter Redis password: "
read -s REDIS_PASSWORD
echo

# Function to test Redis connectivity and operations
test_redis() {
    echo "Trying to connect to Redis server at $REDIS_SERVER_IP..."

    # Check connection with authentication if a password was provided
    if [ -n "$REDIS_PASSWORD" ]; then
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
