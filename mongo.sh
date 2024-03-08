#!/bin/bash

# Updating and Installing Dependencies
sudo apt-get update
sudo apt-get install -y libcurl4 libgssapi-krb5-2 libldap-2.5-0 libwrap0 libsasl2-2 libsasl2-modules libsasl2-modules-gssapi-mit openssl liblzma5

# Installing and Configuring UFW
sudo apt-get install -y ufw
sudo ufw enable
sudo ufw allow 27017/tcp

# Adding MongoDB Repository
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-archive-keyring.gpg
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Installing MongoDB
sudo apt-get update
sudo apt-get install -y mongodb-org

# Starting and Enabling MongoDB Service
sudo systemctl start mongod
sudo systemctl enable mongod

# Installing MongoDB Shell (mongosh)
wget https://downloads.mongodb.com/compass/mongosh-2.1.5-linux-x64.tgz -O mongosh.tgz
tar -zxvf mongosh.tgz
sudo mv mongosh-2.1.5-linux-x64/bin/mongosh /usr/local/bin/

# Configuring MongoDB with Authentication
sudo sed -i '/security:/a\  authorization: enabled' /etc/mongod.conf
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
