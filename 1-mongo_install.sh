
#!/bin/bash

# Update system's package list
sudo apt-get update

# Install necessary packages
sudo apt-get install -y libcurl4 libgssapi-krb5-2 libwrap0 libsasl2-2 libsasl2-modules libsasl2-modules-gssapi-mit openssl liblzma5

# Allow MongoDB port through the firewall
sudo ufw allow 27017/tcp

# Add MongoDB's GPG key
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-archive-keyring.gpg

# Add MongoDB repository
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg ] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Appending the specific repository version for 'jammy'
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-archive-keyring.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee -a /etc/apt/sources.list.d/mongodb-org-7.0.list

# Update package list again and install MongoDB
sudo apt-get update
sudo apt-get install -y mongodb-org

# Start and enable MongoDB service
sudo systemctl start mongod
sudo systemctl enable mongod


# Prepare MongoDB data directory and log file
sudo chown -R mongodb:mongodb /var/lib/mongodb
sudo chown mongodb:mongodb /var/log/mongodb/mongod.log

 Install Mongo Shell
sudo apt-get install -y mongosh

# Download and install the specified version of Mongo Shell
wget https://downloads.mongodb.com/compass/mongosh-2.1.5-linux-x64.tgz -O mongosh.tgz
tar -zxvf mongosh.tgz
sudo mv mongosh-2.1.5-linux-x64/bin/mongosh /usr/local/bin/

# Modify MongoDB configuration
sed -i '/^net:/,/^  bindIp:/s/^  port: 27017/  port: 27018/' /etc/mongod.conf
sed -i '/^net:/,/^  bindIp:/s/^  bindIp: 127.0.0.1/  bindIp: 0.0.0.0/' /etc/mongod.conf

# Restart MongoDB on new port and with new IP binding
mongod --port 27018 --dbpath /var/lib/mongodb --auth --logpath /var/log/mongodb/mongod.log &

# Check Mongo Shell version
mongosh --version

# Connect to Mongo Shell and create user
mongosh --port 27018 <<EOF
use api_db
db.createUser({
  user: "api_user",
  pwd: "ApiPassw0rd!2024",
  roles: [{ role: "readWrite", db: "api_db" }]
})
exit
EOF

# Revert MongoDB port and IP binding to original
sed -i '/^net:/,/^  bindIp:/s/^  port: 27018/  port: 27017/' /etc/mongod.conf

echo "Please manually run the user creation mongosh command to test the connection."

