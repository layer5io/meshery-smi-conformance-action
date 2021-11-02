#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}" || realpath "${BASH_SOURCE[0]}")")

# map for service meshes with abbreviated names
declare -A meshName
meshName["open_service_mesh"]=osm
meshName["traefik_mesh"]=traefik-mesh
meshName["network_service_mesh"]=nsm

main() {
	setupArgs=()
	if [[ -n "${INPUT_PROVIDER_TOKEN:-}" ]]; then
		setupArgs+=(--provider-token ${INPUT_PROVIDER_TOKEN})
	fi

	if [[ -n "${INPUT_SERVICE_MESH:-}" ]]; then
		meshNameLower=`echo $INPUT_SERVICE_MESH  | tr -d '"' | tr '[:upper:]' '[:lower:]'`
		if [ $meshNameLower = "open_service_mesh" ] || [ $meshNameLower = "traefik_mesh" ] || [ $meshNameLower = "network_service_mesh" ]
		then
			serviceMeshAbb=${meshName["$meshNameLower"]}
		else
			serviceMeshAbb=$meshNameLower
		fi
		setupArgs+=(--service-mesh ${serviceMeshAbb})
	fi

	bash "$SCRIPT_DIR/meshery.sh" "${setupArgs[@]}"

	commandArgs=()

	if [[ -n "${INPUT_SERVICE_MESH:-}" ]]; then
		commandArgs+=(--service-mesh ${meshNameLower})
	fi

	if [[ -n "${INPUT_MESH_DEPLOYED:-}" ]]; then
		boolLower=`echo $INPUT_MESH_DEPLOYED  | tr -d '"' | tr '[:upper:]' '[:lower:]'`
		if [[ $boolLower != "true" && $boolLower != "false" ]]
		then
			echo "mesh_deployed should be set to 'true' or 'false'"
			exit 1
		else
			commandArgs+=(--mesh-deployed ${boolLower})
		fi
	fi

	bash "$SCRIPT_DIR/mesheryctl.sh" "${commandArgs[@]}"
}

main
