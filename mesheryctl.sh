#!/usr/bin/env bash

SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}" || realpath "${BASH_SOURCE[0]}")")

declare -A adapters
adapters["istio"]=meshery-istio:10000
adapters["linkerd"]=meshery-linkerd:10001
adapters["consul"]=meshery-consul:10002
adapters["octarine"]=meshery-octarine:10003
adapters["nsm"]=meshery-nsm:10004
adapters["network_service_mesh"]=meshery-nsm:10004
adapters["kuma"]=meshery-kuma:10007
adapters["cpx"]=meshery-cpx:10008
adapters["osm"]=meshery-osm:10009
adapters["open_service_mesh"]=meshery-osm:10009
adapters["traefik-mesh"]=meshery-traefik-mesh:10006
adapters["traefik_mesh"]=meshery-traefik-mesh:10006

main() {
	local service_mesh_adapter=
	local spec=
	local service_mesh=
	local bin_path=

	# temporary
	# this is a patched version of mesheryctl
	curl -L https://github.com/DelusionalOptimist/meshery/releases/download/v0.5.44/mesheryctl --output ~/mesheryctl
	chmod +x ~/mesheryctl

	parse_command_line "$@"
	docker network connect bridge meshery_meshery_1
	docker network connect minikube meshery_meshery_1
	docker network connect minikube meshery_meshery-`yq eval '.["contexts"] | .["local"] | .["adapters"] | .[]' ~/.meshery/config.yaml`_1
	docker network connect bridge meshery_meshery-`yq eval '.["contexts"] | .["local"] | .["adapters"] | .[]' ~/.meshery/config.yaml`_1

	~/mesheryctl system config minikube -t ~/auth.json

	# copy the binary to ~/.meshery/bin
	cp $bin_path ~/.meshery/bin

	# deploys the service mesh
	mesheryctl mesh deploy --adapter $service_mesh_adapter -t ~/auth.json $service_mesh

	echo $spec $service_mesh_adapter
	~/mesheryctl mesh validate --spec $spec --adapter $service_mesh_adapter -t ~/auth.json > /dev/null 2>&1 &
	echo "Wating for smi-conformance pods..."
	sleep 30
	kubectl logs -n meshery deployment.apps/smi-conformance -f
	echo "Uploading results to cloud provider..."
	sleep 40
}

parse_command_line() {
	while :
	do
		case "${1:-}" in
			--service-mesh)
				if [[ -n "${2:-}" ]]; then
					# figure out assigning port numbers and adapter names
					service_mesh=$2
					service_mesh_adapter=${adapters["$2"]}
					shift
				else
					echo "ERROR: '--service-mesh' cannot be empty." >&2
					exit 1
				fi
				;;
			-s|--spec)
				if [[ -n "${2:-}" ]]; then
					spec=$2
					shift
				else
					echo "ERROR: '--spec' cannot be empty." >&2
					exit 1
				fi
				;;
			--bin-path)
				if [[ -n "${2:-}" ]]; then
					bin_path=$2
					shift
				else
					echo "ERROR: '--bin-path' cannot be empty." >&2
					exit 1
				fi
				;;
			*)
				break
				;;
		esac
		shift
	done
}

main "$@"
