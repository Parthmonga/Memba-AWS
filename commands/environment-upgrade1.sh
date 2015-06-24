#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> environment application upgrade'

if [ $# -lt 2 ]
then
    echo '>>> missig arguments'
    exit
fi

CL_NAME=$1
SV_NAME=$2

# http://docs.aws.amazon.com/cli/latest/reference/ecs/describe-services.html
SV_FOUND=$(aws ecs describe-services --cluster "$CL_NAME" --services "$SV_NAME" --query "services[?serviceName=='$SV_NAME'].[serviceName][0][0]" --output text)
SV_STATUS=$(aws ecs describe-services --cluster "$CL_NAME" --services "$SV_NAME" --query "services[?serviceName=='$SV_NAME'].[status][0][0]" --output text)
if [ "$SV_STATUS" != "ACTIVE" ]
then
    SV_FOUND="None"
fi
echo '>>>' $SV_FOUND 'active service found'

if [ "$SV_FOUND" == "None" ]
then
    echo '>>>' $SV_NAME 'service not found'
else

    # Create task definition
    TD_NAME="kidoju-task-definition"
    TD_JSON="file://./definitions/kidoju-task-definition.json"
    # TODO use ./commands/create-ecs-task-definition.sh "$TD_NAME" "$TD_JSON"
    # http://docs.aws.amazon.com/cli/latest/reference/ecs/register-task-definition.html
    TD_REV=$(aws ecs register-task-definition --family "$TD_NAME" --cli-input-json "$TD_JSON" --query "taskDefinition.revision" --output text)
    echo '>>>' $TD_NAME 'task definition registered with revision no.' $TD_REV

    SV_UPDATED=$(aws ecs update-service --cluster "$CL_NAME" --service "$SV_NAME" --task-definition $TD_NAME":"$TD_REV --query "service.serviceName" --output text)
    echo '>>>' $SV_UPDATED 'service upgraded with new task definition'

fi
