#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> launch configuration deletion'

if [ $# -lt 1 ]
then
    echo '>>> missig arguments'
    exit
fi

LC_NAME=$1

# http://docs.aws.amazon.com/cli/latest/reference/autoscaling/describe-launch-configurations.html
LC_FOUND=$(aws autoscaling describe-launch-configurations --launch-configuration-names "$LC_NAME" --query "LaunchConfigurations[0].LaunchConfigurationName" --output text)
echo '>>>' $LC_FOUND 'launch configuration found'

if [ "$LC_FOUND" == "None" ]
then
    echo '>>>' $LC_NAME 'launch configuration already deleted'
else
    # http://docs.aws.amazon.com/cli/latest/reference/autoscaling/delete-launch-configuration.html
    aws autoscaling delete-launch-configuration --launch-configuration-name "$LC_NAME"
    echo '>>>' $LC_NAME 'launch configuration deleted'
fi