#!/bin/bash
# Usage
#
# ./run_db_migrate_task.sh $CLIENT_ROLE_ARN client
PREFIX=$1
PROFILE=$2
VPC_NAME="epb-${STAGE}-vpc"
SECURITY_GROUP_NAME="${PREFIX}-warehouse-ecs-sg"
CLUSTER_NAME="${PREFIX}-warehouse-cluster"
TASK="${PREFIX}-warehouse-ecs-db-migrate-task"

VPC_ID=$(aws ec2 describe-vpcs --profile $PROFILE --filters Name=tag:Name,Values=$VPC_NAME --query 'Vpcs[0].VpcId')
printf "VPC ID=" $VPC_ID

SUBNET_GROUP_ID=$(aws ec2 describe-subnets --profile $PROFILE --filter Name=vpc-id,Values=$VPC_ID --query 'Subnets[?MapPublicIpOnLaunch==`false`].SubnetId')

printf "SUBNET_GROUP ID=" $SUBNET_GROUP_ID

SECURITY_GROUP_ID=$(aws ec2 describe-security-groups --profile $PROFILE  --filter Name=group-name,Values=$SECURITY_GROUP_NAME --query 'SecurityGroups[0].GroupId')

printf "SECURITY_GROUP ID=" $SECURITY_GROUP_ID

JSON_STRING="{\"awsvpcConfiguration\": {\"subnets\": ${SUBNET_GROUP_ID}, \"securityGroups\": [${SECURITY_GROUP_ID}],\"assignPublicIp\":\"DISABLED\"}}"

TASK_ID=$(aws ecs run-task  --profile $PROFILE  --cluster $CLUSTER_NAME  --task-definition epb-intg-warehouse-ecs-db-migrate-task  \
    --network-configuration "${JSON_STRING}" \
    --launch-type "FARGATE" --query 'tasks[0].containers[0].taskArn' | tr -d '"' )

STATUS=""

while [[ $STATUS != "\"STOPPED\"" ]]; do
STATUS=$(aws ecs describe-tasks --profile $PROFILE  --cluster $CLUSTER_NAME --tasks $TASK_ID --query 'tasks[0].containers[0].lastStatus')
printf "${STATUS} << WAITING FOR MIGRATION TASK TO COMPLETE...\n"

sleep 5
done

EXIT_CODE=$(aws ecs describe-tasks --profile $PROFILE --cluster $CLUSTER_NAME --tasks $TASK_ID --query 'tasks[0].containers[0].exitCode')
if [[ $EXIT_CODE = 0 ]]; then
  printf "${TASK_ID} << MIGRATION TASK COMPLETED"
  exit 0
fi

printf 'MIGRATION TASK FAILED'
exit 1




