#!/usr/bin/env bash
REGIONS=$(aws ec2 describe-regions | jq '.Regions[].RegionName' | xargs -n1 echo)
for i in $REGIONS; do
    echo "Region: $i"
    aws --region $i ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags[?Key==`Name`].Value|[0],PrivateIpAddress]|[]' --output table
done
