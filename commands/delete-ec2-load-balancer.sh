#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> load balancer deletion'

if [ $# -lt 1 ]
then
    echo '>>> missig arguments'
    exit
fi

ELB_NAME=$1

# http://docs.aws.amazon.com/cli/latest/reference/elb/describe-load-balancers.html
ELB_FOUND=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$ELB_NAME'].[LoadBalancerName][0][0]" --output text)
echo '>>>' $ELB_FOUND 'load balancer found'

if [ "$ELB_FOUND" == "None" ]
then
    echo '>>>' $ELB_NAME 'load balancer already deleted'
else

    # http://docs.aws.amazon.com/cli/latest/reference/elb/describe-load-balancers.html
    SG_NAME=$(aws elb describe-load-balancers --query "LoadBalancerDescriptions[?LoadBalancerName=='$ELB_NAME'].[SourceSecurityGroup][0][0].GroupName" --output text)
    echo '>>>' $SG_NAME 'load balancer security group found'

    # http://docs.aws.amazon.com/cli/latest/reference/elb/delete-load-balancer.html
    aws elb delete-load-balancer --load-balancer-name "$ELB_NAME"
    echo '>>>' $ELB_NAME 'load balancer deleted'

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-network-interfaces.html
    ATTACH_ID=$(aws ec2 describe-network-interfaces --query "NetworkInterfaces[?Groups[0].GroupName=='$SG_NAME'].[Attachment.AttachmentId][0][0]" --output text)

    # Note: we need to detach before we can delete
    if [ "$ATTACH_ID" != "None" ]
    then
        # http://docs.aws.amazon.com/cli/latest/reference/ec2/detach-network-interface.html
        aws ec2 detach-network-interface --attachment-id "$ATTACH_ID" --force
        echo '>>>' $ATTACH_ID 'network interface detached'
    fi

    # we need a waiter here
    # A client error (InvalidParameterValue) occurred when calling the DeleteNetworkInterface operation: Network interface 'eni-b5034dc3' is currently in use.
    sleep 5

    # http://docs.aws.amazon.com/cli/latest/reference/ec2/describe-network-interfaces.html
    NIC_ID=$(aws ec2 describe-network-interfaces --query "NetworkInterfaces[?Groups[0].GroupName=='$SG_NAME'].[NetworkInterfaceId][0][0]" --output text)

    # Note: If not deleted we won't be able to delete the corresponding security group
    if [ "$NIC_ID" != "None" ]
    then
        # http://docs.aws.amazon.com/cli/latest/reference/ec2/delete-network-interface.html
        aws ec2 delete-network-interface --network-interface-id "$NIC_ID"
        echo '>>>' $NIC_ID 'network interface deleted'
    fi

fi
