
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
#aws ec2 associate-address --region $REGION --instance-id $INSTANCE_ID --allocation-id 

GITHUB_USER="${github_user}"
if [[ ! -z $GITHUB_USER ]]; then
	echo "Adding authorized_keys from $GITHUB_USER"
	curl -sSL $GITHUB_USER >> /home/ubuntu/.ssh/authorized_keys
else
	echo "No github_user specified to add"
fi

