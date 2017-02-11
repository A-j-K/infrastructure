#!/bin/bash

export PACKER_LOG=1
export PACKER_LOG_PATH=~/logs/packer.log

declare -A AMIS
if [ "$3" == "trusty" ]; then
	AMIS["eu-west-1"]="ami-98ecb7fe"
	AMIS["eu-central-1"]="ami-3b3af354"
	AMIS["us-west-1"]="ami-62a7fa02"
	AMIS["us-west-2"]="ami-9516adf5"
	AMIS["us-east-1"]="ami-0927dc1f"
	AMIS["ap-northeast-1"]="ami-9fbcfaf8"
	AMIS["ap-southeast-1"]="ami-eaba0e89"
	AMIS["ap-southeast-2"]="ami-e9bfe49a"
	AMIS["sa-east-1"]="ami-7fb6d213"
	AMIS["cn-north-1"]="ami-e6e0378b"
	AMIS["us-gov-west-1"]="ami-34df6755"
	UBUNTU="trusty"
else
	AMIS["eu-west-1"]="ami-98ecb7fe"
	AMIS["eu-central-1"]="ami-2830f947"
	AMIS["us-west-1"]="ami-79df8219"
	AMIS["us-west-2"]="ami-d206bdb2"
	AMIS["us-east-1"]="ami-f0768de6"
	AMIS["ap-northeast-1"]="ami-bbc680dc"
	AMIS["ap-southeast-1"]="ami-83a713e0"
	AMIS["ap-southeast-2"]="ami-943d3bf7"
	AMIS["sa-east-1"]="ami-25b0d449"
	AMIS["cn-north-1"]="ami-a0e136cd"
	AMIS["us-gov-west-1"]="ami-19d56d78"
	UBUNTU="xenial"
fi

usage() {
	echo "The following env vars must be set:-"
	echo "export AWS_ACCESS_KEY=\"***\""
	echo "export AWS_SECRET_KEY=\"***\""
	echo "$0 \"<github-username>\" \"<aws-region>\" \"xenial|trusy\""
	echo 
	echo "  Argument 1: Your github user name"
	echo "  Argument 2: The AWS region to work in"
	echo "  Argument 3: Either xenial or trusy versions of Ubuntu, select one"
	echo
	echo "AWS regions are:-"
	for KEY in "${!AMIS[@]}"; do
		echo "  $KEY"	
	done
	echo
	exit 1
}

if [[ ! -z $1 && $1 == "--help" ]]; then
	echo "Help"
	usage
	exit 0
fi

if [[ $# != 3 ]]; then
	usage
	exit 0
fi

GITUSER=$1
AWS_REGION=$2
HAVE_REGION="no"

for KEY in "${!AMIS[@]}"; do
	if [[ "$KEY" == "$AWS_REGION" ]]; then
		HAVE_REGION="yes"
		AWS_AMI="${AMIS[$KEY]}"
	fi
done

if [[ "$HAVE_REGION" != "yes" ]]; then
	echo 
	echo "*********************************************************"
	echo "   The region you supplied, \"${AWS_REGION}\" was not found."
	echo "*********************************************************"
	echo
	usage
	exit 1
fi

for KEY in "${!AMIS[@]}"; do
	if [[ "$KEY" == "$2" ]]; then
		AWS_AMI="${AMIS[$KEY]}"
	fi
done

if [ -z $AWS_AMI ]; then
	echo 
	echo "*****************************************************************"
	echo "   Error, no AMI found for the region you supplied: \"$AWS_REGION\"."
	echo "*****************************************************************"
	echo
	usage
	exit 1
fi


if [ -z $UBUNTU ] ; then usage && exit 1; fi
if [ -z $AWS_REGION ]; then usage && exit 1; fi
if [ -z $AWS_AMI ]; then usage && exit 1; fi
if [ -z $AWS_SECRET_KEY ]; then usage && exit 1; fi
if [ -z $AWS_ACCESS_KEY ]; then usage && exit 1; fi

export AMI_NAME="${GITUSER}-docker-host-${UBUNTU}-x64-v0-1-0"

if [ ! -d ~/logs ]; then
	mkdir ~/logs
fi

CMD="packer build"
CMD+=" -only=amazon-ebs"
CMD+=" -var ami_name=${AMI_NAME}"
CMD+=" -var aws_region=${AWS_REGION}"
CMD+=" -var aws_ami=${AWS_AMI}"
CMD+=" -var git_user=${GITUSER}"
CMD+=" -var-file=src/ami.json"
CMD+=" ubuntu.json"
$CMD

