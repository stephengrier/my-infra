#!/usr/bin/env bash
set -ueo pipefail

#yum update --assumeyes

logger "Installing SSM agent"
yum install --assumeyes "https://amazon-ssm-eu-west-2.s3.amazonaws.com/latest/linux_amd64/amazon-ssm-agent.rpm"

mkdir -p /etc/ecs
mkdir -p /data
cat <<EOF > /etc/ecs/ecs.config
ECS_CLUSTER=${cluster}
AWS_DEFAULT_REGION=eu-west-2
ECS_DATADIR=/data
EOF
