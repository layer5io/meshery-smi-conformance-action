#!/bin/sh -l
set -e

curl -L https://git.io/meshery | PLATFORM=kubernetes  bash - 
 
export TOKEN=${INPUT_TOKEN}

echo '{ "meshery-provider": "Meshery", "token": null }' | jq '.token = env.TOKEN' > ~/auth.json

mesheryctl perf --name "mesheryctl action perf tests" --url https://google.com --qps 4 --concurrent-requests 1     --duration 6s --token ~/auth.json
