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

# Ensure MongoDB data and log directory permissions are correct
sudo chown -R mongodb:mongodb /var/lib/mongodb
sudo chown -R mongodb:mongodb /var/log/mongodb

# Starting MongoDB Service
sudo systemctl restart mongod
echo "MongoDB is being restarted to apply configurations..."

# Installing MongoDB Shell (mongosh)
wget https://downloads.mongodb.com/compass/mongosh-2.1.5-linux-x64.tgz -O mongosh.tgz
tar -zxvf mongosh.tgz
sudo mv mongosh-2.1.5-linux-x64/bin/mongosh /usr/local/bin/

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
if mongosh --host $server_ip --port 27017 <<EOF
use $dbname
db.createUser({user: "$username", pwd: "$password", roles:["readWrite"]})
EOF
then
    echo "MongoDB user created successfully."
else
    echo "Failed to create MongoDB user. Checking MongoDB service status..."
    sudo systemctl status mongod | grep "active (running)" && echo "MongoDB is active and running." || echo "MongoDB service is not running as expected."
    echo "Reviewing the last 20 lines from MongoDB log for errors..."
    sudo tail -n 20 /var/log/mongodb/mongod.log
    exit 1
fi

echo "MongoDB installation and user setup complete."
