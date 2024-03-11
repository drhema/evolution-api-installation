#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# 1. Install Docker Compose
echo "Updating and installing Docker..."
sudo apt update && sudo apt upgrade -y
sudo apt-get remove docker docker-engine docker.io containerd runc -y
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release -y
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo ufw allow 8080/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 6379/tcp
sudo ufw allow 5432/tcp
# Wait 5 seconds
echo "Waiting for 5 seconds..."
sleep 5

# 2. Setup Evolution API environment
echo "Cloning Evolution API repository and setting up the environment..."
git clone https://github.com/EvolutionAPI/evolution-api.git
cd evolution-api
sudo apt install npm -y
npm install -g typescript
sudo apt-get install -y nodejs
npm install -g npm@latest
npm install -g pm2@latest
sudo apt-get install -y git zip unzip nload snapd curl wget
cp src/dev-env.yml src/env.yml

# Wait 3 seconds
echo "Waiting for 3 seconds..."
sleep 3

# 3. Configuration prompts
read -p "Enter your subdomain: " sub_domain
# MongoDB details (using defaults for simplicity, modify as needed)
read -p "MongoDB details (Press Enter to use defaults): "
read -p "Database name (Press Enter to use db_mongo): " db_mongo
read -p "Database user (Press Enter to use db_mongo_user): " db_mongo_user
read -p "Database password (Press Enter to use mongo_db_pass): " mongo_db_pass
# Server IP prompt
server_ip=$(hostname -I | awk '{print $1}')
echo "Current server IP is $server_ip. Is this correct? (y/n): "
read server_ip_correct
if [ "$server_ip_correct" != "y" ]; then
    read -p "Enter the correct server IP: " server_ip
fi
read -p "Enter Redis password: " redis_pass
api_key="B6D711FCDE4D4FD5936544120E713976"
read -p "API Key is $api_key. Do you want to change it? (y/n): " change_api_key
if [ "$change_api_key" == "y" ]; then
    read -p "Enter a new API Key (at least 12 letters): " api_key
fi

# Apply configurations to src/env.yml
echo "Applying configurations..."
sudo sed -i "s|URL: localhost|URL: http://$sub_domain|" src/env.yml
sudo sed -i "s|# - yourdomain.com|- \"$sub_domain\"|" src/env.yml
# Update server TYPE and PORT in config.yml
sudo sed -i "/SERVER:/,/URL:/s|TYPE: http|TYPE: https|" config.yml
sudo sed -i "/SERVER:/,/URL:/s|PORT: 8080 # 443|PORT: 443 # 443|" config.yml
sudo sed -i "s|/etc/letsencrypt/live/<domain>/privkey.pem|/etc/letsencrypt/live/$sub_domain/privkey.pem|" src/env.yml
sudo sed -i "s|/etc/letsencrypt/live/<domain>/fullchain.pem|/etc/letsencrypt/live/$sub_domain/fullchain.pem|" src/env.yml
sudo sed -i "s|mongodb://root:root@localhost:27017/?authSource=admin&readPreference=primary&ssl=false&directConnection=true|mongodb://$db_mongo_user:$mongo_db_pass@$server_ip:27017/$db_mongo?authSource=admin&readPreference=primary&ssl=false&directConnection=true|" src/env.yml
sudo sed -i "s|redis://localhost:6379|redis://$redis_pass@$server_ip:6379|" src/env.yml
sudo sed -i "s|KEY: B6D711FCDE4D4FD5936544120E713976|KEY: $api_key|" src/env.yml

# Wait 5 seconds before the final setup
echo "Waiting for 5 seconds..."
sleep 2

echo "Finalizing setup..."
# Kill processes on port 8080
sudo lsof -i :8080 | awk 'NR!=1 {print $2}' | xargs -r sudo kill -9
# Kill processes on port 443
sudo lsof -i :443 | awk 'NR!=1 {print $2}' | xargs -r sudo kill -9
sudo apt update && sudo apt -y upgrade
sudo systemctl reload nginx
nginx -t && systemctl restart nginx
# npm and build the application
npm install
npm run build

echo "Setup completed. Navigate to the evolution-api directory to start your application. write cd evolution-api then write screen then npm run start:prod"
