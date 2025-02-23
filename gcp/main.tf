provider "google" {
  region = var.region
}
module "vpc" {
  source     = "./modules/net-vpc"
  project_id = var.project_id_01
  name       = "my-network"
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

# module "cloud_run" {
#   source = "./fabric/modules/cloud-run-v2"
#   project_id = var.project_id_01
#   region = var.region
#   name = "cloudRun"
#   containers = {
#     storage_api = {
#       image = "gcr.io/google.com/cloudsdktool/cloud-sdl:slim"

#     }
#   }

#   ingress = "internal-and-cloud-load-balancing"

#   vpc_connector_create = {
#     ip_cidr_range = "10.2.0.0/28"
#     network = module.vpc.self_link
#     instances = {
#       max = 10
#       min = 3
#     }
#   } 

#   service_account = module.cloud_run_sa.email
#   deletion_protection = false
# }

# module "cloud_run_sa" {
#   source     = "./fabric/modules/iam-service-account"
#   project_id = var.project_id_01
#   name = "cloud-run-sa"

#   iam_project_roles = {
#     var.project_id_01 = [
#       "roles/storage.objectAdmin"
#     ]
#   }
# }