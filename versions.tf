terraform {
  required_version = ">= 1.0"

  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.5.0"
    }
  }
}
