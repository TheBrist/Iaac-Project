variable "project_id_01" {
  default = "mod-gcp-mam-haf-netanel-01"
}

variable "project_id_02" {
  default = "mod-gcp-mam-haf-netanel-02"
}

variable "region" {
  default = "me-west1"
}

variable "prefix" {
  default = "mod-gcp-mam-haf-gcs"
}

variable "repo_name" {
  default = "my-repo"
}

variable "subnets" {
  default = {
    "ilb" = {
      ip_cidr_range = "10.1.0.0/24"
      name          = "ilb"
    },
    "cr-vpc-connector" = {
      ip_cidr_range = "10.2.0.0/28"
      name          = "cr-vpc-connector"
    },
    "psc-cr" = {
      ip_cidr_range = "10.3.0.0/24"
      name          = "psc-cr"
    }
  }
}