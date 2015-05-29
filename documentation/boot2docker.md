# boot2docker

## installation

Download from http://boot2docker.io/ and install.

Note the user of the boot2docker VM is ```docker``` and the password is ```tcuser``` as seen at https://docs.docker.com/installation/windows/.

If you experience:

```
error in run: Failed to initialize machine "boot2docker-vm": exit status 1
```

Fix as follows (See https://github.com/boot2docker/boot2docker/issues/436):

1. Make sure HyperV is not enabled on Windows: HyperV and VirtualBox compete for VT-x.
2. Remove boot2docker-vm from "C:\Users\<username>\VirtualBox VMs".
3. Open a command prompt amd run ```bootdocker init``.

There is a nice tutorial how to run docker on Windows at http://blog.tutum.co/2014/11/05/how-to-use-docker-on-windows/.

## help

```docker``` lists all commands 

```docker <command> --help``` displays options for a specific command.

## upgrade

In a command shell:

```shell
boot2docker stop
boot2docker download
boot2docker start
```

## ip address

```boot2docker ip``` in the shell (but VM needs to be shut down) or ```ifconfig``` in the boot2docker console.

## create an image from a Dockerfile

We assume here in boot2docker because docker hub does the same remotely and automatically.

### Share your project directory with Dockerfile at the root with boot2docker VM 

To share a windows folder, first install CIFS in the boot2docker console:

```shell
$ wget http://distro.ibiblio.org/tinycorelinux/5.x/x86/tcz/cifs-utils.tcz
$ tce-load -i cifs-utils.tcz
```

Assuming the current project is located in a folder named ```Docker-AWS``` on the Windows Desktop, mount a shared folder in the boot2docker console:

```shell
$ sudo mkdir -p /mnt/shared
$ sudo mount -t cifs //<ip-address>/Users/<username>/Desktop/Docker-AWS /mnt/shared -o username=<login>
```

Enter your windows user password when requested. Then the following commands should display the list of project files including this README in the boot2docker console:

```shell
$ cd /mnt/shared
$ ls -la
```

To unmount the share:

```shell
$ sudo umount -l /mnt/shared
```

### Build an image from a Dockerfile

The second step consists in building an image in the boot2docker console:

```docker build -t <image name>[:<tag name>] .```, like in ```docker build -t jlchereau/hello .```, builds an image
from the Dockerfile in the . (dot) directory. This assumes the command is launched from a directory containing a Dockerfile.

```docker images``` should display your new image.

## troubleshoot an image

```docker run -i -t <image name>[:<tag name>] /bin/bash``` launches a shell into the image.

## container and image management

### list containers and images

```docker ps``` lists running containers.

```docker ps -all``` or ```docker ps -a``` lists all containers.

```docker images``` lists all images.

### start/stop containers

To start a container from an image that exposes port 3000, which we want to be mapped to port 49160,
run ```docker run -p 49160:3000 -d <image name>[:<tag name>]```, like in ```docker run -p 49160:3000 -d jlchereau/hello```.

```docker pull <image name>[:<tag name>]```, like in ```docker pull jlchereau/hello```,  pulls the image from the docker hub without running it.

Then assuming the ip address found here above is 192.168.59.103, the application exposed is accessible at http://192.168.59.103:49160.

After checking the name of the container created from the image using ```docker ps```, ```docker stop <container name>``` and ```docker start <container name>```,
like in ```docker stop stupefied_lumiere```, stops/starts the container.

### remove containers and images

```docker rm <container name>```, like in ```docker rm stupefied_lumiere```, removes a container (the name can be found by running ```docker ps -all```).

```docker rmi <image name>[:<tag name>]```, like in ```docker rm jlchereau/hello``` or ```docker rm jlchereau/hello:latest```, removes an image.

To remove untagged images (<none> tag) from your Docker host, see http://jimhoskins.com/2013/07/27/remove-untagged-docker-images.html.