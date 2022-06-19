terraform {
  required_providers {
    tailscale = {
      source  = "davidsbond/tailscale"
      version = "0.11.1"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "3.7.0"
    }

    consul = {
      source  = "hashicorp/consul"
      version = "2.15.1"
    }
  }

  backend "consul" {
    path = "hashiatho.me/tailscale"
  }
}

provider "vault" {}

data "vault_generic_secret" "tailscale" {
  path = "hashiatho.me/tailscale"
}

provider "tailscale" {
  api_key = data.vault_generic_secret.tailscale.data.tailscale_secret_key
  tailnet = data.vault_generic_secret.tailscale.data.tailnet
}

provider "consul" {}

data "consul_nodes" "nodes" {
  query_options {
    datacenter = var.datacenter
  }
}

# Create a tailscale api key for each node
resource "tailscale_tailnet_key" "node_key" {
  for_each      = toset(data.consul_nodes.nodes.nodes[*].name)
  reusable      = true
  ephemeral     = true
  preauthorized = true

}

output "nodes" {
  value = length(data.consul_nodes.nodes.nodes)
}
