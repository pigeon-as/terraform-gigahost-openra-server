# Complete example

Deploys an OpenRA dedicated server on a Gigahost VM with the module's defaults
(a `KVM Performance VPS 4GB` in `Sandefjord` running `Ubuntu 24.04 LTS`).

```sh
export GIGAHOST_API_TOKEN=flux_live_...

terraform init
terraform apply
```

The `connect_address` output is the `host:port` players enter in OpenRA's
*Connect to a server* dialog. The module generates its own SSH keypair to
provision the box; to log in yourself:

```sh
terraform output -raw ssh_private_key > openra.pem && chmod 600 openra.pem
ssh -i openra.pem root@<ipv4>
```

## Notes

- OpenRA has no max-players setting — the player slot count comes from the map.
  Set `server.map` to a map hash and/or restrict `server.map_pool`.
- Change any `server.*` setting and re-apply to reconfigure in place — the VM is
  not rebuilt.
