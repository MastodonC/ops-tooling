#!/usr/bin/env bash

declare -a SAFE_TO_DELETE_PATTERN_LIST=("^dev-witan.*"
                                        "^dev-kixi.*"
                                        "^test-witan.*"
                                        "^test-kixi.*"
                                        "^local-witan.*"
                                        "^local-kixi.*")
declare -a SAFE_TO_IGNORE_PATTERN_LIST=("^staging-witan.*")
declare -a DELETING=()
declare -a IGNORING=()
declare -a REPORTING=()

can-delete () {
    STREAM=$1
    for pattern in "${SAFE_TO_DELETE_PATTERN_LIST[@]}"; do
        if $(echo $STREAM | grep -q "$pattern")
        then
            return 0
        fi
    done
    return 1
}

can-ignore () {
    STREAM=$1
    for pattern in "${SAFE_TO_IGNORE_PATTERN_LIST[@]}"; do
        if $(echo $STREAM | grep -q "$pattern")
        then
            return 0
        fi
    done
    return 1
}

REGIONS=$(aws ec2 describe-regions | jq '.Regions[].RegionName' | xargs -n1 echo)
for region in $REGIONS; do
    STREAMS=$(aws kinesis --region $region list-streams | jq '.StreamNames[]' | xargs -n1 echo)
    for stream in $STREAMS; do
        if $(can-delete $stream)
        then
            echo "Deleting: $stream ($region)"
        elif $(can-ignore $stream)
        then
            echo "Ignoring: $stream ($region)"
        else
            echo "Reporting: $stream ($region)"
        fi
    done
done
