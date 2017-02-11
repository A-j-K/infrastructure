#!/bin/bash

echo '==> Installing Ansible and Git'
sudo apt-get install -y software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get -y update
sudo apt-get install -y ansible git

echo '==> provisioning with Ansible'
sudo ansible-playbook playbooks/setup.yml 

