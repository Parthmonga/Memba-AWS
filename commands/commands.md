# Building scripts for bash

## Introduction

Bash and sh are installed with Git, which has most of the unix commands on Windows.

Make sure ```C:\Program Files (x86)\Git\bin``` is in your PATH environment variable and run ```sh --login -i``` to get an interactive shell.

## Get the AWS CLI to work in interactive shells

The AWS CLI does not work in Git Bash out of the box. See https://github.com/aws/aws-cli/issues/1323.

For the AWS CLI to work in interactive shells, a .bashrc file needs to be added to the user directory, usually ```C:\Users\<user name>```,
with the following content:

```shell
# create an alias for aws
alias aws='python "C:\Program Files\Python\Scripts\aws"'
```

In a bash shell, check ```aws --version```.

## Get aws to work in non-interactive shells (scripts)

This alias needs to be propagated to non-interactive shells (scripts).

## The UGLY way that works

1. Make sure to prefix your scripts with ```#!/bin/sh``` and not ```#!/bin/bash```
2. Follow the prefix with ```source ~/.bashrc``` to force the script to read the alias in ~/.bashrc.

We could even test windows as follows:

```shell
if [ "$MSYSTEM" == "MINGW32" ]
then
    source ~/.bashrc
fi
```

This way, scripts can be run in a shell using either
 
```
sh ./commands/list-regions.sh
```

or even simply

```
./commands/list-regions.sh
```

## The UNIX way that does not work

The UNIX way to propagate ~/.bashrc and the aws alias to non-interactive shells is to export BASH_ENV as follows (in ~/.bashrc).
See https://github.com/markbirbeck/sublime-text-shell-command/wiki/Using-a-Shell-Configuration-File.

```shell
# Make .bashrc available to non interactive shells (.sh scripts)
export BASH_ENV=~/.bashrc
```

But unfortunately, this does not work: the alias is not made available to scripts.

See also:
- http://superuser.com/questions/405342/mingw-bash-profile/405373#405373
- http://unix.stackexchange.com/questions/1496/why-doesnt-my-bash-script-recognize-aliases

