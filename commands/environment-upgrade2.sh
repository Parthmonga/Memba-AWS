#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> environment application refresh'

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

    AS_DESIRED=$(aws ecs describe-services --cluster production --services productionService --query "services[?serviceName=='productionService'].[desiredCount][0][0]" --output text)

    # Create task definition
    TD_NAME="kidoju-task-definition"
    TD_JSON="file://./definitions/kidoju-task-definition.json"
    # TODO use ./commands/create-ecs-task-definition.sh "$TD_NAME" "$TD_JSON"
    # http://docs.aws.amazon.com/cli/latest/reference/ecs/register-task-definition.html
    TD_REV=$(aws ecs register-task-definition --family "$TD_NAME" --cli-input-json "$TD_JSON" --query "taskDefinition.revision" --output text)
    echo '>>>' $TD_NAME 'task definition registered with revision no.' $TD_REV

    # A client error (InvalidParameterException) occurred when calling the DeleteService operation: The service cannot be stopped while the primary deployment is scaled above 0.
    # http://docs.aws.amazon.com/cli/latest/reference/ecs/update-service.html
    SV_UPDATED=$(aws ecs update-service --cluster "$CL_NAME" --service "$SV_NAME" --desired-count 0 --query "service.serviceName" --output text)
    echo '>>>' $SV_UPDATED 'service stopped'

    AS_RUNNING=1
    until [  $AS_RUNNING -eq 0 ]
    do
       sleep 2
       AS_RUNNING=$(aws ecs describe-services --cluster production --services productionService --query "services[?serviceName=='productionService'].[runningCount][0][0]" --output text)
       echo '>>>' $SV_NAME 'has a running count of' $AS_RUNNING
    done

    sleep 5
    SV_UPDATED=$(aws ecs update-service --cluster "$CL_NAME" --service "$SV_NAME" --desired-count "$AS_DESIRED" --task-definition $TD_NAME":"$TD_REV --query "service.serviceName" --output text)
    echo '>>>' $SV_UPDATED 'service restarted'

fi
