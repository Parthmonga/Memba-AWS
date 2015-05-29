#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> cluster deletion'

if [ $# -lt 1 ]
then
    echo '>>> missig arguments'
    exit
fi

CL_NAME=$1

CL_FOUND=$(aws ecs describe-clusters --clusters "$CL_NAME" --query "clusters[0].clusterName" --output text)
CL_STATUS=$(aws ecs describe-clusters --clusters "$CL_NAME" --query "clusters[0].status" --output text)
if [ "$CL_STATUS" != "ACTIVE" ]
then
    CL_FOUND="None"
fi
echo '>>>' $CL_FOUND 'cluster found'

# TODO https://github.com/aws/aws-cli/issues/1327
if [ "$CL_FOUND" == "None" ]
then
    echo '>>>' $CL_NAME 'cluster not found'
    echo '>>>' $CL_NAME 'cluster already deleted'
else

    # Note: this should not be required since we are using an auto-scaling group which we delete as a whole (just in case some instances are left)
    # http://docs.aws.amazon.com/cli/latest/reference/ecs/list-container-instances.html
    INSTANCE_ARNS=$(aws ecs list-container-instances --cluster default --query="containerInstanceArns" --output text)

    if [ ! -z "$INSTANCE_ARNS" ]
    then

        #http://docs.aws.amazon.com/cli/latest/reference/ecs/describe-container-instances.html
        INSTANCE_IDS=$(aws ecs describe-container-instances --container-instances $INSTANCE_ARNS --query "containerInstances[].ec2InstanceId" --output text)

        # http://docs.aws.amazon.com/cli/latest/reference/ec2/terminate-instances.html
        aws ec2 terminate-instances --instance-ids $INSTANCE_IDS

        #http://docs.aws.amazon.com/cli/latest/reference/ec2/wait/instance-terminated.html
        aws ec2 wait instance-terminated --instance-ids $INSTANCE_IDS
        echo '>>>' $INSTANCE_IDS 'instances terminated'

    fi

    # http://docs.aws.amazon.com/cli/latest/reference/ecs/delete-cluster.html
    CL_DELETED=$(aws ecs delete-cluster --cluster "$CL_NAME" --query "cluster.clusterName" --output text)
    echo '>>>' $CL_DELETED 'cluster deleted'

fi
