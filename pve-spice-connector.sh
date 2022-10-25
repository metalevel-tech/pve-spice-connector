#!/bin/bash -e

# @author       Spas Z. Spasov <spas.z.spasov@metalevel.tech>
# @license      https://www.gnu.org/licenses/gpl-3.0.html GNU General Public License, version 3
# @home         https://github.com/metalevel-tech/pve-spice-connector
#
# @name, env    pve-spice-connector.sh, pve-spice-connector.env
# @description  Bash script that runs Virt-viewer's SPICE session via API call to a remove ProxmoxVE.
#
# @requirements curl, jq, virt-viewer (remote-viewer)

# Load a configuration file
. "$(dirname -- "$0")/pve-spice-connector.env" 2>/dev/null || true

# Set the authentication parameters
: "${TOKEN:=USER@REALM!TOKENID}"
: "${UUID:=THE-UUID-GENERATED-WHEN-YOU-CREATE-API-TOKEN}"

# Set the HTTP/S protocol ot the PVE Node
: "${PROTO:=https}"

# Set PVE Node name and Qemu/VM Id
: "${NODE:=pve}"
: "${VMID:=100}"

# Set Node URL, and Node Proxy arguments
: "${PVE_URL:=192.168.1.200:8006}"
: "${SPICE_PROXY_ARGS:=?proxy=192.168.1.200}"

# Define the temporary .ini file for virt-viewer/spice
SPICE_INI="/tmp/spice-${NODE}-${VMID}.vv"

# Get the status of the VM
STATUS=$(
    curl -fsS -k -X GET --header "Authorization: PVEAPIToken=$TOKEN=$UUID" \
    "${PROTO}://${PVE_URL}/api2/json/nodes/${NODE}/qemu/${VMID}/status/current" | jq -r '.data.qmpstatus'
)

# Power on the VM if it is not running
if [[ $STATUS != "running" ]]
then
    curl -fsS -k -X POST --header "Authorization: PVEAPIToken=$TOKEN=$UUID" \
    "${PROTO}://${PVE_URL}/api2/json/nodes/${NODE}/qemu/${VMID}/status/start" >/dev/null
    sleep 3
fi

# Get the VM's spice connection details
DATA_JSON=$(
    curl -fsS -k -X POST --header "Authorization: PVEAPIToken=$TOKEN=$UUID" \
    "${PROTO}://${PVE_URL}/api2/json/nodes/${NODE}/qemu/${VMID}/spiceproxy${SPICE_PROXY_ARGS}"
)

# https://stackoverflow.com/questions/50902634/transform-json-to-ini-files-using-jq-bash
JQ_SCRIPT='def kv: to_entries[] | "\(.key)=\(.value)"; .[] | to_entries[] | "[\(.key)]", (.value|kv)'

# Generate the .ini file
echo "[${DATA_JSON}]" | sed 's/"data":/"virt-viewer":/' | jq -rf <(echo $JQ_SCRIPT) > "$SPICE_INI"

# Open the .ini file with virt-viewer
eval remote-viewer "$SPICE_INI" >/dev/null 2>&1 &