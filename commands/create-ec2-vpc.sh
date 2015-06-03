#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> vpc creation'

if [ $# -lt 4 ]
then
    echo '>>> missig arguments'
    exit
fi

VPC_CIDR=$1
NET1_CIDR=$2
NET2_CIDR=$3
NET3_CIDR=$4
echo '>>> creating vpc' $VPC_CIDR 'with subnets' $NET1_CIDR $NET2_CIDR $NET3_CIDR

# http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-vpcs.html
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[?CidrBlock=='$VPC_CIDR'].[VpcId][0][0]" --output text)
echo '>>>' $VPC_ID 'vpc found'

if [ "$VPC_ID" == "None" ]
then

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/create-vpc.html
    VPC_ID=$(aws ec2 create-vpc --cidr-block "$VPC_CIDR" --query "Vpc.VpcId" --output text)
    echo '>>>' $VPC_ID 'vpc created'

    # TODO consider http://docs.aws.amazon.com/cli/latest/reference/ec2/wait/vpc-available.html

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/modify-vpc-attribute.html
    # TODO: maybe we should comment this in production................
    aws ec2  modify-vpc-attribute --vpc-id "$VPC_ID" --enable-dns-hostnames "{\"Value\":true}"
    echo '>>> dns hostnames enabled on' $VPC_ID

    # http://docs.aws.amazon.com/cli/latest/reference/configure/get.html
    REGION=$(aws configure get region --output text)

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/create-subnet.html
    SUBNET_ID1=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "$NET1_CIDR" --availability-zone "$REGION""a" --query "Subnet.SubnetId" --output text)
    SUBNET_ID2=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "$NET2_CIDR" --availability-zone "$REGION""b" --query "Subnet.SubnetId" --output text)
    SUBNET_ID3=$(aws ec2 create-subnet --vpc-id "$VPC_ID" --cidr-block "$NET3_CIDR" --availability-zone "$REGION""c" --query "Subnet.SubnetId" --output text)
    echo '>>>' $SUBNET_ID1 $SUBNET_ID2 $SUBNET_ID3 'subnets created on' $VPC_ID

    # TODO Check modify auto-assign public IP on subnets (on by default)
    # TODO consider http://docs.aws.amazon.com/cli/latest/reference/ec2/wait/subnet-available.html

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/create-internet-gateway.html
    IGW_ID=$(aws ec2 create-internet-gateway --query="InternetGateway.InternetGatewayId" --output text)
    echo '>>>' $IGW_ID 'internet gateway created'

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/attach-internet-gateway.html
    aws ec2 attach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"
    echo '>>>' $IGW_ID 'internet gateway attached to vpc' $VPC_ID

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-route-tables.html
    RT_ID=$(aws ec2 describe-route-tables --query "RouteTables[?VpcId =='$VPC_ID'].[RouteTableId][0][0]" --output text)
    echo '>>>' $RT_ID 'route table found'

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/create-route.html
    DONE=$(aws ec2 create-route --route-table-id "$RT_ID" --destination-cidr-block "0.0.0.0/0" --gateway-id "$IGW_ID" --query "Return" --output text)
    echo '>>>' $RT_ID 'route table updated'

    # TODO add tags

    echo '>>>' $VPC_CIDR 'vpc and subnets created'

else
    echo '>>>' $VPC_CIDR 'vpc already exists'
fi