#!/bin/sh -l
set -e

export TOKEN=${INPUT_TOKEN}
export PERF_PROFILE=${INPUT_PERFORMANCE_PROFILE}

echo '{ "meshery-provider": "None", "token": null }' | jq '.token = env.TOKEN' > ~/auth.json

mesheryctl perf apply -f $PERF_PROFILE -t $TOKEN

