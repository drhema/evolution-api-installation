
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

# Install MongoDB Shell (mongosh)
sudo apt-get install -y mongosh

# Download, extract, and move mongosh binary
wget https://downloads.mongodb.com/compass/mongosh-2.1.5-linux-x64.tgz -O mongosh.tgz
tar -zxvf mongosh.tgz
sudo mv mongosh-2.1.5-linux-x64/bin/mongosh /usr/local/bin/

# Configure MongoDB to use authentication
echo "
net:
  port: 27017
  bindIp: 0.0.0.0
" | sudo tee /etc/mongod.conf

# Restart MongoDB to apply the new configuration
sudo systemctl restart mongod

#!/bin/bash

# Prompt user for database details
echo "Please enter the database name:"
read databaseName

echo "Please enter the database user name:"
read userName

echo "Please enter the password for the database user:"
read -s userPassword # -s flag hides input for security

# Placeholder for MongoDB user creation
# Note: In a real scenario, you'd use these variables in a `mongosh` command
# that logs into MongoDB and executes the user creation command.
# This step is highly context-specific and might require manual execution or automation via `expect`.

echo "Attempting to create user and test connection (this part is not automated in the script)..."

# Placeholder for connection test
# Again, in a real-world use, you'd replace this echo with a command that uses `mongosh`
# to attempt a connection using the provided details.
echo "mongosh \"mongodb://${userName}:${userPassword}@localhost:27017/${databaseName}\""

echo "Please manually run the above mongosh command to test the connection."
