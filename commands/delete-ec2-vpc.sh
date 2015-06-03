#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> vpc deletion'

if [ $# -lt 1 ]
then
    echo '>>> missig arguments'
    exit
fi

VPC_CIDR=$1
echo '>>> deleting vpc' $VPC_CIDR

# http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-vpcs.html
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[?CidrBlock=='$VPC_CIDR'].[VpcId][0][0]" --output text)
echo '>>>' $VPC_ID 'vpc found'

if [ "$VPC_ID" == "None" ]
then
    echo '>>>' $VPC_CIDR 'vpc already deleted'
else

    # TODO this script only works with one attachment only between gateway and vpc
    # http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-internet-gateways.html
    IGW_ID=$(aws ec2 describe-internet-gateways --query "InternetGateways[].{ InternetGatewayId: InternetGatewayId, VpcId: Attachments[0].VpcId } | [?VpcId=='$VPC_ID'].[InternetGatewayId][0][0]" --output text)

    if [ "$IGW_ID" == "None" ]
    then
        echo '>>>' $VPC_CIDR 'has no internet gateway'
    else

        echo '>>>' $IGW_ID 'internet gateway found'

        # http://docs.aws.amazon.com/cli/latest/reference/ec2/detach-internet-gateway.html
        aws ec2 detach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"
        echo '>>>' $IGW_ID 'internet gateway detached'

        # http://docs.aws.amazon.com/cli/latest/reference/ec2/delete-internet-gateway.html
        aws ec2 delete-internet-gateway --internet-gateway-id "$IGW_ID"
        echo '>>>' $IGW_ID 'internet gateway deleted'

    fi

    # TODO we need a waiter here
    sleep 1

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-subnets.html
    VPC_SUBNETS=$(aws ec2 describe-subnets --query "Subnets[?VpcId=='$VPC_ID'].[SubnetId][]" --output text)
    echo '>>>' $VPC_SUBNETS 'subnets found'

    for SUBNET_ID in $VPC_SUBNETS
    do
        echo '>>> deleting' $SUBNET_ID
        # http://docs.aws.amazon.com/cli/latest/reference/ec2/delete-subnet.html
        aws ec2 delete-subnet --subnet-id "$SUBNET_ID"
    done
    echo '>>>' $VPC_SUBNETS 'subnets deleted'

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/delete-vpc.html
    aws ec2 delete-vpc --vpc-id "$VPC_ID"
    echo '>>>' $VPC_CIDR 'vpc deleted'
fi


