# System and application logs

## Introduction

### Requirements

We want:

1. All our logs (AWS, OS, docker, nginx, application, database) in one single store (ideally AWS CloudWatch > S3);
2. Ideally a monitoring UI to query these logs efficiently (logentries);
1. The ability to have application logs that track a session/transaction (to be defined) from the browser to the web api via the web application (in our code).

After comparing solutions including [logstash + kibana](https://www.digitalocean.com/community/tutorials/how-to-use-logstash-and-kibana-to-centralize-and-visualize-logs-on-ubuntu-14-04),
[Graylog](https://www.graylog.org/), [Fluentd](http://www.fluentd.org/) and services like [loggly](https://www.loggly.com/), we have opted for a mix of [CloudWatch](http://aws.amazon.com/cloudwatch/) and [logentries](https://logentries.com/).

### Options for applications logs

The various strategies for monitoring logs are summarized in the ["How to Get Started with Containers and Microservices Webinar"](http://info.logentries.com/containers-and-microservices-recording).

1. Logging inside applications:
    - using aws sdk to put log entries into CloudWatch;
    - using logentries apis and plugins including [le_js for Javascript](https://github.com/logentries/le_js) and [le_node for nodeJS](https://github.com/logentries/le_node);
2. Logging to files sent by a daemon running on the host or in a container:
    - using well-known nodeJS modules like [morgan](https://github.com/expressjs/morgan), [winston](https://github.com/winstonjs/winston), [bunyan](https://github.com/trentm/node-bunyan);
    - using a host or a containerized daemon like syslog (rsyslog, syslog-mg) to push log files to [cloudwatch]( givin) or [logentries](https://blog.logentries.com/2014/03/how-to-run-rsyslog-in-a-docker-container-for-logging/);
3. Logging applications to stdout/stderr and pushing docker logs to [CloudWatch](https://github.com/nearform/docker-cloudwatch) or [logentries][docker container](https://github.com/nearform/docker-logentries).

Option 3 has multiples benefits:
- Using JS console functions, our applications are not bound to lousy libraries or unresponsive api calls (down times).
- A logging container is an easily pluggable/replaceable component which netheir affects the host configuration (option 2) or our application configurations (option 1).
- No dependency to logentries since all logs are stored in CloudWatch

## Docker, Nginx and Application logs

https://logentries.com/doc/aws-cloudwatch/
https://logentries.com/doc/aws-cloudtrail/


http://nisdom.com/blog/2015/04/10/minimalistic-logging-from-docker-containers/
https://github.com/sendgridlabs/loggly-docker/blob/master/50-default.conf
https://blog.logentries.com/2014/03/how-to-run-rsyslog-in-a-docker-container-for-logging/
https://www.loggly.com/docs/docker-syslog/

https://github.com/sekka1/loggly
http://help.papertrailapp.com/kb/configuration/configuring-centralized-logging-from-docker-containers/
http://gliderlabs.com/blog/2015/03/31/new-logspout-extensible-docker-logging/


## Amazon AMI (EC2) logs
