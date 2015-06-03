#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> security group deletion'

if [ $# -lt 2 ]
then
    echo '>>> missig arguments'
    exit
fi

VPC_CIDR=$1
SG_NAME=$2

# http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-vpcs.html
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[?CidrBlock==`$VPC_CIDR`].[VpcId][0][0]" --output text)
echo '>>>' $VPC_ID 'vpc found'

if [ "$VPC_ID" == "None" ]
then
    echo '>>>' $VPC_CIDR 'vpc missing'
    echo '>>>' $SG_NAME 'security group already deleted'
else

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html
    SG_ID=$(aws ec2 describe-security-groups --query "SecurityGroups[?VpcId==`$VPC_ID`]|[?GroupName==`$SG_NAME`].[GroupId][0][0]" --output text)
    echo '>>>' $SG_ID 'security group found'

    if [ "$SG_ID" == "None" ]
    then
        echo '>>>' $SG_NAME 'security group already deleted'
    else

        # http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html
        SG_PORTS=$(aws ec2 describe-security-groups --query="SecurityGroups[?VpcId==`$VPC_ID`]|[?GroupName==`$SG_NAME`].IpPermissions[].FromPort" --output text)

        for PORT in $SG_PORTS
        do
            # TODO change --cidr IP range on SSH port 22
            # http://docs.aws.amazon.com/cli/latest/reference/ec2/revoke-security-group-ingress.html
            aws ec2 revoke-security-group-ingress --group-id "$SG_ID" --protocol tcp --port "$PORT" --cidr '0.0.0.0/0'
            echo '>>>' $SG_NAME 'security group revoked on port' $PORT
        done

        # A client error (DependencyViolation) occurred when calling the DeleteSecurityGroup operation: resource sg-cc6041a9 has a dependent object
        sleep 10

        # http://docs.aws.amazon.com/cli/latest/reference/ec2/delete-security-group.html
        aws ec2 delete-security-group --group-id "$SG_ID"
        echo '>>>' $SG_NAME 'security group deleted'
    fi

fi