# Manual Refresh

If it were possible, it would be the equivalent of restarting/reloading an ECS service.

Actually what needs to be done in the AWS console to achive the same is:

1. Go to **EC2 Container Service***
2. Open the **production** cluster
3. CLick the **productionService** in the list of services
4. Click the **Update** button (top right)
5. Enter a **Number of tasks** of 0 and click **Update Service** (bottom right)
6. Wait until the running count reaches 0 (refresh periodically)
7. Click the **Update** button (top right)
8. Enter a **Number of tasks** of 1 and click **Update Service** (bottom right)
9. Wait until the running count reaches 1 (refresh periodically)

If images are tagged in the task definition, the same images are reloaded.

If any image is not tagged in the task definition, ```docker run``` will pull the latest image from docker hub, thus reloading the service with most recent changes.

# Automated Refresh

Simply run ```production-refresh.sh``` which calls ```./commands/environment-refresh.sh production productionService```