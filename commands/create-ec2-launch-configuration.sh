#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> launch configuration creation'

if [ $# -lt 7 ]
then
    echo '>>> missig arguments'
    exit
fi

VPC_CIDR=$1
SG_NAME=$2
LC_NAME=$3
LC_AMI_ID=$4
LC_INST_TYPE=$5
LC_KEY_PAIR=$6
LC_USER_DATA=$7
ECS_INSTANCE_ROLE="ecsInstanceRole"

# http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-vpcs.html
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[?CidrBlock=='$VPC_CIDR'].[VpcId][0][0]" --output text)
echo '>>>' $VPC_ID 'vpc found'

if [ "$VPC_ID" == "None" ]
then
    echo '>>>' $VPC_CIDR 'vpc missing'
else

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html
    SG_ID=$(aws ec2 describe-security-groups --query "SecurityGroups[?VpcId=='$VPC_ID']|[?GroupName=='$SG_NAME'].[GroupId][0][0]" --output text)
    echo '>>>' $SG_ID 'security group found'

    if [ "$SG_ID" == "None" ]
    then
        echo '>>>' $SG_NAME 'security group missing'
    else

        # http://docs.aws.amazon.com/cli/latest/reference/autoscaling/describe-launch-configurations.html
        LC_FOUND=$(aws autoscaling describe-launch-configurations --launch-configuration-names "$LC_NAME" --query "LaunchConfigurations[0].LaunchConfigurationName" --output text)
        echo '>>>' $LC_FOUND 'launch configuration found'

        if [ "$LC_FOUND" == "None" ]
        then
            # http://docs.aws.amazon.com/cli/latest/reference/autoscaling/create-launch-configuration.html
            # TODO Without Administrator privileges we get --> A client error (AccessDenied) occurred when calling the CreateLaunchConfiguration operation: User: arn:aws:iam::215711614536:user/syscmdline is not authorized to perform: iam:PassRole on resource: arn:aws:iam::215711614536:role/ecsInstanceRole
            # Fix http://docs.aws.amazon.com/IAM/latest/UserGuide/roles-usingrole-ec2instance.html
            aws autoscaling create-launch-configuration --launch-configuration-name "$LC_NAME" --image-id "$LC_AMI_ID" --instance-type "$LC_INST_TYPE" --key-name "$LC_KEY_PAIR" --security-groups "$SG_ID" --iam-instance-profile "$ECS_INSTANCE_ROLE" --instance-monitoring Enabled=true --no-ebs-optimized --associate-public-ip-address --user-data "$LC_USER_DATA"
            echo '>>>' $LC_NAME 'launch configuration created'
        else
            echo '>>>' $LC_NAME 'launch configuration already exists'
        fi
    fi

fi