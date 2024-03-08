# Evolution API Installation Guide

This guide outlines the steps to install MongoDB, Redis, Nginx, and the Evolution API. Follow these steps sequentially to set up your environment.

## Prerequisites

Ensure your system is up to date and has `wget` installed before proceeding with the installations.

## 1. Install MongoDB

Download and run the MongoDB installation script:

```bash
wget https://raw.githubusercontent.com/drhema/evolution-api-installation/main/1-mongo.sh && chmod +x 1-mongo.sh && ./1-mongo.sh

### 1.1. Check the status of MongoDB and ensure it is running:

```bash
sudo systemctl status mongod
Start MongoDB if it's not already running:

```bash
sudo systemctl start mongod
Verify MongoDB is listening on port 27017:

```bash
sudo ss -tulwn | grep 27017
If necessary, repair MongoDB:

```bash
mongod --repair --dbpath /var/lib/mongodb
2. Install Redis
Execute the Redis installation script:

```bash
wget https://raw.githubusercontent.com/drhema/evolution-api-installation/main/2-redis.sh && chmod +x 2-redis.sh && ./2-redis.sh
3. Check Redis Connection
Ensure that Redis is installed and operating correctly:

```bash
wget https://raw.githubusercontent.com/drhema/evolution-api-installation/main/3-redis_check.sh && chmod +x 3-redis_check.sh && ./3-redis_check.sh
4. Install Nginx
Install Nginx and configure SSL with Let's Encrypt:

```bash
wget https://raw.githubusercontent.com/drhema/evolution-api-installation/main/4-nginx.sh && chmod +x 4-nginx.sh && ./4-nginx.sh
5. Install Evolution API
Finally, set up the Evolution API along with its dependencies:

```bash
wget https://raw.githubusercontent.com/drhema/evolution-api-installation/main/5-EvolutionAPI.sh && chmod +x 5-EvolutionAPI.sh && ./5-EvolutionAPI.sh
Navigate to the evolution-api directory and restart Nginx:

```bash
cd evolution-api
sudo systemctl restart nginx
To start the Evolution API in production mode:

```bash
screen
npm run start:prod
Detach from the screen session by pressing Ctrl+A followed by D.

```bash

Copy the entire block above into your GitHub repository as a `README.md` file to provide a comprehensive installation guide for users.
