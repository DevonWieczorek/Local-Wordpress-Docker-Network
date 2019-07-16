# pull in vars from .env
source .env

# update /etc/hosts with local.finddreamjobs.com
sudo /bin/bash -c "echo \"127.0.0.1 $local_docker_domain\" >> /etc/hosts"
sudo /bin/bash -c "echo \"127.0.0.1 https://$local_docker_domain\" >> /etc/hosts"

echo ""
echo "updated local hosts file to point docker ip to $local_docker_domain"
