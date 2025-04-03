#!/usr/bin/env bash

REGION="us-east-1"

# Deploy the Jenkins CI Server.
aws cloudformation deploy \
--stack-name jenkins \
--template-file ./jenkins/jenkins-root.yaml \
--region ${REGION} \
--capabilities CAPABILITY_IAM \
--no-fail-on-empty-changeset

# Deploy the Production Apache Tomcat web server that will host our UserManagement app
# as well as the necessary network and security infrastructure.
aws cloudformation deploy \
--stack-name production-web \
--template-file ./web/web-root-production.yaml \
--region ${REGION} \
--capabilities CAPABILITY_IAM \
--no-fail-on-empty-changeset

# Deploy the Dev Apache Tomcat web server that will host our UserManagement app
# as well as the necessary network and security infrastructure.
aws cloudformation deploy \
--stack-name dev-web \
--template-file ./web/web-root-dev.yaml \
--region ${REGION} \
--capabilities CAPABILITY_IAM \
--no-fail-on-empty-changeset

# A nice way to get the URL of the Jenkins server without messing around in the AWS console.
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=jenkins-server" --query "Reservations[*].Instances[*].InstanceId" --output text)
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[*].Instances[*].PublicIpAddress" --output text)
echo "Jenkins Server URL: http://$PUBLIC_IP:8080"

# We can also get the initial admin password.
JENKINS_ADMIN_PASSWORD=`ssh -o StrictHostKeyChecking=no -i /home/student/Downloads/labsuser.pem ubuntu@$PUBLIC_IP 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'`
echo ${JENKINS_ADMIN_PASSWORD}