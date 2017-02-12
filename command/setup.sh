#!/bin/bash

echo '==> Installing Ansible and Git'
sudo apt-get -y update
sudo apt-get install -y software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get -y update

ENV DEPS \
	ansible \
	git \
	curl \
	wget \
	subversion \
	awscli \
	tree \
	jq \
	build-essential \
	apt-utils \
	ca-certificates \
	libssl-dev \
	libcurl4-openssl-dev \
	vim \
	libc-dev \
	file \
	mlocate \
	libxml2 \
	autoconf \
	g++ \
	gcc \
	make

RUN apt-get update && apt-get install -y $DEPS $DEPS_TEMP --no-install-recommends

ssh-keygen -t rsa -N "" -f ~/.ssh/aws-sdk-cpp-key
if [ -e ~/.ssh/aws-sdk-cpp-key.pub ]; then
	cp ~/.ssh/aws-sdk-cpp-key.pub ../ami/docker-host/files/aws-sdk-cpp-key.pub
fi

echo '==> provisioning with Ansible'
sudo ansible-playbook playbooks/setup.yml 

