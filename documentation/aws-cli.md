# AWS CLI Cheat Sheet

## Documentation

AWS CLI docs are located at http://aws.amazon.com/cli/

Also consider watching:

- https://www.youtube.com/watch?v=ZbgvG7yFoQI

## Installation

Follow the instructions at http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html

1. First download and install Python version 2.7.9 or above (required for pip) from https://www.python.org/downloads/release/python-279/
2. Configure your PYTHON environment variable and check ```python --version``` and ```pip --help```.
3. Then run ```pip install awscli``` from an administrator console (```sudo```) to install the AWS CLI.

Then you can run ```pip install --upgrade awscli``` to upgrade the AWS CLI.

If you get the following error:

```shell
Fatal error in launcher: Unable to create process using '""C:\Program Files\Pyth
on\python.exe"" "C:\Program Files\Python\Scripts\pip.exe" install awscli'
```

Then you need to run ```python "C:\Program Files\Python\Scripts\pip.exe" install --upgrade awscli``` with administrator privileges.

Check the installation/upgrade with ```aws --version```.

## Configuration

Run ```aws configure``` and follow the instructions as explained at http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html.

This creates two files in ```C:\Users\<user name>\.aws``` which you can edit with a text editor.

## Help

you can do:

- ```aws help```,
- ```aws <service> help``` like in ```aws ecs help```,
- ```aws <service> <command> help``` like in ```aws ec2 list-clusters help```.

## --debug

The option ```--debug``` can be passed to any command to get verbose debugging information.

## Profiles and roles

Security rights are set through policies.

It is important that no policy is attached to users or groups , except maybe read-only policies on groups.
 
The recommended model is:

1. set policies on roles,
2. trust groups to assume roles
3. defined profiles that use these roles

For more information see http://docs.aws.amazon.com/cli/latest/userguide/cli-roles.html.

## Waiters


## JMESPath queries and JPTERM


## Templates