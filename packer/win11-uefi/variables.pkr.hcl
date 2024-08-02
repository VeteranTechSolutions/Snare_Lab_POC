variable "lab_username" {
  type =  string
  default = ""
}

variable "proxmox_node" {
  type    = string
  default = ""
}

variable "proxmox_hostname" {
  type    = string
  default = ""
}

variable "lab_password" {
  type =  string
  default = ""
  sensitive = true
}

variable "proxmox_api_id" {
  type = string
  default = ""
}

variable "proxmox_api_token" {
  type = string
  default = ""
}

variable "storage_name" {
  type = string
  default = "local-zfs"
}

variable "netbridge" {
  type = string
  default = "vmbr0"
}

variable "iso_url" {
  type    = string
  default = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/22631.2428.231001-0608.23H2_NI_RELEASE_SVC_REFRESH_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:c8dbc96b61d04c8b01faf6ce0794fdf33965c7b350eaa3eb1e6697019902945c"
}
