#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> key pair check'

if [ $# -lt 1 ]
then
    echo '>>> missig arguments'
    exit
fi

KEY_NAME=$1

COUNT=$(aws ec2 describe-key-pairs --query "length(KeyPairs)" --output text)
if [ $COUNT -gt 1 ]
then
    echo '>>> WARNING: You have' $COUNT 'key pairs'
fi

KEY_FOUND=$(aws ec2 describe-key-pairs --query "KeyPairs[?KeyName=='$KEY_NAME'].KeyName" --output text)
if [ -z KEY_FOUND ]
then
     echo '>>>' $KEY_NAME 'not found'
else
     echo '>>>' $KEY_NAME 'found'
    # Maybe we should consider creating a new key pair in this case
    # Note that renewing key pairs with each installation improves security
fi
