
# Evolution API Installation Guide

This guide outlines the necessary steps to install MongoDB, Redis, Nginx, and the Evolution API. Follow these steps sequentially to set up your environment properly.

## Prerequisites

- Ensure your system is up to date.
- Ubuntu 22.0 or above
- Must login with user root
- Make sure `wget` is installed before proceeding with the installations.

## Installation Steps

### 1. Install MongoDB

#### 1.1 Download and run the MongoDB installation script

```bash
wget https://raw.githubusercontent.com/drhema/evolution-api-installation/main/1-mongo_install.sh && chmod +x 1-mongo_install.sh && ./1-mongo_install.sh
```
```bash
mongosh "mongodb://localhost:27017"
```

```bash
use api_db
db.createUser({
  user: "api_user",
  pwd: "ApiPassw0rd!2024",  // Use the intended password
  roles: [{role: "readWrite", db: "api_db"}]
})
```

```bash
Exit
```

```bash
mongosh 'mongodb://api_user:ApiPassw0rd!2024@localhost:27017/api_db'
```


#### 1.2 Check the status of MongoDB

Ensure MongoDB is running:

```bash
sudo systemctl status mongod
```

If MongoDB is not running, start it:

```bash
sudo systemctl start mongod
```

Verify MongoDB is listening on port 27017:

```bash
sudo ss -tulwn | grep 27017
```


### 2. Install Redis

Download and execute the Redis installation script:

```bash
wget https://raw.githubusercontent.com/drhema/evolution-api-installation/main/2-redis.sh && chmod +x 2-redis.sh && ./2-redis.sh
```

### 3. Check Redis Connection

Ensure that Redis is installed and operating correctly:

```bash
wget https://raw.githubusercontent.com/drhema/evolution-api-installation/main/3-redis_check.sh && chmod +x 3-redis_check.sh && ./3-redis_check.sh
```

### 4. Install Nginx

Install Nginx and configure SSL with Let's Encrypt: insert your subdomain ex: api.yourdomain.com & your email address email@yourdomain.com

```bash
wget https://raw.githubusercontent.com/drhema/evolution-api-installation/main/4-nginx.sh && chmod +x 4-nginx.sh && ./4-nginx.sh
```

### 5. Install Evolution API

Set up the Evolution API along with its dependencies:

```bash
wget https://raw.githubusercontent.com/drhema/evolution-api-installation/main/5-EvolutionAPI.sh && chmod +x 5-EvolutionAPI.sh && ./5-EvolutionAPI.sh
```

Edit https and port 443:
```bash
nano src/env.yml
```

Edit http ===> https
Port 8080 ===> 443

Navigate to the evolution-api directory and restart Nginx:

```bash
cd evolution-api
sudo systemctl restart nginx
```

To start the Evolution API in production mode:

```bash
screen
```

```bash
npm run start:prod
```

Detach from the screen session by pressing `Ctrl+A` followed by `D`.

---

access the API via
https://sub.domain.com/manager
insert your password or if u used the default
```bash
B6D711FCDE4D4FD5936544120E713976
```

modify src/env.yml
```bash
nano src/env.yml
```
```bash
sudo lsof -i :8080
sudo lsof -i :443
sudo kill -9 17496
```
sudo nginx -t

for any support contact: me@ibrahim.agency
