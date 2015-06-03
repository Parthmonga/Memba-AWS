#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> load balancer creation'

if [ $# -lt 8 ]
then
    echo '>>> missig arguments'
    exit
fi

VPC_CIDR=$1         #"10.1.0.0/16"
SG_ELB_NAME=$2      #"productionELBSecurityGroup"
ELB_NAME=$3         #"productionLoadBalancer"
ELB_HTTP_PORT=$4    #"80"
ELB_HTTPS_PORT=$5   #"443"
EC2_HTTP_PORT=$6    #"80"
EC2_HTTPS_PORT=$7   #"443"
CERT_NAME=$8        #"kidojuSSLCertificate"

# https://www.memba.com
ELB_HTTP_LISTENER="Protocol=HTTP,LoadBalancerPort="$ELB_HTTP_PORT",InstanceProtocol=HTTP,InstancePort="$EC2_HTTP_PORT
# https://www.kidoju.com
CERT_ID=$(aws iam get-server-certificate --server-certificate-name "kidojuSSLCertificate" --query "ServerCertificate.ServerCertificateMetadata.Arn" --output text)
ELB_HTTPS_LISTENER="Protocol=HTTPS,LoadBalancerPort="$ELB_HTTPS_PORT",InstanceProtocol=HTTP,InstancePort="$EC2_HTTPS_PORT",SSLCertificateId="$CERT_ID

# http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-vpcs.html
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[?CidrBlock==`$VPC_CIDR`].[VpcId][0][0]" --output text)
echo '>>>' $VPC_ID 'vpc found'

if [ "$VPC_ID" == "None" ]
then
    echo '>>>' $VPC_CIDR 'vpc missing'
else

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-subnets.html
    VPC_SUBNETS=$(aws ec2 describe-subnets --query "Subnets[?VpcId==`$VPC_ID`].[SubnetId][]" --output text)
    echo '>>>' $VPC_SUBNETS 'subnets found'

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html
    SG_ID=$(aws ec2 describe-security-groups --query "SecurityGroups[?VpcId==`$VPC_ID`]|[?GroupName==`$SG_ELB_NAME`].[GroupId][0][0]" --output text)

    if [ "$SG_ID" == "None" ]
    then
        echo '>>>' $SG_ELB_NAME 'security group missing'
    else

        # http://docs.aws.amazon.com/cli/latest/reference/elb/describe-load-balancers.html
        ELB_FOUND=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName==`$ELB_NAME`].[LoadBalancerName][0][0]" --output text)
        echo '>>>' $ELB_FOUND 'load balancer found'

        if [ "$ELB_FOUND" == "None" ]
        then

            # http://docs.aws.amazon.com/cli/latest/reference/elb/create-load-balancer.html
            # Note keep $VPC_SUBNETS without quotes otherwise the aws cli sees one concatenated value instead of 3 separated with spaces
            ELB_DNS=$(aws elb create-load-balancer --load-balancer-name "$ELB_NAME" --listeners "$ELB_HTTP_LISTENER" "$ELB_HTTPS_LISTENER" --subnets $VPC_SUBNETS --security-groups "$SG_ID" --query "DNSName" --output text)
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