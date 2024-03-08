#!/bin/bash

# Updating and Installing Deendencies
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

# Automatically enabling security and authorization if not already set
if ! grep -q "authorization: enabled" /etc/mongod.conf; then
    if grep -q "^security:" /etc/mongod.conf; then
        sudo sed -i '/^security:/a \  authorization: enabled' /etc/mongod.conf
    else
        echo -e "security:\n  authorization: enabled" | sudo tee -a /etc/mongod.conf
    fi
fi

# Starting MongoDB Service
sudo systemctl start mongod

# Checking if MongoDB is running and listening on port 27017
if sudo ss -tulwn | grep 27017; then
    echo "MongoDB is running and listening on port 27017."
else
    echo "MongoDB failed to start or is not listening on port 27017. Please check the service status and configuration."
    exit 1
fi

# Installing MongoDB Shell (mongosh)
wget https://downloads.mongodb.com/compass/mongosh-2.1.5-linux-x64.tgz -O mongosh.tgz
tar -zxvf mongosh.tgz
sudo mv mongosh-2.1.5-linux-x64/bin/mongosh /usr/local/bin/

# Restarting MongoDB service to apply security settings
sudo systemctl restart mongod

# Prompt for Database Name, User, and Password
echo "Enter the name of the MongoDB database:"
read dbname
echo "Enter the MongoDB username:"
read username
echo "Enter the password for the MongoDB user:"
read -s password

# Create MongoDB User
mongosh <<EOF
use $dbname
db.createUser({user: "$username", pwd: "$password", roles:["readWrite"]})
EOF

echo "MongoDB installation and user setup complete."
