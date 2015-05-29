#!/bin/sh
source ~/.bashrc

# TODO check any suspicious configuration:
# users should have no policies + no roles: only groups
# list of limited groups with known policies
# list of limited roles with group trust

aws iam list-roles

aws iam list-groups

aws iam list-users


