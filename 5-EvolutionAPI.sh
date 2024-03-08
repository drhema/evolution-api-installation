#!/bin/bash

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Clone the Evolution API repository
echo "Cloning Evolution API repository..."
git clone https://github.com/EvolutionAPI/evolution-api.git
cd evolution-api

# Update and install dependencies
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y git zip unzip nload snapd curl wget nodejs npm

# Install global npm packages
echo "Installing global npm packages..."
npm install -g npm@latest
npm install -g typescript
npm install -g pm2@latest

# Copy development environment file to production environment file
echo "Setting up environment configuration..."
cp src/dev-env.yml src/env.yml

# Instructions for editing the environment configuration
echo "Please manually edit 'src/env.yml' to configure your environment."
echo "Use any text editor of your choice, for example:"
echo "nano src/env.yml"
echo "After editing, you can start your application."
