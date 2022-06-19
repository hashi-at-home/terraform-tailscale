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
