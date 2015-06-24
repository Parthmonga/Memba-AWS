# Putty

## Connect to an aws ec2 instance

1. Open putty.exe.
2. Click **Session** in the left tree.
3. Enter the host name or ip address of the ec2 instance you want to connect to in the form ```ec2-user@ec2-54-77-20-97.eu-west-1.compute.amazonaws.com```.
4. Click **Connection .> SSH > Auth** in the left tree.
5. **Browser** for the private key file for authentication.
6. Click **Open** in the bottom right corner.
7. Accept the warning.

For more information, see http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/putty.html.

## Display logs

Run ```docker ps``` to find container ids.

Run ```docker logs <container id>``` as in ```docker logs 3ca944e1f9e2```.


## Connect to a container

Run ```docker ps``` to find container names.

Run ```docker exec -it <container-name> bash``` as in ```docker exec -it ecs-kidoju-task-definition-38-memba-blog-1-9af8e4d3fedc88df8301 bash```.
