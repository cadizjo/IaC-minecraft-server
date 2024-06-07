#!/bin/bash

# Navigate to the Terraform directory and install the necessary providers
cd terraform
terraform init

# Format and validate the EC2 configuration file
terraform fmt 
terraform validate

# Apply the EC2 instance configurations specified in main.tf
terraform apply -auto-approve

# Extract the public IP of the newly created EC2 instance
instance_ip=$(terraform output -raw instance_public_ip)

# Retrieve the private key and save it to a file
terraform output -raw private_key_pem > ../ansible/minecraft_key.pem
chmod 400 ../ansible/minecraft_key.pem

# Update the Ansible inventory file with the instance IP
echo "[minecraft]" > ../ansible/inventory.ini
echo "$instance_ip" >> ../ansible/inventory.ini

# Navigate to the Ansible directory and run the playbook against our managed node (the EC2 instance) to configure the minecraft server
cd ../ansible
ansible-playbook -i inventory.ini --private-key minecraft_key.pem playbook.yml