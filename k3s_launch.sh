cd Terraform/ 
terraform init && terraform apply --auto-approve
ip_master=$(terraform output -json instance_ips_master | jq -r '.')
ip_worker=$(terraform output -json instance_ips_worker | jq -r '.')
cd ..
sed -i 's/IP_MASTER/'$ip_master'/g' ansible/Deploy_k3s/inventory.ini
sed -i 's/IP_WORKER/'$ip_worker'/g' ansible/Deploy_k3s/inventory.ini
sed -i 's/###IP_MASTER###/'$ip_master'/g' ansible/Deploy_k3s/k3s-worker/tasks/main.yml
cd ansible/Deploy_k3s/
ansible-playbook -i inventory.ini playbook.yml