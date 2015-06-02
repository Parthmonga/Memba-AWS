#!/bin/sh
source ~/.bashrc

echo '------------------------------------------------------------'
echo '>>> certificate check'
# http://docs.aws.amazon.com/IAM/latest/UserGuide/ManagingServerCerts.html#UploadSignedCert

if [ $# -lt 2 ]
then
    echo '>>> missig arguments'
    exit
fi

CERT_NAME=$1 #"kidojuSSLCertificate"
CERT_CN=$2 #"www.kidoju.com"

CERT_FOUND=$(aws iam get-server-certificate --server-certificate-name "$CERT_NAME" --query "ServerCertificate.ServerCertificateMetadata.ServerCertificateName" --output text)
if [ "$CERT_FOUND" == "$CERT_NAME" ]
then
    echo '>>>' $CERT_FOUND 'certificate found'
else
    CERT=$(aws iam upload-server-certificate --server-certificate-name "$CERT_NAME" --certificate-body "file://./certificates/"$CERT_CN".server.cert" --private-key "file://./certificates/"$CERT_CN".key" --certificate-chain "file://./certificates/"$CERT_CN".chain.cert")
    echo '>>>' $CERT_NAME 'certificate uploaded'
fi