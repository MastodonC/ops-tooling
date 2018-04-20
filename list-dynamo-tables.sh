#!/usr/bin/env bash
REGIONS=$(aws ec2 describe-regions | jq '.Regions[].RegionName' | xargs -n1 echo)
for i in $REGIONS; do
    echo "Region: $i"
    aws dynamodb --region $i list-tables | jq '.TableNames[]'
done
