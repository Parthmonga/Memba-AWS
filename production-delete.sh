#!/bin/sh

ENVIRONMENT="production"
VPC_CIDR="10.1.0.0/16"

./commands/environment-delete.sh "$ENVIRONMENT" "$VPC_CIDR"