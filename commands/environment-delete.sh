#!/bin/sh

echo '============================================================'
echo '>>> delete deployment evironment'

if [ $# -lt 2 ]
then
    echo '>>> missig arguments'
    exit
fi

ENVIRONMENT=$1
VPC_CIDR=$2

SG_EC2_NAME=$ENVIRONMENT"EC2SecurityGroup"
SG_ELB_NAME=$ENVIRONMENT"ELBSecurityGroup"
ELB_NAME=$ENVIRONMENT"LoadBalancer"
LC_NAME=$ENVIRONMENT"LaunchConfiguration"
CL_NAME=$ENVIRONMENT
AS_NAME=$ENVIRONMENT"AutoScalingGroup"
TD_KIDOJU_NAME="kidoju-task-definition"
TD_MEMBA_NAME="memba-task-definition"
SV_NAME=$ENVIRONMENT"Service"

# Delete service
./delete-ecs-service.sh "$CL_NAME" "$SV_NAME"

# Delete task definition
./commands/delete-ecs-task-definition.sh "$TD_NAME"

# Delete auto scaling group
./commands/delete-ec2-auto-scaling-group.sh "$AS_NAME"

# Delete cluster
./commands/delete-ecs-cluster.sh "$CL_NAME"

# Delete launch configuration
./commands/delete-ec2-launch-configuration.sh "$LC_NAME"

# Delete load balancer
./commands/delete-ec2-load-balancer.sh "$ELB_NAME"

# Delete security group
./commands/delete-ec2-security-group.sh "$VPC_CIDR" "$SG_EC2_NAME"
./commands/delete-ec2-security-group.sh "$VPC_CIDR" "$SG_ELB_NAME"

# Delete VPC and subnets
./commands/delete-ec2-vpc.sh "$VPC_CIDR"
