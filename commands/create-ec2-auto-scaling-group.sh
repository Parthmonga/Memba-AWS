#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> auto scaling group creation'

if [ $# -lt 7 ]
then
    echo '>>> missig arguments'
    exit
fi

VPC_CIDR=$1
ELB_NAME=$2
LC_NAME=$3
AS_NAME=$4
AS_MIN=$5
AS_MAX=$6
AS_DESIRED=$7

# http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-vpcs.html
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[?CidrBlock==`$VPC_CIDR`].[VpcId][0][0]" --output text)
echo '>>>' $VPC_ID 'vpc found'

if [ "$VPC_ID" == "None" ]
then
    echo '>>>' $VPC_CIDR 'vpc missing'
else

    # http://docs.aws.amazon.com/cli/latest/reference/autoscaling/describe-auto-scaling-groups.html
    AS_FOUND=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$AS_NAME" --query "AutoScalingGroups[0].AutoScalingGroupName" --output text)
    echo '>>>' $AS_FOUND 'auto scaling group found'

    if [ "$AS_FOUND" == "None" ]
    then

        # http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-subnets.html
        VPC_SUBNETS=$(aws ec2 describe-subnets --query "Subnets[?VpcId==`$VPC_ID`].[SubnetId][]" --output text)
        # replace tabs with commas
        VPC_SUBNETS=${VPC_SUBNETS//[$'\t']/,}
        echo '>>>' $VPC_SUBNETS 'subnets found'

        # http://docs.aws.amazon.com/cli/latest/reference/autoscaling/create-auto-scaling-group.html
        aws autoscaling create-auto-scaling-group --auto-scaling-group-name "$AS_NAME" --launch-configuration-name "$LC_NAME" --load-balancer-names "$ELB_NAME" --min-size "$AS_MIN" --max-size "$AS_MAX" --desired-capacity "$AS_DESIRED" --vpc-zone-identifier "$VPC_SUBNETS"

        # http://docs.aws.amazon.com/cli/latest/reference/autoscaling/enable-metrics-collection.html
        aws autoscaling enable-metrics-collection --auto-scaling-group-name "$AS_NAME" --granularity "1Minute"

        # TODO add scaling policies
        # TODO add tags

        echo '>>>' $AS_NAME 'auto scaling group created'

    else
        echo '>>>' $AS_NAME 'auto scaling group already exists'
    fi

fi