#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> service creation'

if [ $# -lt 6 ]
then
    echo '>>> missig arguments'
    exit
fi

CL_NAME=$1
TD_NAME=$2
SV_NAME=$3
SV_ELB=$4
SV_DESIRED=$5
SV_ROLE=$6

# http://docs.aws.amazon.com/cli/latest/reference/ecs/describe-services.html
SV_FOUND=$(aws ecs describe-services --cluster "$CL_NAME" --services "$SV_NAME" --query "services[?serviceName==`$SV_NAME`].[serviceName][0][0]" --output text)
SV_STATUS=$(aws ecs describe-services --cluster "$CL_NAME" --services "$SV_NAME" --query "services[?serviceName==`$SV_NAME`].[status][0][0]" --output text)
if [ "$SV_STATUS" != "ACTIVE" ]
then
    SV_FOUND="None"
fi
echo '>>>' $SV_FOUND 'active service found'

if [ "$SV_FOUND" == "None" ]
then

    # http://docs.aws.amazon.com/cli/latest/reference/ecs/create-service.html
    # TODO not sure what --client-token is about
    SV_CREATED=$(aws ecs create-service --cluster "$CL_NAME" --service-name "$SV_NAME" --task-definition "$TD_NAME" --load-balancers "$SV_ELB" --desired-count "$SV_DESIRED" --role "$SV_ROLE" --client-token="a" --query "service.serviceName" --output text)
    echo '>>>' $SV_CREATED 'service created'

    # TODO: add tags

else
    echo '>>>' $SV_NAME 'service already exists'
fi