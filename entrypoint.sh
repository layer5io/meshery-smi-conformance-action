#!/bin/sh -l
set -e

curl -LO 'https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl'

curl -L https://git.io/meshery | PLATFORM=kubernetes  bash - 
 
export TOKEN=${INPUT_TOKEN}

echo '{ "meshery-provider": "Meshery", "token": null }' | jq '.token = env.TOKEN' > ~/auth.json

mesheryctl system context create k8s -p kubernetes    
mesheryctl system context switch k8s                  
mesheryctl system start --yes  

kubectl config view --minify --flatten > ~/minified_config 
mv ~/minified_config ~/.kube/config

mesheryctl perf --name "mesheryctl action perf tests" --url https://google.com --qps 4 --concurrent-requests 1     --duration 6s --token ~/auth.json
