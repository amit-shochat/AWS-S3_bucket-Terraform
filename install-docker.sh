#!/bin/bash
sudo yum update -y && sudo yum upgrade -y
sudo yum install -y bash-completion bash-completion-extras
locate bash_completion.sh
source /etc/profile.d/bash_completion.sh
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker 
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker centos 
sudo docker pull amitshochat66/klika-project:im_alive_bash
sudo docker images | awk 'NR > 1 {print $3}'
sudo docker run -d -e AliveTime=2 $(sudo docker images | awk 'NR > 1 {print $3}')
sudo docker ps -a