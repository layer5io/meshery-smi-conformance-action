<p style="text-align:center;" align="center"><a href="https://docs.meshery.io/guides/smi-conformance#running-smi-conformance-tests-in-cicd-pipelines"><img align="center" style="margin-bottom:20px;" src="./.github/readme/images/SMI%20Conformance%20with%20Meshery.jpeg" /></a><br /><br /></p>

<p align="center">
<a href="https://github.com/layer5io/meshery-smi-conformance-action/releases">
<img alt="GitHub release (latest by date)" src="https://img.shields.io/github/v/release/layer5io/meshery-smi-conformance-action"></a>
<a href="https://github.com/layer5io/meshery-smi-conformance-action/issues">
<img alt="GitHub issues" src="https://img.shields.io/github/issues/layer5io/meshery-smi-conformance-action"> </a>
<a href="https://github.com/layer5io/meshery-smi-conformance-action/blob/master/LICENSE" alt="LICENSE">
<img src="https://img.shields.io/github/license/layer5io/meshery.svg" /></a>
<a href="http://slack.layer5.io" alt="Join Slack">
<img src="https://img.shields.io/badge/Slack-@layer5.svg?logo=slack"></a>
<a href="https://twitter.com/intent/follow?screen_name=mesheryio" alt="Twitter Follow">
<img src="https://img.shields.io/twitter/follow/layer5.svg?label=Follow+Layer5&style=social" /></a>
</p>

# Meshery - SMI Conformance GitHub Action

GitHub Action to run [SMI Conformance](https://docs.meshery.io/functionality/service-mesh-interface) tests on CI/CD pipelines.

Meshery is SMI's official tool for validating conformance. Learn more at [smi-spec.io](https://smi-spec.io/blog/validating-smi-conformance-with-meshery/).

## Learn More

- [Meshery and Service Mesh Interface](https://docs.meshery.io/functionality/service-mesh-interface)
- [Guide: Running SMI Conformance Tests](https://docs.meshery.io/guides/smi-conformance)
- [Conformance Test Details](https://layer5.io/projects/service-mesh-interface-conformance)
- [SMI Conformance Dashboard](https://meshery.io/service-mesh-interface) (stand-alone)
- [SMI Conformance Dashboard](https://layer5.io/service-mesh-landscape#smi) (service mesh landscape)
- [Design Specification](https://docs.google.com/document/d/1HL8Sk7NSLLj-9PRqoHYVIGyU6fZxUQFotrxbmfFtjwc/edit#)
- [Supported Service Meshes](https://docs.meshery.io/service-meshes)

## Usage

See [action.yml](action.yml)

By default, this action brings its own Kubernetes cluster(minikube), deploys the latest release of the service mesh specified and runs conformance tests (see [Running on latest release](#running-on-latest-release)).

You can however bring your own clusters with a specific version of a service mesh installed and Meshery would automatically detect your environment and run the conformance test accordingly (see [Running on specific version](#running-on-specific-version)).

See [Running SMI Conformance Tests in CI/CD Pipelines](https://docs.meshery.io/guides/smi-conformance#running-smi-conformance-tests-in-cicd-pipelines) for detailed instructions on setting up Meshery and authenticating the GitHub action.

### Sample Configurations

#### Running on latest release

Meshery would handle setting up the environment, deploying the service mesh and running the conformance tests.

```yaml
name: SMI Conformance with Meshery
on:
  push:
    tags:
      - 'v*'

jobs:
  smi-conformance:
    name: SMI Conformance
    runs-on: ubuntu-latest
    steps:

      - name: SMI conformance tests
        uses: layer5io/mesheryctl-smi-conformance-action@master
        with:
          provider_token: ${{ secrets.MESHERY_PROVIDER_TOKEN }}
          service_mesh: open_service_mesh
          mesh_deployed: false
```

#### Running on specific version 
(bring your own cluster)

The environment with the service mesh installed provided by the user and Meshery runs the conformance tests.

```yaml
name: SMI Conformance with Meshery
on:
  push:
    branches:
      - 'master'

jobs:
  smi-conformance:
    name: SMI Conformance tests on master
    runs-on: ubuntu-latest
    steps:

      - name: Deploy k8s-minikube
        uses: manusa/actions-setup-minikube@v2.4.1
        with:
          minikube version: 'v1.21.0'
          kubernetes version: 'v1.20.7'
          driver: docker

      - name: Install OSM
        run: |
           curl -LO https://github.com/openservicemesh/osm/releases/download/v0.9.1/osm-v0.9.1-linux-amd64.tar.gz
           tar -xzf osm-v0.9.1-linux-amd64.tar.gz
           mkdir -p ~/osm/bin
           mv ./linux-amd64/osm ~/osm/bin/osm-bin
           PATH="$PATH:$HOME/osm/bin/"
           osm-bin install --osm-namespace default

      - name: SMI conformance tests
        uses: layer5io/mesheryctl-smi-conformance-action@master
        with:
          provider_token: ${{ secrets.MESHERY_PROVIDER_TOKEN }}
          service_mesh: open_service_mesh
          mesh_deployed: true
```

## Reporting Conformance

Service mesh projects can report their SMI Conformance results automatically and update it on the [SMI Conformance Dashboard](https://meshery.io/service-mesh-interface).

See [Reporting Conformance](https://docs.meshery.io/functionality/service-mesh-interface#reporting-conformance) for details on how to setup reporting.

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
