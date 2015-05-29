#!/bin/sh

echo '============================================================'
echo '>>> create deployment evironment'

if [ $# -lt 5 ]
then
    echo '>>> missig arguments'
    exit
fi

ENVIRONMENT=$1

# Create VPC, subnets and internet gateways
VPC_CIDR=$2
NET1_CIDR=$3
NET2_CIDR=$4
NET3_CIDR=$5
./create-ec2-vpc.sh "$VPC_CIDR" "$NET1_CIDR" "$NET2_CIDR" "$NET3_CIDR"

# Create security groups
SG_EC2_NAME=$ENVIRONMENT"EC2SecurityGroup"
SG_EC2_DESCRIPTION="security group for ec2 instances in "$ENVIRONMENT" environment"
SG_EC2_PORTS="22 80 8080"
./create-ec2-security-group.sh "$VPC_CIDR" "$SG_EC2_NAME" "$SG_EC2_DESCRIPTION" "$SG_EC2_PORTS"

SG_ELB_NAME=$ENVIRONMENT"ELBSecurityGroup"
SG_ELB_DESCRIPTION="security group for load balancer in "$ENVIRONMENT" environment"
SG_ELB_PORTS="80 443"
./create-ec2-security-group.sh "$VPC_CIDR" "$SG_ELB_NAME" "$SG_ELB_DESCRIPTION" "$SG_ELB_PORTS"

# Create load balancer
ELB_NAME=$ENVIRONMENT"LoadBalancer"
./create-ec2-load-balancer.sh "$VPC_CIDR" "$SG_ELB_NAME" "$ELB_NAME"

# Create launch configuration
LC_NAME=$ENVIRONMENT"LaunchConfiguration"
LC_AMI_ID="ami-b3543cc4" #ECS-Optimized Amason Linux AMI 2015.03b
LC_INST_TYPE="t2.micro"
LC_KEY_PAIR=$ENVIRONMENT"IrelandKeyPair"
LC_USER_DATA="file://./definitions/"$ENVIRONMENT"-user-data.sh"
./create-ec2-launch-configuration.sh "$VPC_CIDR" "$SG_EC2_NAME" "$LC_NAME" "$LC_AMI_ID" "$LC_INST_TYPE" "$LC_KEY_PAIR" "$LC_USER_DATA"

# Create cluster
CL_NAME=$ENVIRONMENT
./create-ecs-cluster.sh "$CL_NAME"

# Create auto scaling group
AS_NAME=$ENVIRONMENT"AutoScalingGroup"
AS_MIN=1
AS_MAX=2
AS_DESIRED=1
./create-ec2-auto-scaling-group.sh "$VPC_CIDR" "$ELB_NAME" "$LC_NAME" "$AS_NAME" "$AS_MIN" "$AS_MAX" "$AS_DESIRED"

# Create task definitionw
TD_KIDOJU_NAME="kidoju-task-definition"
TD_KIDOJU_JSON="file://./definitions/kidoju-task-definition.json"
#./create-ecs-task-definition.sh "$TD_KIDOJU_NAME" "$TD_KDOJU_JSON"

TD_MEMBA_NAME="memba-task-definition"
TD_MEMBA_JSON="file://./definitions/memba-task-definition.json"
#./create-ecs-task-definition.sh "$TD_MEMBA_NAME" "$TD_MEMBA_JSON"

# Create services
SV_DESIRED=$AS_DESIRED
SV_ROLE="ecsServiceRole"

SV_KIDOJU_NAME=$ENVIRONMENT"KidojuService"
SV_KIDOJU_ELB="loadBalancerName="$ELB_NAME",containerName=Kidoju-Blog,containerPort=3000"
./create-ecs-service.sh "$CL_NAME" "$TD_NAME" "$SV_KIDOJU_NAME" "$SV_KIDOJU_ELB" "$SV_DESIRED" "$SV_ROLE"

SV_MEMBA_NAME=$ENVIRONMENT"MembaService"
SV_MEMBA_ELB="loadBalancerName="$ELB_NAME",containerName=Memba-Blog,containerPort=3000"
./create-ecs-service.sh "$CL_NAME" "$TD_NAME" "$SV_MEMBA_NAME" "$SV_MEMBA_ELB" "$SV_DESIRED" "$SV_ROLE"