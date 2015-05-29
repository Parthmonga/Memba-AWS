#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> cluster creation'

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
echo '>>>' $CL_FOUND 'active cluster found'

# TODO https://github.com/aws/aws-cli/issues/1327
if [ "$CL_FOUND" == "None" ]
then

    # http://docs.aws.amazon.com/cli/latest/reference/ecs/create-cluster.html
    CL_CREATED=$(aws ecs create-cluster --cluster-name "$CL_NAME" --query "cluster.clusterName" --output text)
    echo '>>>' $CL_CREATED 'cluster created'

    # TODO: add tags

else
    echo '>>>' $CL_NAME 'cluster already exists'
fi