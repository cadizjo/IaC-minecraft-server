#!/bin/bash

# Navigate to the Terraform directory and install the necessary providers
cd terraform-scripts
terraform init

# Format and validate the EC2 configuration file
terraform fmt 
terraform validate

# Apply the EC2 instance configurations specified in main.tf
terraform apply -auto-approve

# Extract the public IP and private key associated with the newly created EC2 instance
INSTANCE_IP=$(terraform output -raw instance_public_ip)
PRIVATE_KEY_PEM=$(terraform output -raw private_key_pem)

# Save the private key to a file and set permissions
echo "$PRIVATE_KEY_PEM" > ../ansible-scripts/minecraft_key.pem
chmod 400 ../ansible-scripts/minecraft_key.pem

# Update Ansible inventory with the new instance public IP
echo "[minecraft]" > ../ansible-scripts/inventory.ini
echo "$INSTANCE_IP ansible_user=ec2-user ansible_ssh_private_key_file=minecraft_key.pem" >> ../ansible-scripts/inventory.ini

# Wait for the instance to initialize (add a delay to ensure SSH is available)
sleep 100  

# Run Ansible playbook on inventory nodes specified (EC2 instance)
cd ../ansible-scripts
ansible-playbook -i inventory.ini playbook.yml

# Print Minecraft Server's Public IP address
echo "Minecraft Server IP address: $INSTANCE_IP"