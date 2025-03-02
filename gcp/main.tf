provider "google" {
  region = var.region
}



# module "vpc" {
#   source     = "./modules/net-vpc"
#   project_id = var.project_id_01
#   name       = "mynetwork"

#   subnets = [for subnet in var.subnets : {
#     ip_cidr_range = subnet.ip_cidr_range
#     name          = subnet.name
#     region        = var.region
#   }]

#   subnets_proxy_only = [
#     {
#       ip_cidr_range = "10.10.0.0/24"
#       name          = "proxy-only-subnet"
#       region        = var.region
#     }
#   ]

#   subnets_psc = [
#     {
#       ip_cidr_range = "10.0.0.0/24"
#       name          = "psc-projects"
#       region        = var.region
#     }
#   ]
# }

# module "vpc_external" {
#   source     = "./modules/net-vpc"
#   project_id = var.project_id_02
#   name       = "extnetwork"
#   subnets_psc = [{
#     ip_cidr_range = "10.20.0.0/24"
#     name          = "external-lb"
#     region        = var.region
#   }]
# }

# module "external-lb" {
#   source     = "./modules/net-lb-app-ext-regional"
#   project_id = var.project_id_02
#   name       = "external-lb"
#   vpc        = module.vpc_external.self_link
#   region     = var.region
#   backend_service_configs = {
#     external-lb = {
#       backends = [
#         { backend = "neg-elb" }
#       ]
#       health_checks = []
#     }
#   }

#   health_check_configs = {}
#   neg_configs = {
#     neg-elb = {
#       psc = {
#         region         = var.region
#         subnetwork     = "external-lb"
#         target_service = "projects/${var.project_id_01}/regions/${var.region}/serviceAttachments/ilb-service-attachment"
#       }
#     }
#   }

#   depends_on = [module.vpc_external]
# }

# module "private-dns" {
#   source     = "./modules/dns"
#   project_id = var.project_id_02
#   name       = "ilb-dns-zone"
#   zone_config = {
#     domain = "psc.gcp.idf.il."
#     private = {
#       client_networks = [module.vpc.self_link]
#     }
#   }
#   recordsets = {
#     "A ilb-service.${var.region}" = {
#       records = [module.ilb-l7.address],
#       ttl     = 600,
#     }
#   }

# }

# module "ilb-l7" {
#   source     = "./modules/net-lb-app-int"
#   name       = "internal-lb"
#   project_id = var.project_id_01
#   region     = var.region
#   backend_service_configs = {
#     default = {
#       backends = [{
#         group = "my-neg"
#       }]
#       health_checks = []
#     }
#   }
#   health_check_configs = {
#     health-check = {
#       check_interval_sec  = 10
#       timeout_sec         = 5
#       healthy_threshold   = 2
#       unhealthy_threshold = 2
#       name                = "health-check"
#       http = {
#         port = 80
#       }
#   } }
#   neg_configs = {
#     my-neg = {
#       cloudrun = {
#         region = var.region
#         target_service = {
#           name = "cloudrun123"
#         }
#       }
#     }
#   }
#   vpc_config = {
#     network    = module.vpc.self_link
#     subnetwork = module.vpc.subnets["${var.region}/ilb"].self_link
#   }

#   # service_attachment = {
#   #   // domain_name           = "ilb-service.${var.region}.psc.gcp.idf.il."
#   #   nat_subnets           = [module.vpc.subnets["${var.region}/psc-projects"].self_link]
#   #   enable_proxy_protocol = false
#   #   consumer_accept_lists = {
#   #     (var.project_id_02) = 1
#   #   }
#   #   consumer_reject_lists = []
#   #   name                  = "ilb-service-attachment"
#   # }

# }

module "cloud_run" {
  source     = "./modules/cloud-run-v2"
  project_id = var.project_id_01
  region     = var.region
  name       = "cloudrun123"
  containers = {
    storage-api = {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  service_account     = module.cloud_run_sa.email
  deletion_protection = false
}

module "cloud_run_sa" {
  source     = "./modules/iam-service-account"
  project_id = var.project_id_01
  name       = "cloudrunsa"

  iam_project_roles = {
    "${var.project_id_01}" = [
      "roles/storage.objectAdmin"
    ]
  }
}

