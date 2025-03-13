variable "resource_group_name" {
  description = "Resource group name"
  default     = "netanel"
}

variable "location" {
  description = "Location"
  default     = "Israel Central"
}

variable "vnet_vm_name" {
  description = "Name of vnet vm"
  default     = "vnet-vm"
}

variable "vnet_func_app_name" {
  description = "Name of vnet function app"
  default     = "vnet-function-app"
}

variable "user_principal_id" {
  description = "Allows access to VM via RDP"
  default = "db506c9c-457c-4d86-81dd-6e5b2670c7be"
}

variable "admin_username" {
  description = "Admin username"
  default = "oriram"
}

variable "admin_password" {
  description = "Admin password"
  default = "Homogadol123"
}

variable "project_id_01" {
  default = "mod-gcp-mam-haf-netanel-01"
}

variable "google_billing_account" {
  default = "01A98A-A178F7-4BC158"
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

variable "project_01_apis" {
  default = [
    "analyticshub.googleapis.com",
    "artifactregistry.googleapis.com",
    "bigquery.googleapis.com",
    "bigqueryconnection.googleapis.com",
    "bigquerydatapolicy.googleapis.com",
    "bigquerymigration.googleapis.com",
    "bigqueryreservation.googleapis.com",
    "bigquerystorage.googleapis.com",
    "cloudaicompanion.googleapis.com",
    "cloudapis.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudtrace.googleapis.com",
    "compute.googleapis.com",
    "containerregistry.googleapis.com",
    "dataform.googleapis.com",
    "dataplex.googleapis.com",
    "datastore.googleapis.com",
    "deploymentmanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "networkconnectivity.googleapis.com",
    "oslogin.googleapis.com",
    "pubsub.googleapis.com",
    "run.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "sql-component.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
    "storage.googleapis.com",
    "vpcaccess.googleapis.com",
    "websecurityscanner.googleapis.com"
  ]
}

variable "project_02_apis" {
  default = [
    "analyticshub.googleapis.com",
    "artifactregistry.googleapis.com",
    "bigquery.googleapis.com",
    "bigqueryconnection.googleapis.com",
    "bigquerydatapolicy.googleapis.com",
    "bigquerymigration.googleapis.com",
    "bigqueryreservation.googleapis.com",
    "bigquerystorage.googleapis.com",
    "cloudapis.googleapis.com",
    "cloudtrace.googleapis.com",
    "compute.googleapis.com",
    "containerregistry.googleapis.com",
    "dataform.googleapis.com",
    "dataplex.googleapis.com",
    "datastore.googleapis.com",
    "dns.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "orgpolicy.googleapis.com",
    "oslogin.googleapis.com",
    "pubsub.googleapis.com",
    "run.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "sql-component.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
    "storage.googleapis.com",
    "websecurityscanner.googleapis.com"
  ]
}
