<p style="text-align:center;" align="center"><a href="https://layer5.io/meshery"><img align="center" style="margin-bottom:20px;" src="https://raw.githubusercontent.com/layer5io/meshery/master/.github/assets/images/meshery/meshery-logo-tag-light-text-side.png"  width="70%" /></a><br /><br /></p>

<p align="center">
<a href="https://hub.docker.com/r/layer5/meshery" alt="Docker pulls">
<img src="https://img.shields.io/docker/pulls/layer5/meshery.svg" /></a>
<a href="https://goreportcard.com/report/github.com/layer5io/meshery" alt="Go Report Card">
<img src="https://goreportcard.com/badge/github.com/layer5io/meshery" /></a>
<a href="https://github.com/layer5io/meshery/actions" alt="Build Status">
<img src="https://github.com/layer5io/meshery/workflows/Meshery/badge.svg" /></a>
<a href="https://bestpractices.coreinfrastructure.org/projects/3564" alt="CLI Best Practices">
<img src="https://bestpractices.coreinfrastructure.org/projects/3564/badge" /></a>
<a href="https://github.com/layer5io/meshery" alt="Website">
<img src="https://img.shields.io/website/https/layer5.io/meshery.svg" /></a>
<a href="https://github.com/issues?utf8=✓&q=is%3Aopen+is%3Aissue+archived%3Afalse+org%3Alayer5io+label%3A%22help+wanted%22+" alt="GitHub issues by-label">
<img src="https://img.shields.io/github/issues/layer5io/meshery/help%20wanted.svg" /></a>
<a href="http://slack.layer5.io" alt="Join Slack">
<img src="https://img.shields.io/badge/Slack-@layer5.svg?logo=slack"></a>
<a href="https://twitter.com/intent/follow?screen_name=mesheryio" alt="Twitter Follow">
<img src="https://img.shields.io/twitter/follow/layer5.svg?label=Follow+Layer5&style=social" /></a>
<a href="https://github.com/layer5io/meshery" alt="LICENSE">
<img src="https://img.shields.io/github/license/layer5io/meshery.svg" /></a>
</p>

[![smi-conformance](https://github.com/layer5io/meshery-smi-conformance-action/actions/workflows/smi-conformace.yml/badge.svg)](https://github.com/layer5io/meshery-smi-conformance-action/actions/workflows/smi-conformace.yml)

<h5><p align="center"><i>If you’re using Meshery or if you like the project, please <a href="https://github.com/layer5io/meshery/stargazers">★</a> this repository to show your support! 🤩</i></p></h5>

[Meshery](https://meshery.io) is the multi-service mesh management plane offering lifecycle, configuration, and performance management of service meshes and their workloads.

# Meshery GitHub Action for Service Mesh Interface Conformance

GitHub Action for `mesheryctl mesh validate` for SMI conformance - https://meshery.io/service-mesh-interface

<img src="/.github/readme/images/smi-conformance.png" width="110px" align="left" style="margin-right: 10px;" />

**Learn More**
- [SMI Conformance Dashboard](https://meshery.io/service-mesh-interface) (stand-alone)
- [SMI Conformance Dashboard](https://layer5.io/service-mesh-landscape#smi) (service mesh landscape)
- [Design Specification](https://docs.google.com/document/d/1HL8Sk7NSLLj-9PRqoHYVIGyU6fZxUQFotrxbmfFtjwc/edit#)
- [Conformance Test Details](https://layer5.io/projects/service-mesh-interface-conformance)

## Usage

* **For initial releases, this action works the best with minikube clusters.**
* We recommend using the [manusa/actions-setup-minikube](https://github.com/manusa/actions-setup-minikube) action.
* We also recommend using the [ubuntu-latest](https://github.com/actions/virtual-environments#available-environments) environment.

### Inputs
```yaml
  # this token is used to auth with meshery provider and persist conformance results
  provider_token:
    description: "Provider token to use. NOTE: value of the 'token' key in auth.json"
    required: true

  # the name of the service mesh to run tests on. Must be in compliance with
  # https://github.com/service-mesh-performance/service-mesh-performance/blob/1de8c93d8cba4ba8c1120fe09b7bf6ce0aa48c83/protos/service_mesh.proto#L15-L28
  service_mesh:
    # used for provisioning appropriate meshery-adatper
    description: "SMP compatible name for service mesh to use. e.g: open_service_mesh, istio etc"
    required: true

  # to identify if you want to run the tests on a cluster having the service
  # mesh pre-installed
  mesh_deployed:
    description: "A boolean. Set to true if you want to do tests on a custom deployment of the service mesh and not only on the latest release"
  required: true
```

### Example Configurations

#### Running SMI Conformance Tests on latest release of a Service Mesh
```yaml
name: SMI Conformance Validation using Meshery
on:
  push:
    tags:
      - 'v*'

jobs:
  do_conformance:
    name: Conformance Validation
    runs-on: ubuntu-latest
    steps:

      # This action takes care of installing a cluster, installing the latest
      # release of a service mesh and running SMI Conformance Tests on it
      - name: SMI conformance tests
        uses: layer5io/mesheryctl-smi-conformance-action@master
        with:
          provider_token: ${{ secrets.PROVIDER_TOKEN }}
          service_mesh: open_service_mesh
          mesh_deployed: false
```

#### Running SMI Conformance Tests on any version of a service mesh
```yaml
name: SMI Conformance Validation using Meshery
on:
  push:
    branches:
      - 'master'

jobs:
  do_conformance:
    name: SMI Conformance on every commit to master
    runs-on: ubuntu-latest
    steps:

      # deploy k8s
      - name: Deploy k8s
        uses: manusa/actions-setup-minikube@v2.4.1
        with:
          minikube version: 'v1.21.0'
          kubernetes version: 'v1.20.7'
          driver: docker

      # Install the wanted version of your service mesh
      - name: Install OSM
        run: |
           curl -LO https://github.com/openservicemesh/osm/releases/download/v0.9.1/osm-v0.9.1-linux-amd64.tar.gz
           tar -xzf osm-v0.9.1-linux-amd64.tar.gz
           mkdir -p ~/osm/bin
           mv ./linux-amd64/osm ~/osm/bin/osm-bin
           PATH="$PATH:$HOME/osm/bin/"
           osm-bin install --osm-namespace default

      # perform SMI conformance validation on the mesh installed in the cluster
      - name: SMI conformance tests
        uses: layer5io/mesheryctl-smi-conformance-action@master
        with:
          provider_token: ${{ secrets.PROVIDER_TOKEN }}
          service_mesh: open_service_mesh
          mesh_deployed: true
```



## Join the service mesh community!

<a name="contributing"></a><a name="community"></a>
Our projects are community-built and welcome collaboration. 👍 Be sure to see the <a href="https://docs.google.com/document/d/17OPtDE_rdnPQxmk2Kauhm3GwXF1R5dZ3Cj8qZLKdo5E/edit">Layer5 Community Welcome Guide</a> for a tour of resources available to you and jump into our <a href="http://slack.layer5.io">Slack</a>!

<p style="clear:both;">
<a href ="https://layer5.io/community/meshmates"><img alt="MeshMates" src=".github/readme/images/Layer5-MeshMentors.png" style="margin-right:10px; margin-bottom:7px;" width="28%" align="left" /></a>
<h3>Find your MeshMate</h3>

<p>MeshMates are experienced Layer5 community members, who will help you learn your way around, discover live projects and expand your community network. 
Become a <b>Meshtee</b> today!</p>

Find out more on the <a href="https://layer5.io/community">Layer5 community</a>. <br />
<br /><br /><br /><br />
</p>

<div>&nbsp;</div>

<a href="https://meshery.io/community"><img alt="Layer5 Service Mesh Community" src=".github/readme/images//slack-128.png" style="margin-left:10px;padding-top:5px;" width="110px" align="right" /></a>

<a href="http://slack.layer5.io"><img alt="Layer5 Service Mesh Community" src=".github/readme/images//community.svg" style="margin-right:8px;padding-top:5px;" width="140px" align="left" /></a>

<p>
✔️ <em><strong>Join</strong></em> any or all of the weekly meetings on <a href="https://calendar.google.com/calendar/b/1?cid=bGF5ZXI1LmlvX2VoMmFhOWRwZjFnNDBlbHZvYzc2MmpucGhzQGdyb3VwLmNhbGVuZGFyLmdvb2dsZS5jb20">community calendar</a>.<br />
✔️ <em><strong>Watch</strong></em> community <a href="https://www.youtube.com/playlist?list=PL3A-A6hPO2IMPPqVjuzgqNU5xwnFFn3n0">meeting recordings</a>.<br />
✔️ <em><strong>Access</strong></em> the <a href="https://drive.google.com/drive/u/4/folders/0ABH8aabN4WAKUk9PVA">Community Drive</a> by completing a community <a href="https://layer5.io/newcomer">Member Form</a>.<br />
✔️ <em><strong>Discuss</strong></em> in the <a href="https://discuss.layer5.io/">Community Forum</a>.<br />
</p>
<p align="center">
<i>Not sure where to start?</i> Grab an open issue with the <a href="https://github.com/issues?q=is%3Aopen+is%3Aissue+archived%3Afalse+org%3Alayer5io+org%3Ameshery+org%3Aservice-mesh-performance+org%3Aservice-mesh-patterns+label%3A%22help+wanted%22+">help-wanted label</a>.
</p>
