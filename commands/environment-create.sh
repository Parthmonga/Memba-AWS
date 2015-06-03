#!/bin/sh
source ~/.bashrc

echo '============================================================'
echo '>>> create deployment evironment'

if [ $# -lt 5 ]
then
    echo '>>> missig arguments'
    exit
fi

ENVIRONMENT=$1
VPC_CIDR=$2
NET1_CIDR=$3
NET2_CIDR=$4
NET3_CIDR=$5

# Check region
# http://docs.aws.amazon.com/cli/latest/reference/configure/get.html
RG_VALUE=$(aws configure get region --output text)
if [ "$RG_VALUE" == "eu-west-1" ]
then
    RG_NAME="Ireland"
    # http://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_container_instance.html
    # LC_AMI_ID="ami-ed7c149a"
    LC_AMI_ID="ami-b3543cc4" # ECS-Optimized Amason Linux AMI 2015.03b for eu-west-1 region
elif [ "$RG_VALUE" == "us-east-1" ]
then
    RG_NAME="Virginia"
    LC_AMI_ID="ami-d0b9acb8" # ECS-Optimized Amason Linux AMI 2015.03b for us-east-1 region
else
    echo '>>>' $RG_VALUE 'not handled in ./commands/environment-create.sh'
    exit
fi

# Check users and groups

# Check roles

# Check key pair
KP_NAME=$ENVIRONMENT$RG_NAME"KeyPair"
./commands/check-ec2-key-pair.sh "$KP_NAME"

# Check certificate
CERT_NAME="kidojuSSLCertificate"
CERT_CN="www.kidoju.com"
./commands/check-iam-certificate.sh "$CERT_NAME" "$CERT_CN"

# Create VPC, subnets and internet gateways
./commands/create-ec2-vpc.sh "$VPC_CIDR" "$NET1_CIDR" "$NET2_CIDR" "$NET3_CIDR"

SG_ELB_NAME=$ENVIRONMENT"ELBSecurityGroup"
SG_ELB_DESCRIPTION="security group for load balancer in "$ENVIRONMENT" environment"
SG_ELB_HTTP_PORT="80"
SG_ELB_HTTPS_PORT="443"
SG_ELB_PORTS="$SG_ELB_HTTP_PORT $SG_ELB_HTTPS_PORT"
./commands/create-ec2-security-group.sh "$VPC_CIDR" "$SG_ELB_NAME" "$SG_ELB_DESCRIPTION" "$SG_ELB_PORTS"

# Create security groups
SG_EC2_NAME=$ENVIRONMENT"EC2SecurityGroup"
SG_EC2_DESCRIPTION="security group for ec2 instances in "$ENVIRONMENT" environment"
SG_EC2_HTTP_PORT="80"
SG_EC2_HTTPS_PORT="80" #"443"
if [ "$SG_EC2_HTTP_PORT" == "$SG_EC2_HTTPS_PORT" ]
then
    SG_EC2_PORTS="22 $SG_EC2_HTTP_PORT"
else
    SG_EC2_PORTS="22 $SG_EC2_HTTP_PORT $SG_EC2_HTTPS_PORT"
fi
./commands/create-ec2-security-group.sh "$VPC_CIDR" "$SG_EC2_NAME" "$SG_EC2_DESCRIPTION" "$SG_EC2_PORTS"

# Create load balancer
ELB_NAME=$ENVIRONMENT"LoadBalancer"
./commands/create-ec2-load-balancer.sh "$VPC_CIDR" "$SG_ELB_NAME" "$ELB_NAME" "$SG_ELB_HTTP_PORT" "$SG_ELB_HTTPS_PORT" "$SG_EC2_HTTP_PORT" "$SG_EC2_HTTPS_PORT" "$CERT_NAME"

# Create launch configuration
LC_NAME=$ENVIRONMENT"LaunchConfiguration"
LC_INST_TYPE="t2.micro"
LC_USER_DATA="file://./definitions/"$ENVIRONMENT"-user-data.sh"
./commands/create-ec2-launch-configuration.sh "$VPC_CIDR" "$SG_EC2_NAME" "$LC_NAME" "$LC_AMI_ID" "$LC_INST_TYPE" "$KP_NAME" "$LC_USER_DATA"

# Create cluster
CL_NAME=$ENVIRONMENT
./commands/create-ecs-cluster.sh "$CL_NAME"

# Create auto scaling group
AS_NAME=$ENVIRONMENT"AutoScalingGroup"
AS_MIN=1
AS_MAX=2
AS_DESIRED=1
./commands/create-ec2-auto-scaling-group.sh "$VPC_CIDR" "$ELB_NAME" "$LC_NAME" "$AS_NAME" "$AS_MIN" "$AS_MAX" "$AS_DESIRED"

# Create task definition
TD_NAME="kidoju-task-definition"
TD_JSON="file://./definitions/kidoju-task-definition.json"
./commands/create-ecs-task-definition.sh "$TD_NAME" "$TD_JSON"

# Create service
SV_DESIRED=$AS_DESIRED
SV_ROLE="ecsServiceRole"
SV_NAME=$ENVIRONMENT"Service"
SV_ELB="loadBalancerName="$ELB_NAME",containerName=nginx-proxy,containerPort=80"
./commands/create-ecs-service.sh "$CL_NAME" "$TD_NAME" "$SV_NAME" "$SV_ELB" "$SV_DESIRED" "$SV_ROLE"
