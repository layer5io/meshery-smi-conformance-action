#!/bin/sh -l
set -e

curl -LO 'https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl'

 curl -L https://git.io/meshery | PLATFORM=kubernetes  bash - 
 
 apk add jq


