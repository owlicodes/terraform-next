#!/bin/bash
# Replace these with your actual instance IPs
INSTANCE1_IP="<First Instance IP>"
INSTANCE2_IP="<Second Instance IP>"
KEY_PATH="~/.ssh/nextjs-deployer"

for IP in $INSTANCE1_IP $INSTANCE2_IP
do
    echo "Deploying to $IP..."
    
    # Create the app directory
    ssh -i $KEY_PATH ec2-user@$IP "mkdir -p ~/todo-application"
    
    # Copy package.json, package-lock.json, and .next folder
    scp -i $KEY_PATH package*.json ec2-user@$IP:~/todo-application/
    scp -i $KEY_PATH -r .next ec2-user@$IP:~/todo-application/
    scp -i $KEY_PATH -r public ec2-user@$IP:~/todo-application/
    
    # Install dependencies and start the app
    ssh -i $KEY_PATH ec2-user@$IP "cd ~/todo-application && npm install && pm2 delete todo-application || true && PORT=3000 pm2 start npm --name 'todo-application' -- start"
done