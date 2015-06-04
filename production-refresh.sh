#!/bin/sh

ENVIRONMENT="production"
CL_NAME=$ENVIRONMENT
SV_NAME=$ENVIRONMENT"Service"

./commands/environment-refresh.sh "$CL_NAME" "$SV_NAME"