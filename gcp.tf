provider "google" {
  region = var.region
}

data "google_project" "project_01" {
  project_id = var.project_id_01
}

module "project_01" {
  source          = "./modules/project"
  name            = var.project_id_01
  parent          = "folders/436369632532"
  billing_account = var.google_billing_account

  services = var.project_01_apis
}

module "project_02" {
  source          = "./modules/project"
  name            = var.project_id_02
  parent          = "folders/910030953669"
  billing_account = var.google_billing_account

  services = var.project_02_apis
}

module "vpc" {
  source     = "./modules/net-vpc"
  project_id = var.project_id_01
  name       = "mynetwork"

  subnets = [for subnet in var.gcp_subnets : {
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

  subnets_psc = [
    {
      ip_cidr_range = "10.0.0.0/24"
      name          = "psc-projects"
      region        = var.region
    }
  ]
}

module "vpc_external" {
  source     = "./modules/net-vpc"
  project_id = var.project_id_02
  name       = "extnetwork"
  subnets_psc = [{
    ip_cidr_range = "10.20.0.0/24"
    name          = "external-lb"
    region        = var.region
  }]

  subnets_proxy_only = [
    {
      ip_cidr_range = "10.21.0.0/24"
      name          = "proxy-only-subnet-exl"
      region        = var.region
    }
  ]
}

module "external-lb" {
  source     = "./modules/net-lb-app-ext-regional"
  project_id = var.project_id_02
  name       = "external-lb"
  vpc        = module.vpc_external.self_link
  region     = var.region
  backend_service_configs = {
    default = {
      backends = [
        { backend = "neg-elb" }
      ]
      health_checks = []
    }
  }

  health_check_configs = {}
  neg_configs = {
    neg-elb = {
      psc = {
        region         = var.region
        subnetwork     = module.vpc_external.subnets_psc["${var.region}/external-lb"].self_link
        target_service = module.ilb-l7.service_attachment_id
      }
    }
  }

  #depends_on = [module.vpc_external, module.ilb-l7]
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

  service_attachment = {
    nat_subnets           = [module.vpc.subnets_psc["${var.region}/psc-projects"].self_link]
    enable_proxy_protocol = false
    consumer_accept_lists = {
      (var.project_id_02) = 1
    }
    consumer_reject_lists = []
  }
}

module "cloud_run" {
  source     = "./modules/cloud-run-v2"
  project_id = var.project_id_01
  region     = var.region
  name       = "cloudrun123"
  containers = {
    storage-api = {
      image = "${var.region}-docker.pkg.dev/${var.project_id_01}/${google_artifact_registry_repository.my_repo.repository_id}/testapi:latest"

      env = { "BUCKET_NAME" = module.bucket.name }
    }
  }

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  custom_audiences = []

  service_account     = module.cloud_run_sa.email
  deletion_protection = false

}

module "cloud_run_sa" {
  source     = "./modules/iam-service-account"
  project_id = var.project_id_01
  name       = "cloudrunsa"

  iam_project_roles = {
    "${var.project_id_01}" = [
      "roles/storage.admin"
    ]
  }

  # iam = {
  #   "roles/iam.workloadIdentityUser" = ["principal://iam.googleapis.com/projects/${module.project_01.number}/locations/global/workloadIdentityPools/provider-pool/providers/azure"]
  # }
}

module "azure_sa" {
  source       = "./modules/iam-service-account"
  project_id   = var.project_id_01
  name         = "azuresa"
  display_name = "Azure SA for Cloud Run"
  # iam = {
  #   "roles/iam.workloadIdentityUser" = ["principal://iam.googleapis.com/projects/${module.project_01.number}/locations/global/workloadIdentityPools/provider-pool/providers/azure"]
  # }

  iam_project_roles = {
    "${var.project_id_01}" = [
      "roles/run.invoker"
    ]
  }
}

module "bucket" {
  source                   = "./modules/gcs"
  project_id               = var.project_id_01
  name                     = "cloud-storage"
  prefix                   = var.prefix
  versioning               = true
  location                 = var.region
  public_access_prevention = "enforced"
  force_destroy            = true

  iam_bindings = {
    storage-admin = {
      role    = "roles/storage.admin"
      members = [module.cloud_run_sa.iam_email]
    }
  }
}

resource "google_artifact_registry_repository" "my_repo" {
  location      = var.region
  repository_id = var.repo_name
  description   = "docker repository"
  format        = "DOCKER"
  project       = var.project_id_01
}
resource "google_iam_workload_identity_pool" "pool" {
  workload_identity_pool_id = "provider-pool"
  display_name              = "Provider workload pool"
  project                   = var.project_id_01
}

resource "google_iam_workload_identity_pool_provider" "azure_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "azure"
  project                            = var.project_id_01
  attribute_mapping = {
    "google.subject" = "assertion.sub"
  }
  oidc {
    issuer_uri = "https://sts.windows.net/${var.tenant_id}/"
  }
}

