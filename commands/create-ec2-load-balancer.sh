#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> load balancer creation'

if [ $# -lt 3 ]
then
    echo '>>> missig arguments'
    exit
fi

VPC_CIDR=$1
SG_NAME=$2
ELB_NAME=$3

# http://docs.aws.amazon.com/cli/latest/reference/elb/describe-load-balancers.html
# aws elb describe-load-balancers

ELB_HTTP_LISTENER="Protocol=HTTP,LoadBalancerPort=80,InstanceProtocol=HTTP,InstancePort=80"
ELB_HTTPS_LISTENER="Protocol=HTTPS,LoadBalancerPort=443,InstanceProtocol=HTTP,InstancePort=443"

# http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-vpcs.html
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[?CidrBlock=='$VPC_CIDR'].[VpcId][0][0]" --output text)
echo '>>>' $VPC_ID 'vpc found'

if [ "$VPC_ID" == "None" ]
then
    echo '>>>' $VPC_CIDR 'vpc missing'
else

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-subnets.html
    VPC_SUBNETS=$(aws ec2 describe-subnets --query "Subnets[?VpcId=='$VPC_ID'].[SubnetId][]" --output text)
    echo '>>>' $VPC_SUBNETS 'subnets found'

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html
    SG_ID=$(aws ec2 describe-security-groups --query "SecurityGroups[?VpcId=='$VPC_ID']|[?GroupName=='$SG_NAME'].[GroupId][0][0]" --output text)

    if [ "$SG_ID" == "None" ]
    then
        echo '>>>' $SG_NAME 'security group missing'
    else

        # http://docs.aws.amazon.com/cli/latest/reference/elb/describe-load-balancers.html
        ELB_FOUND=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$ELB_NAME'].[LoadBalancerName][0][0]" --output text)
        echo '>>>' $ELB_FOUND 'load balancer found'

        if [ "$ELB_FOUND" == "None" ]
        then

            # http://docs.aws.amazon.com/cli/latest/reference/elb/create-load-balancer.html
            # Note keep $VPC_SUBNETS without quotes otherwise the aws cli sees one concatenated value instead of 3 separated with spaces
            ELB_DNS=$(aws elb create-load-balancer --load-balancer-name "$ELB_NAME" --listeners "$ELB_HTTP_LISTENER" --subnets $VPC_SUBNETS --security-groups "$SG_ID" --query "DNSName" --output text)
            echo '>>>' $ELB_DNS 'load balancer created'

            # TODO Add access logs

            # http://docs.aws.amazon.com/cli/latest/reference/elb/create-load-balancer-listeners.html
            # TODO: the following won't work without an SSL certificate
            # aws elb create-load-balancer-listeners --load-balancer-name "$ELB_NAME" --listeners "$ELB_HTTPS_LISTENER"
            # TODO http://docs.aws.amazon.com/cli/latest/reference/elb/set-load-balancer-listener-ssl-certificate.html

        else
            echo '>>>' $ELB_NAME 'load balancer already exists'
        fi
    fi

fi