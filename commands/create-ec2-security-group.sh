#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> security group creation'

if [ $# -lt 3 ]
then
    echo '>>> missig arguments'
    exit
fi

VPC_CIDR=$1
SG_NAME=$2
SG_DESCRIPTION=$3
SG_PORTS=$4

# http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-vpcs.html
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[?CidrBlock==`$VPC_CIDR`].[VpcId][0][0]" --output text)
echo '>>>' $VPC_ID 'vpc found'

if [ "$VPC_ID" == "None" ]
then
    echo '>>>' $VPC_CIDR 'vpc missing'
else

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html
    SG_ID=$(aws ec2 describe-security-groups --query "SecurityGroups[?VpcId==`$VPC_ID`]|[?GroupName==`$SG_NAME`].[GroupId][0][0]" --output text)
    echo '>>>' $SG_ID 'security group found'

    if [ "$SG_ID" == "None" ]
    then

        # http://docs.aws.amazon.com/cli/latest/reference/ec2/create-security-group.html
        SG_ID=$(aws ec2 create-security-group --group-name "$SG_NAME" --description "$SG_DESCRIPTION" --vpc-id "$VPC_ID" --query="GroupId" --output text)
        echo '>>>' $SG_ID 'security group created'

        for PORT in $SG_PORTS
        do
            # TODO change --cidr IP range on SSH port 22
            # http://docs.aws.amazon.com/cli/latest/reference/ec2/authorize-security-group-ingress.html
            aws ec2 authorize-security-group-ingress --group-id "$SG_ID" --protocol tcp --port "$PORT" --cidr '0.0.0.0/0'
            echo '>>>' $SG_NAME 'security group authorized on port' $PORT
        done

    else
        echo '>>>' $SG_NAME 'security group already exists'
    fi

fi





