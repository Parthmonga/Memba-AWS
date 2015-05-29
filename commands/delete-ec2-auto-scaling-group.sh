#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> auto scaling group deletion'

if [ $# -lt 1 ]
then
    echo '>>> missig arguments'
    exit
fi

AS_NAME=$1

# http://docs.aws.amazon.com/cli/latest/reference/autoscaling/describe-auto-scaling-groups.html
AS_FOUND=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$AS_NAME" --query "AutoScalingGroups[0].AutoScalingGroupName" --output text)
echo '>>>' $AS_FOUND 'auto scaling group found'

if [ "$AS_FOUND" == "None" ]
then
    echo '>>>' $AS_NAME 'auto scaling group already deleted'
else

    # http://docs.aws.amazon.com/cli/latest/reference/autoscaling/update-auto-scaling-group.html
    # A client error (ResourceInUse) occurred when calling the DeleteAutoScalingGroup operation: You cannot delete an AutoScalingGroup while there are instances or pending Spot instance request(s) still in the group.
    aws autoscaling update-auto-scaling-group --auto-scaling-group-name "$AS_NAME" --min-size 0 --max-size 0 --desired-capacity 0

    INSTANCES=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names "$AS_NAME" --query "AutoScalingGroups[0].Instances[*].InstanceId" --output text)
    echo '>>>' $INSTANCES 'instances found'

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/wait/instance-running.html
    # aws ec2 wait instance-running --instance-ids $INSTANCES

    # for INSTANCE_ID in $INSTANCES
    # do
    #    echo '>>> terminating' $INSTANCE_ID
    #    # http://docs.aws.amazon.com/cli/latest/reference/autoscaling/terminate-instance-in-auto-scaling-group.html
    #    aws autoscaling terminate-instance-in-auto-scaling-group --instance-id "$INSTANCE_ID" --should-decrement-desired-capacity
    # done

    if [ ! -z "$INSTANCES" ]
    then
        #http://docs.aws.amazon.com/cli/latest/reference/ec2/wait/instance-terminated.html
        aws ec2 wait instance-terminated --instance-ids $INSTANCES
        echo '>>>' $INSTANCES 'instances terminated'
    fi

    # http://docs.aws.amazon.com/cli/latest/reference/autoscaling/disable-metrics-collection.html
    aws autoscaling  disable-metrics-collection --auto-scaling-group-name "$AS_NAME"

    # A client error (ScalingActivityInProgress) occurred when calling the DeleteAutoScalingGroup operation: You cannot delete an AutoScalingGroup while there are scaling activities in progress for that group.
    sleep 10

    # http://docs.aws.amazon.com/cli/latest/reference/autoscaling/delete-auto-scaling-group.html
    aws autoscaling delete-auto-scaling-group --auto-scaling-group-name "$AS_NAME" --force-delete
    echo '>>>' $AS_NAME 'auto scaling group deleted'

fi