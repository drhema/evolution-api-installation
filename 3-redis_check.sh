#!/bin/bash

# Automatically determine the Redis server IP address
REDIS_SERVER_IP=$(hostname -I | awk '{print $1}')
REDIS_PASSWORD="your_redis_password" # Leave this empty if no password is set: REDIS_PASSWORD=""

# Function to test Redis connectivity and operations
test_redis() {
    echo "Trying to connect to Redis server at $REDIS_SERVER_IP..."

    # If a password is required, use the -a option to authenticate
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
