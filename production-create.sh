#!/bin/sh

ENVIRONMENT="production"
VPC_CIDR="10.1.0.0/16"
NET1_CIDR="10.1.0.0/20"
NET2_CIDR="10.1.16.0/20"
NET3_CIDR="10.1.32.0/20"

./commands/environment-create.sh "$ENVIRONMENT" "$VPC_CIDR" "$NET1_CIDR" "$NET2_CIDR" "$NET3_CIDR"