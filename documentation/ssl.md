# SSL Certificates

## Introduction

Generating an SSL Certificate for an AWS Elastic Load Balancer is explained at:

- http://docs.aws.amazon.com/ElasticLoadBalancing/latest/DeveloperGuide/ssl-server-cert.html
- http://docs.aws.amazon.com/IAM/latest/UserGuide/ManagingServerCerts.html
- http://www.flatmtn.com/article/setting-openssl-create-certificates
- https://certsimple.com/blog/openssl-csr-command

## Why amazon's documented procedure does not work?

The procedure described at the [amazon link](http://docs.aws.amazon.com/ElasticLoadBalancing/latest/DeveloperGuide/ssl-server-cert.html)
reproduced here above does not work:

- openssl complains that it is *Unable to load config info from /usr/local/ssl/openssl.cnf*;
- then after sorting this issue, Name.com complains that *Your CSR contains a key size that is no longer considered secure.
Security best practices require a minimum key size of 2048 bits. Please submit a new CSR with a minimum 2048 bit key size.*

So we had to make our own procedure.

## Generate a private key and a certificate signed request

CD to ./certificates directory (hereafter, the current directory).

Check openSSL is installed by running ```openssl version```.

Find openssl.cnf on your disk and copy it into your current directory. We have created [update.cmd](https://github.com/Memba/Memba-AWS/blob/master/update.cmd) to achieve the same:

```
cd /d %~dp0
COPY "C:\Program Files (x86)\Git\ssl\openssl.cnf" .\certificates\openssl.cnf /Y
```

Then run:

```
openssl req -newkey rsa:2048 -nodes -sha256 -keyout www.kidoju.com.key -out www.kidoju.com.csr -subj "/C=LU/L=Luxembourg/O=Memba Sarl/OU=Kidoju/CN=www.kidoju.com" -config openssl.cnf
```

As a result, you get ```www.kidoju.com.key``` and ```www.kidoju.com.csr``` in the current directory. There is also a ```.rnd``` file.

## Obtain the certificate from a provider

We have used [name.com rapidSSL certificate offer](https://www.name.com/ssl).

Follow the instructions displayed, copy/paste the content of ```www.kidoju.com.csr``` where it belongs, submit and get:

- the server certificate (```www.kidoju.com.server.cert```),
- the CA certificates (respectively INTERMEDIATE ```www.kidoju.com.ca.cert``` and ROOT ```www.kidoju.com.root.cert```).

## Upload the certificate to AWS

Create a text file named ```www.kidoju.com.chain.cert``` and copy/paste the INTERMEDIATE and ROOT certificates. The content of this file should look like:

```
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----
```

Then upload the certificate to AWS using the CLI as follows:

```
aws iam upload-server-certificate --server-certificate-name "kidojuSSLCertificate" --certificate-body "file://./certificates/www.kidoju.com.server.cert" --private-key "file://./certificates/www.kidoju.com.key" --certificate-chain "file://./certificates/www.kidoju.com.chain.cert"
```

Conveniently, you can use [check-iam-certificate.sh](https://github.com/Memba/Memba-AWS/blob/master/commands/check-iaM-certificate.sh) as follows:

```
./commands/check-iam-certificate.sh "kidojuSSLCertificate" "www.kidoju.com"
```