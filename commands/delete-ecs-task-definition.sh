#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> task definition deregistration'

if [ $# -lt 1 ]
then
    echo '>>> missig arguments'
    exit
fi

TD_NAME=$1

# http://docs.aws.amazon.com/cli/latest/reference/ecs/deregister-task-definition.html
# TODO not yet implemented by AWS
aws ecs deregister-task-definition --task-definition "$TD_NAME"