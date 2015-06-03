# Manual Setup

We are following the instructions from the [Amazon EC2 Container Service Developer Guide](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-dg.pdf).

## IAM users and roles (pages 4-5)

For now, this is managed in the AWS console.

We have created 3 groups:

- **SysAdmins** have Administrators privileges.
- **SysOpArchitects** have Power User privileges. TODO: limit privileges to the minimum required to setup a production environment.
- **SysOpOperators** has no privileges. TODO: limit privileges to the minimum required to upgrade and maintain a production environment.

We have also created 2 roles:

- **ecsInstanceRole**
- **ecsServiceRole**

## Key Pair (pages 5-7)

We have created a single keyPair named **productionIrelandKeyPair**.

## Virtual Private Cloud (pages 7-8)

We have added **productionIrelandVPC** to the default VPC based on option **VPC with a Single Public Subnet** in the **Start VPC Wizard**.

Note : in the future, we might want to select **VPC with Public and Private Subnets** to isolate our MongoDB database.
Note: Private address spaces (CIDR) are defined at https://tools.ietf.org/html/rfc1918

## Security Group (pages 8-10)

We have added the **productionIrelandVPCSecurityGroup** to the **productionIrelandVPC**.

ATTENTION: this needs to be completed in the EC2 console, not the VPC console.

Enable HTTP, HTTPS and SSH.

### Create a load balancer

1. Define Load Balancer: Naem the elb **productionIrelandLoadBalancer**, designate the vpc **productionIrelandVPC** and select all available subnets
2. Assign Security Groups: select **productionIrelandSecurityGroup**
3. Configure Security Settings: TODO  secure listener
4. Configure Health Check: Configure the ping path and leave other options by default
5. Add EC2 Instances: Click next without adding instances
6. Add Tags: Add tag **Environment: production**
7. Review

## Create an auto-scaling group

In the EC2 Console, add an auto-scaling group:

### Create a launch configuration

1. Choose AMI: In AWS Marketplace, search on **ecs** and choose **Amazon ECS-Optimized Amazon Linux AMI**.
2. Choose InstanceType: For the purpose of this exercise, select a **t2.micro** instance type 
3. Configure details: Name your configuration **productionIrelandLaunchConfiguration** and select **ecsInstanceRole**
Under Advanced Details, select **Assign a public IP address to every instance**.
Add User data

```
#!/bin/bash
echo ECS_CLUSTER=kidoju >> /etc/ecs/ecs.config
```

4. Add Storage: Keep the **30 GiB** default option.
5. Configure Security Group: select **productionIrelandSecurityGroup**
6. Review: and select **productionIrelandKeyPair**

TODO: This should be versioned with the AMI version

### Create an auto-scaling group

1. Configure Auto Scaling group details: Name the group **productionIrelandAutoScalingGroup** , select all subnets and enable CloudWatch monitoring. 
IN the advanced section, select the load balancer and enable CloudWatch monitoring.
2. Configure scaling policies: TODO for now, keep this group at its initial size
3. Configure Notifications: TODO: Do not ass any notification for now
4. Configure Tags: Add tag **Environment: production**
5. Review: and create auto scaling group.

### Create a cluster

In teh ECS console, click creat ecluster.


https://forums.aws.amazon.com/thread.jspa?threadID=179401&tstart=0
https://aws.amazon.com/blogs/compute/scaling-amazon-ecs-services-automatically-using-amazon-cloudwatch-and-aws-lambda/

# Automated Setup