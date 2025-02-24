provider "google" {
  region = var.region
}
module "vpc" {
  source     = "./modules/net-vpc"
  project_id = var.project_id_01
  name       = "mynetwork"
  subnets = [
    {
      ip_cidr_range = "10.0.0.0/24"
      name          = "psc"
      region        = var.region
    },
    {
      ip_cidr_range = "10.1.0.0/24"
      name          = "ilb"
      region        = var.region
    }
  ]
}

module "cloud_run" {
  source = "./modules/cloud-run-v2"
  project_id = var.project_id_01
  region = var.region
  name = "cloudrun123"
  containers = {
    storage-api = {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  vpc_connector_create = {
    ip_cidr_range = "10.2.0.0/28"
    network = module.vpc.self_link
    instances = {
      max = 10
      min = 3
    }
  } 

  service_account = module.cloud_run_sa.email
  deletion_protection = false
}

module "cloud_run_sa" {
  source     = "./modules/iam-service-account"
  project_id = var.project_id_01
  name = "cloudrunsa"

  iam_project_roles = {
    "${var.project_id_01}" = [
      "roles/storage.objectAdmin"
    ]
  }
}