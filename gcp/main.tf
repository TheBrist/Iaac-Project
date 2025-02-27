provider "google" {
  region = var.region
}

module "vpc" {
  source     = "./modules/net-vpc"
  project_id = var.project_id_01
  name       = "mynetwork"

  subnets = [for subnet in var.subnets : {
    ip_cidr_range = subnet.ip_cidr_range
    name          = subnet.name
    region        = var.region
  }]

  subnets_proxy_only = [
    {
      ip_cidr_range = "10.10.0.0/24"
      name          = "proxy-only-subnet"
      region        = var.region
    }
  ]
}

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

  vpc_connector_create = {
    ip_cidr_range = "10.5.0.16/28"
    network       = module.vpc.self_link
    instances = {
      max = 10
      min = 3
    }
  }

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

module "ilb-l7" {
  source     = "./modules/net-lb-app-int"
  name       = "internal-lb"
  project_id = var.project_id_01
  region     = var.region
  backend_service_configs = {
    default = {
      backends = [{
        group = "my-neg"
      }]
      health_checks = []
    }
  }
  health_check_configs = {
    health-check = {
      check_interval_sec  = 10
      timeout_sec         = 5
      healthy_threshold   = 2
      unhealthy_threshold = 2
      name                = "health-check"
      http = {
        port = 80
      }
  } }
  neg_configs = {
    my-neg = {
      cloudrun = {
        region = var.region
        target_service = {
          name = "cloudrun123"
        }
      }
    }
  }
  vpc_config = {
    network    = module.vpc.self_link
    subnetwork = module.vpc.subnets["${var.region}/ilb"].self_link
  }
}
