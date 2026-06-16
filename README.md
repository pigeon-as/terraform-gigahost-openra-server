# terraform-gigahost-openra-server

A Terraform module that deploys and configures an [OpenRA](https://www.openra.net)
dedicated server on a [Gigahost](https://gigahost.no) virtual machine.

It is also a worked example of a pattern you need on any provider whose API has
**no cloud-init / user-data hook**: create the VM, then configure the software
over SSH with provisioners — the sanctioned "last resort" — while keeping the
application's configuration as first-class Terraform inputs and outputs.

## What it does

1. Generates an SSH keypair (`tls_private_key`), registers it as a
   `gigahost_ssh_key`, and creates an Ubuntu VM (`gigahost_server`) with that key
   attached. Provisioning needs nothing from the caller.
2. Installs the OpenRA dedicated server over SSH — from the official
   self-contained Linux AppImage (which bundles the .NET runtime, so there are
   no package repositories to add) — and runs it under systemd as an
   unprivileged user.
3. Re-applies the configuration whenever it changes, **without rebuilding the
   VM**, using a `terraform_data` resource whose `triggers_replace` watches the
   rendered config.

All host-side artifacts — the install script and the systemd unit — live in
[`templates/`](templates/) and are rendered with `templatefile()`. The generated
private key is exposed as the `ssh_private_key` output for your own SSH access.

## Usage

```hcl
provider "gigahost" {} # reads GIGAHOST_API_TOKEN from the environment

module "openra" {
  source = "github.com/pigeon-as/terraform-gigahost-openra-server"

  server = {
    name = "My OpenRA Server"
    mod  = "ra" # ra | cnc | d2k
  }
}

output "connect_address" {
  value = module.openra.connect_address
}
```

`product_name`, `region_name` and `os_name` default to a `KVM Performance VPS
4GB` in `Sandefjord` on `Ubuntu 24.04 LTS`, so a token is all you need to start.
A runnable version is in [`examples/complete`](examples/complete).

## How the re-provision trigger works

The provisioners are attached to a `terraform_data` resource, not to the VM. Its
`triggers_replace` holds a hash of the rendered systemd unit (which embeds every
`server.*` setting and the pinned version), a hash of the install script, and
the VM's `srv_id`:

- **Change a setting** (e.g. `server.name`) → the unit hash changes → the
  `terraform_data` is replaced → the installer re-runs and `systemctl restart`s
  the service. The VM is untouched.
- **Change the VM** (e.g. `product_name`) → `gigahost_server` is replaced →
  `srv_id` changes → the server is provisioned again on the fresh host.

The install script is idempotent: it downloads and extracts the pinned release
only once, otherwise just refreshing the unit and restarting the service.

## The OpenRA `server` settings

The `server` variable mirrors OpenRA's `Server.*` settings (with `Game.Mod`
exposed as `mod`). Every attribute is optional with engine-default values; see
[`variables.tf`](variables.tf) for the full set. Note that OpenRA has **no
max-players setting** — the player slot count is defined by the map, so cap
players by choosing a map (`server.map`) or restricting `server.map_pool`.

## Requirements

- Terraform >= 1.4 (for `terraform_data`).
- Providers: `pigeon-as/gigahost` (configured with `GIGAHOST_API_TOKEN`) and
  `hashicorp/tls`.

## Future improvements

- **cloud-init / user-data.** When the Gigahost API (and provider) expose a
  user-data field on the server resource, move the OpenRA install into cloud-init
  and drop the SSH provisioner entirely — the provider-native mechanism is
  always preferable to provisioners.
- **Firewall.** When the provider gains a firewall / security-group resource,
  restrict inbound traffic to the OpenRA listen port instead of relying on the
  host's default-open networking.

## Notes and limitations

- **Provisioners are a last resort.** They are used here only because Gigahost's
  API exposes no user-data field (see Future improvements).
- **Secrets.** The generated `ssh_private_key` and `server.password` (rendered
  into the systemd unit) are present in Terraform state — treat state as
  sensitive.
- **Pinned version.** `openra_version` defaults to a specific release tag so
  upstream releases never change behaviour silently. Bump it deliberately.

## License

[MPL-2.0](LICENSE).
