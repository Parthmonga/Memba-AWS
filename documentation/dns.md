# Domain Name Services

## Introduction

We are using name.com DNS.

Unfortunately URL forwarding on name.com cannot forward http traffic to https.

We have not found any clear documentation allowing http traffic pointing at an Elastic Load Balancer to be routed to nginx virtual hosts.

## memba.com

### Mail

memba.com and memba.org have MX and TXT records (SPF and DKIM) for Google mail as per:

- https://support.google.com/a/answer/174125?hl=en (MX)
- https://support.google.com/a/answer/178723?hl=en (SPF)
- https://support.google.com/a/answer/174124?hl=en (DKIM)

### Web

memba.com has a CNAME record pointing at an Amazon Elastic Load Balancer.

memba.org, memba.net and other domains are configured with name.com URL forwarding pointing at http://www.memba.com.

There is no https traffic on these sites.

## kidoju.com

### Mail

Currently, kidoju domains are not configured for email.

### Web

kidoju.com has a CNAME record pointing at an Amazon Elastic Load Balancer configured with [SSL certificates](ssl.md).

An [Nginx reverse proxy](nginx.md) is configured to forward http traffic to https.

kidoju.org and kidoju.net are configured with name.com URL forwarding pointing at https://www.kidoju.com.