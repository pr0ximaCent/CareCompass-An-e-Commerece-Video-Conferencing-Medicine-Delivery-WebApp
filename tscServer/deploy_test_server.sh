#!/bin/bash
#https://www.cyberciti.biz/faq/unix-linux-execute-command-using-ssh/
pnpm exec tsc;
tar -czvf dist.tar.gz dist package.json test.config.js;
scp dist.tar.gz vector_vm:~/cuet_project/ && rm dist.tar.gz;
#pnpm install validator multer
# run commands on remote server
ssh vector_vm << EOF
  cd ~/cuet_project;
  rm -rf dist;
  tar -xzvf dist.tar.gz;
  rm dist.tar.gz;
  pnpm install;
  pm2 restart test.config.js;
EOF
#if which node >/dev/null 2>&1; then
#  echo "Node.js is installed, skipping..."
#else
#  echo "Installing Node.js..."
#  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/nodesource-archive-keyring.gpg
#  echo "deb [signed-by=/usr/share/keyrings/nodesource-archive-keyring.gpg] https://deb.nodesource.com/node_18.x $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/nodesource.list
#  sudo apt update
#  sudo apt install -y nodejs
#  sudo npm install -g pm2 yarn
#fi
#
## Install Python3
#if which python3 >/dev/null 2>&1; then
#  echo "Python3 is installed, skipping..."
#else
#  echo "Installing Python3..."
#  sudo apt update
#  sudo apt install -y python3 python3-pip
#fi