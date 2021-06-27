FROM ubuntu:latest

COPY entrypoint.sh /entrypoint.sh

RUN curl -LO 'https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl'
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-$(uname)-amd64
RUN chmod +x ./kind
RUN mv ./kind usr/local/bin/kind && export KUBECONFIG=${HOME}/.kube/config
RUN kind create cluster --name kind --wait 300s
RUN sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC86BB64
RUN sudo add-apt-repository ppa:rmescandon/yq
RUN sudo apt update
RUN sudo apt install yq -y
RUN sudo api install jq
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
RUN git clone https://github.com/layer5io/meshery.git; cd meshery
RUN kubectl create namespace meshery
RUN yq e '.service.type = "NodePort"' -i install/kubernetes/helm/meshery/values.yaml
RUN helm install meshery --namespace meshery install/kubernetes/helm/meshery
RUN cd mesheryctl && make && sudo mv mesheryctl /usr/local/bin/mesheryctl
RUN kubectl expose deployment meshery --port=9081 --type=NodePort
ENTRYPOINT ["/entrypoint.sh"]
