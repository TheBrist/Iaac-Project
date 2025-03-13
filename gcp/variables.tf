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
