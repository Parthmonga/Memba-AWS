# Nginx

## Introduction

All kidoju containers (webapp, api and support) use nginx as a reverse proxy.

https://github.com/lebinh/nginx-conf
http://glenngillen.com/thoughts/setting-up-nginx-ssl-and-virtual-hosts

## Configuration files

Nginx comes with a global configuration file at ```/etc/nginx/nginx.conf```.

Despite the [recommended instructions](https://github.com/docker-library/docs/tree/master/nginx#complex-configuration)
replacing this file is not the simplest option because it sets many defaults.

For this reason, we have opted to replace ```

## Nginx as a reverse proxy

Nginx can be used as a reverse proxy especially with several locations redirecting to corresponding containers (webapp, api, support, admin, ...).

## Virtual hosts

Virtual hosts can be defined using ```server_name```. See http://nginx.org/en/docs/http/server_names.html.
Note that ```.memba.com``` is equivalent to ```memba.com *.memba.com```.



## GZip compression



## Cache Control


## Hide nginx version

Add ```server_tokens off;``` to configuration file.

Source: http://www.nginxtips.com/how-to-hide-nginx-version/

## 


## SSL Certificates and redirection from http to https

http://serverfault.com/questions/67316/in-nginx-how-can-i-rewrite-all-http-requests-to-https-while-maintaining-sub-dom/401632
http://serverfault.com/questions/250476/how-to-force-or-redirect-to-ssl-in-nginx
http://wiki.nginx.org/Pitfalls#Taxing_Rewrites

http://www.emind.co/how-to/how-to-force-https-behind-aws-elb

The SSL certificate and https traffic encryption is better delegated to the AWS Elastic Load Balancer.

