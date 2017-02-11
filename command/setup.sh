#!/bin/bash

echo '==> Installing Ansible and Git'
sudo apt-get install -y software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get -y update
sudo apt-get install -y ansible git

ssh-keygen -t rsa -N "" -f ~/.ssh/aws-sdk-cpp-key
if [[ -e ~/.ssh/aws-sdk-cpp-key.pub ]]; then
	cp ~/.ssh/aws-sdk-cpp-key.pub ../ami/docker-host/files/aws-sdk-cpp-key.pub
fi

echo '==> provisioning with Ansible'
sudo ansible-playbook playbooks/setup.yml 

