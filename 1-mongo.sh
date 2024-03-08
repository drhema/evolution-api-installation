#!/bin/bash

# Updating and Installing Dependencies
sudo apt-get update
sudo apt-get install -y libcurl4 libgssapi-krb5-2 libldap-2.5-0 libwrap0 libsasl2-2 libsasl2-modules libsasl2-modules-gssapi-mit openssl liblzma5

# Installing and Configuring UFW
sudo apt-get install -y ufw
sudo ufw enable

# Allowing Necessary Ports
sudo ufw allow 10000/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 6379/tcp
sudo ufw allow 5432/tcp
sudo ufw allow 8025/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 27017/tcp
sudo ufw allow 3306/tcp

# Adding MongoDB Repository
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-archive-keyring.gpg
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Installing MongoDB
sudo apt-get update
sudo apt-get install -y mongodb-org

# Configuring MongoDB to listen on both localhost and all network interfaces
sudo sed -i '/  bindIp:/c\  bindIp: 127.0.0.1,0.0.0.0' /etc/mongod.conf

# Automatically enabling security and authorization
if ! grep -q "security:" /etc/mongod.conf; then
    echo "security:" | sudo tee -a /etc/mongod.conf
    echo "  authorization: enabled" | sudo tee -a /etc/mongod.conf
else
    sudo sed -i '/security:/a\  authorization: enabled' /etc/mongod.conf
fi

# Starting MongoDB Service and waiting for it to fully start
sudo systemctl start mongod
echo "Waiting for MongoDB to start..."
sleep 10  # Wait 10 seconds to ensure MongoDB has started

# Checking MongoDB Service Status
echo "Checking MongoDB service status..."
sudo systemctl status mongod | grep "active (running)" && echo "MongoDB is active and running." || echo "MongoDB service is not running as expected."

# Checking if MongoDB is running and listening on port 27017, with retry logic
retry_count=0
max_retries=5
while ! sudo ss -tulwn | grep 27017; do
    if [ "$retry_count" -eq "$max_retries" ]; then
        echo "MongoDB failed to start or is not listening on port 27017 after several attempts. Please check the service status and configuration."
        exit 1
    fi
    echo "Waiting for MongoDB to listen on port 27017..."
    sleep 5  # Wait 5 more seconds
    ((retry_count++))
done
echo "MongoDB is running and listening on port 27017."

# Installing MongoDB Shell (mongosh)
wget https://downloads.mongodb.com/compass/mongosh-2.1.5-linux-x64.tgz -O mongosh.tgz
tar -zxvf mongosh.tgz
sudo mv mongosh-2.1.5-linux-x64/bin/mongosh /usr/local/bin/

# Restarting MongoDB service to apply security settings
sudo systemctl restart mongod

# Determine the server's primary IP address
server_ip=$(hostname -I | awk '{print $1}')

# Prompt for Database Name, User, and Password
echo "Enter the name of the MongoDB database:"
read dbname
echo "Enter the MongoDB username:"
read username
echo "Enter the password for the MongoDB user:"
read -s password

# Use the server's IP address for the MongoDB connection string in the mongosh command
echo "Attempting to create MongoDB user..."
success=false
for attempt in {1..5}; do
    if mongosh --host $server_ip --port 27017 <<EOF
use $dbname
db.createUser({user: "$username", pwd: "$password", roles:["readWrite"]})
EOF
    then
        success=true
        echo "MongoDB user created successfully."
        break
    else
        echo "Attempt $attempt to create MongoDB user failed. Retrying in 5 seconds..."
        sleep 5
    fi
done

if [ "$success" != true ]; then
    echo "Failed to create MongoDB user after several attempts."
fi

echo "MongoDB installation and user setup complete."
