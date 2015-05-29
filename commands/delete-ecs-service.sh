#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> service deletion'

if [ $# -lt 2 ]
then
    echo '>>> missig arguments'
    exit
fi

CL_NAME=$1
SV_NAME=$2

# http://docs.aws.amazon.com/cli/latest/reference/ecs/describe-services.html
SV_FOUND=$(aws ecs describe-services --cluster "$CL_NAME" --services "$SV_NAME" --query "services[?serviceName == '$SV_NAME'].[serviceName][0][0]" --output text)
SV_STATUS=$(aws ecs describe-services --cluster "$CL_NAME" --services "$SV_NAME" --query "services[?serviceName == '$SV_NAME'].[status][0][0]" --output text)
if [ "$SV_STATUS" != "ACTIVE" ]
then
    SV_FOUND="None"
fi
echo '>>>' $SV_FOUND 'active service found'

if [ "$SV_FOUND" == "None" ]
then
    echo '>>>' $SV_NAME 'service not found'
    echo '>>>' $SV_NAME 'service already deleted'
else

    # A client error (InvalidParameterException) occurred when calling the DeleteService operation: The service cannot be stopped while the primary deployment is scaled above 0.
    # http://docs.aws.amazon.com/cli/latest/reference/ecs/update-service.html
    SV_UPDATED=$(aws ecs update-service --cluster "$CL_NAME" --service "$SV_NAME" --desired-count 0 --query "service.serviceName" --output text)
    echo '>>>' $SV_UPDATED 'service updated'

    # http://docs.aws.amazon.com/cli/latest/reference/ecs/delete-service.html
    SV_DELETED=$(aws ecs delete-service --cluster "$CL_NAME" --service "$SV_NAME" --query "service.serviceName" --output text)
    echo '>>>' $SV_DELETED 'service deleted'

fi