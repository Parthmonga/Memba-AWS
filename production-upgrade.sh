#!/bin/sh

ENVIRONMENT="production"
CL_NAME=$ENVIRONMENT
SV_NAME=$ENVIRONMENT"Service"

./commands/environment-upgrade1.sh "$CL_NAME" "$SV_NAME"
./commands/environment-refresh.sh "$CL_NAME" "$SV_NAME"

# Same as
#./commands/environment-upgrade2.sh "$CL_NAME" "$SV_NAME"