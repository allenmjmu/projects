#!/bin/bash

POLICY_NAME="PROJECT_EKS"
POLCIY_JSON_FILE="./policies/eks.json"
POLICY_NAME_DENIES="PROJECT_EXPLICITDENIES"
POLICY_JSON_FILE_DENIES="./policies/Denies.json"
POLICY_NAME_IAM="IamPermissions"
POLICY_JSON_FILE_IAM="./policies/iamPermissions.json"

USER_NAME="terraformUser"

POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='$POLICY_NAME'].Arn" --output text)
if [ -n "$POLICY_ARN" ]; then
    echo "The policy '$POLICY_NAME' exists. Continue with the execution."
else 
    echo "The policy '$POLICY_NAME' does not exist. Creating policy..."
    aws iam create-policy --policy-name $POLICY_NAME --policy-document file://$POLCIY_JSON_FILE
    POLICY_ARN=$(aws iam list-policies --query "Policies[?PolciyName=='$POLICY_NAME'].Arn" --output text)
fi

POLICY_ARN_DENIES=$(aws iam list-policies --query "Policies[?PolicyName=='$POLICY_JSON_FILE_DENIES'].Arn" --output text)
if [ -n "$POLICY_ARN_DENIES" ]; then
    echo "The policy '$POLICY_ARN_DENIES' exisits. Continue."
else
    echo "The policy '$POLICY_ARN_DENIES' doe not exist. Creating policy..."
    aws iam create-policy --policy-name "$POLICY_ARN_DENIES" --policy-document file://$POLICY_JSON_FILE_DENIES
    POLICY_ARN_DENIES=(aws iam list-policies --query "Policies[?PolicyName=='$POLICY_JSON_FILE_DENIES'].Arn" --output text)
fi

POLICY_ARN_IAM=$(aws iam list-policies --query "Policies[?PolicyName=='$POLICY_NAME_IAM'].Arn" --output text)
if [ -n "$POLICY_NAME_IAM" ]; then
    echo "The policy '$POLICY_NAME_IAM' exisits. Continue."
else
    echo "The policy '$POLICY_NAME_IAM' doe not exist. Creating policy..."
    aws iam create-policy --policy-name $$POLICY_NAME_IAM --policy-document file://$POLICY_JSON_FILE_IAM
    POLICY_ARN_IAM=$(aws iam list-policies --query "Policies[?PolicyName=='$POLICY_NAME_IAM'].Arn" --output text)
fi

aws iam get-user --user-name $USER_NAME 2>/dev/null

if [ $? -eq 0 ]; then
    echo "The AWS user exists. Continue."
else
    echo "The AWS user does not exist. Creating..."
    aws iam create-user --user-name $USER_NAME
fi

aws iam attach-user-policy --user-name $USER_NAME --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam attach-user-policy --user-name $USER_NAME --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
aws iam attach-user-policy --user-name $USER_NAME --policy-arn arn:aws:iam::aws:policy/AmazonRDSDataFullAccess
aws iam attach-user-policy --user-name $USER_NAME --policy-arn "$POLICY_ARN" 
aws iam attach-user-policy --user-name $USER_NAME --policy-arn "$POLICY_NAME_DENIES"
aws iam attach-user-policy --user-name $USER_NAME --policy-arn "$POLICY_ARN_IAM"

echo "The policy '$POLICY_NAME' has been created and updated for user '$USER_NAME'."