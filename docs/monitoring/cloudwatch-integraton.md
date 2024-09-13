# Problem
Some components of the Mojaloop software may operate as AWS managed services, which report their metrics to AWS CloudWatch. The operations team needs these performance and health metrics to be available in a centralized Grafana monitoring dashboard.

# Solution
The solution involves retrieving metrics from CloudWatch to evaluate the performance and health of AWS managed services, and integrating them into Prometheus. Grafana dashboards can then query these metrics from Prometheus.

The diagram below depicts the architecture of the proposed system.

![diagram](./cloudwatch-integraton-architecture.svg)

# Implementation details

## Exporter options
Two options are available. 
1. [CloudWatch Exporter](https://github.com/prometheus/cloudwatch_exporter/) 
2. [YACE - yet another cloudwatch exporter](https://github.com/nerdswords/yet-another-cloudwatch-exporter)

We chose the second option, YACE, because it includes a mixin with prebuilt dashboards for various services like EC2, EBS, S3, and RDS, which reduces the setup effort.

## Authentication 
Cloudwatch exporter needs to authenticate with the AWS cloudwatch API. YACE uses AWS SDK for Go enabling us to authenticate via [AWS's default credential chain](https://aws.github.io/aws-sdk-go-v2/docs/configuring-sdk/#specifying-credentials). We have two relevant options


1. Expose credentails as environment variables  
2. Associate an AWS IAM policy with the exporter pod

Option 1 uses long-lived static credentials, while Option 2 enables short-lived, more secure authentication tokens. Currently, we are using Option 1 to accelerate development.

## Target Discovery 
YACE can discover and filter resource targets based on tags. To maintain consistency, we should use the monitoring_enabled:true tag on all resources that need to be monitored.