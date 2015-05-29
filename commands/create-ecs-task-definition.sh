#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> task definition registration'

if [ $# -lt 2 ]
then
    echo '>>> missig arguments'
    exit
fi

TD_NAME=$1
TD_JSON=$2

# http://docs.aws.amazon.com/cli/latest/reference/ecs/register-task-definition.html
TD_REV=$(aws ecs register-task-definition --family "$TD_NAME" --cli-input-json "$TD_JSON" --query "taskDefinition.revision" --output text)

# https://github.com/aws/aws-cli/issues/1332
# TODO new revisions are added

echo '>>>' $TD_NAME 'task definition registered with revision no.' $TD_REV