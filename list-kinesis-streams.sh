#!/usr/bin/env bash

declare -a SAFE_TO_DELETE_PATTERN_LIST=("^dev-witan.*"
                                        "^dev-kixi.*"
                                        "^test-witan.*"
                                        "^test-kixi.*"
                                        "^test-jenkins-witan.*"
                                        "^test-jenkins-kixi.*"
                                        "^local-witan.*"
                                        "^local-kixi.*")
declare -a SAFE_TO_IGNORE_PATTERN_LIST=("^staging-witan.*")

case $1 in
    "staging")
        CHANNEL="#alert-staging"
        ;;
    "prod")
        CHANNEL="#alert-prod"
        ;;
    *)
        echo "Please provide an environment (staging or prod)"
        exit 1
        ;;
esac

if [[ "$2" == "--dry" ]]
then
    DRY_RUN=0
    echo "(This is a dry run - commands are printed in parenthesis)"
else
    DRY_RUN=1
fi

do-delete () {
    STREAM=$1
    REGION=$2
    CMD="aws kinesis --region $REGION delete-stream --stream-name $STREAM"
    echo "Deleting: $STREAM ($REGION)"
    if [[ $DRY_RUN -eq 0 ]]
    then
        echo "(" $CMD ")"
    else
        echo "REAL" $CMD
    fi
}

do-report () {
    STREAM=$1
    REGION=$2
    CMD="curl -X POST --data-urlencode 'payload={\"channel\": \"${CHANNEL}\", \"username\": \"list-kinesis-streams.sh\", \"text\": \":warning: Reporting a rogue stream: \\\""${STREAM}\\\"" in region ${REGION}\", \"icon_emoji\": \":fu:\"}' https://hooks.slack.com/services/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"
    echo "Reporting: $STREAM ($REGION)"
    if [[ $DRY_RUN -eq 0 ]]
    then
        echo "(" $CMD ")"
    else
        $CMD
    fi
}

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
             do-delete $stream $region
         elif $(can-ignore $stream)
         then
             echo "Ignoring: $stream ($region)"
         else
             do-report $stream $region
         fi
    done
done