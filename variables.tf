variable "talos_version" {
  description = "The version of talos features to use in generated machine configuration."
  type        = string
  default     = "v1.7.6"
}

variable "kubernetes_version" {
  description = "The version of kubernetes to use."
  type        = string
  default     = "v1.30.3"
}

variable "cluster_name" {
  description = "The name of the talos kubernetes cluster."
  type        = string
  default     = ""
}

variable "controlplane_nodes" {
  description = "Talos controlplane nodes."
  type        = map(any)
  default = {}
}

variable "worker_nodes" {
  description = "Talos worker nodes."
  type        = map(any)
  default = {}
}

variable "common_config_patches" {
  description = "Common configuration patches applied to both control plane and worker nodes."
  type        = list(any)
  default     = []
}

variable "controlplane_config_patches" {
  description = "Configuration patches specific to control plane nodes."
  type        = list(any)
  default     = []
}

variable "worker_config_patches" {
  description = "Configuration patches specific to worker nodes."
  type        = list(any)
  default     = []
}
