# Proxmox VE SPICE Connector

Bash script that runs Virt-viewer's SPICE session via API call to a remote ProxmoxVE.

[run-vm-via-desktop-shortcut-generated-by-pve-spice-connector.webm](https://github.com/metalevel-tech/pve-spice-connector/assets/24458278/da77afae-f92b-4246-a0c5-510e55d1c6d6)



## Deploy

Clone the repository, create environment (configuration) file on the base of the provided example. Then optionally locate the script somewhere on your `$PATH` in order to use it as shell command. Here is an example:

```bash
git clone git@github.com:metalevel-tech/pve-spice-connector.git

cp pve-spice-connector.env{-example,}

ln -s /home/${USER}/Git/pve-spice-connector/pve-spice-connector.sh /home/${USER}/bin
ln -s /home/${USER}/Git/pve-spice-connector/pve-spice-connector.env /home/${USER}/bin
```

## Setup

Generate [API token](https://pve.proxmox.com/pve-docs/chapter-pveum.html#pveum_tokens) on the ProxmoxVE server. Uncheck the _Privilege separation_ option if you don't want to make additional setup for the privileges. Copy the generated authentication data, then edit the environment file and set the default values of the configuration variables:

- `$TOKEN` _name_ and `$UUID` of the token;
- `$PROTO` you can remove this variable if you use `https`;
- `$NODE` the name of the node in your cluster, you can remove this variable if you use `pve`;
- `$VMID` the Id of the default virtual machine you want to connect to, this variable will be overridden via the script call command.
- Choice one of the examples for the `$SPICE_PROXY_ARGS` and `$PVE_URL` variables and remove the rest. I'm using the parameters provided via `$SPICE_PROXY_ARGS` to override the default proxy within the Virt-viewer configuration _object_, because I'm using ReverseProxy for the ProxmoxVE Web GUI interface, but I don't want to use it for the SPICE session.

## Usage

While the scrip is in your `$PATH` you can use it as a shell command in the following way:

```bash
pve-spice-connector.sh            # Connect to the VM with the default VMID
VMID=155 pve-spice-connector.sh   # Connect to the VM with VMID 155
VMID=200 pve-spice-connector.sh   # Connect to the VM with VMID 200
```

The script will check whether the VM is running and if it is, it will immediately connect to it via SPICE session. If the VM is not running, the script will start it and few seconds later will connect to it.

## Assets

Use the [example-launcher.desktop](./assets/pve-spice-connector.example-launcher.desktop) file as template to create launchers on your GNU/Linux GUI desktop. Copy the icons from the directory [assets/icons/](./assets/icons/) to `~/.local/share/icons/` and after a while they will be available for usage within your desktop environment.

## References

- ProxmoxVE: [Proxmox VE API Reference](https://pve.proxmox.com/pve-docs/api-viewer/#/nodes/{node}/qemu/{vmid}/spiceproxy)
- ProxmoxVE Wiki: [Proxmox VE API](https://pve.proxmox.com/wiki/Proxmox_VE_API)
- ProxmoxVE Docs: [Pveproxy](https://pve.proxmox.com/pve-docs/pveproxy.8.html)
- ProxmoxVE Docs: [Spiceproxy](https://pve.proxmox.com/pve-docs/spiceproxy.8.html)
- Examples of similar scripts (and topics) which use password authentication:

  - Proxmox Forum: [Accessing SPICE without WEB GUI](https://forum.proxmox.com/threads/accessing-spice-without-webgui.77543/) | [spice-example-.sh](https://git.proxmox.com/?p=pve-manager.git;a=blob_plain;f=spice-example-sh;hb=HEAD)
  - Proxmox Forum: [Spiceproxy via API](https://forum.proxmox.com/threads/spiceproxy-via-api.103395/)
  - Apalrd.net: [Using a Raspberry Pi as a Thin Client for Proxmox VMs](https://www.apalrd.net/posts/2022/raspi_spice/)
  - JamesCoyle.net Limited: [Getting Started With Proxmox HTTP API Commands](https://www.jamescoyle.net/how-to/2666-getting-started-with-proxmox-http-api-commands)

- Proxmox Forum: [Change Spice Proxy port](https://forum.proxmox.com/threads/change-spice-proxy-port.29950/) (not related to the current topic, but I want to keep it as a note for myself)
- Metalevel.tech Wiki: [The Proxmox Category in my wiki](https://wiki.metalevel.tech/wiki/Category:Proxmox)
