# VLAN Attachment module

This module allows for the provisioning of VLAN Attachments for [Dedicated Interconnect](https://cloud.google.com/network-connectivity/docs/interconnect/how-to/dedicated/creating-vlan-attachments) or [Partner Interconnect](https://cloud.google.com/network-connectivity/docs/interconnect/how-to/partner/creating-vlan-attachments).

## Examples

### Dedicated Interconnect - Single VLAN Attachment (No SLA)

```hcl
resource "google_compute_router" "interconnect-router" {
  name    = "interconnect-router"
  network = "mynet"
  project = "myproject"
  region  = "europe-west8"
  bgp {
    advertise_mode    = "CUSTOM"
    asn               = 64514
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range = "10.255.255.0/24"
    }
    advertised_ip_ranges {
      range = "192.168.255.0/24"
    }
  }
}

module "example-va" {
  source      = "./fabric/modules/net-vlan-attachment"
  network     = "mynet"
  project_id  = "myproject"
  region      = "europe-west8"
  name        = "vlan-attachment"
  description = "Example vlan attachment"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router.name
  }
  dedicated_interconnect_config = {
    # cloud router gets 169.254.0.1 peer router gets 169.254.0.2
    bandwidth    = "BPS_10G"
    bgp_range    = "169.254.0.0/29"
    interconnect = "https://www.googleapis.com/compute/v1/projects/my-project/global/interconnects/interconnect-a"
    vlan_tag     = 12345
  }
}
# tftest modules=1 resources=5
```

### Dedicated Interconnect - Single VLAN Attachment (No SLA) - BFD and MD5 Auth

```hcl
resource "google_compute_router" "interconnect-router" {
  name    = "interconnect-router"
  network = "mynet"
  project = "myproject"
  region  = "europe-west8"
  bgp {
    advertise_mode    = "CUSTOM"
    asn               = 64514
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range = "10.255.255.0/24"
    }
    advertised_ip_ranges {
      range = "192.168.255.0/24"
    }
  }
}

module "example-va" {
  source      = "./fabric/modules/net-vlan-attachment"
  network     = "mynet"
  project_id  = "myproject"
  region      = "europe-west8"
  name        = "vlan-attachment"
  description = "Example vlan attachment"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router.name
    bfd = {
      min_receive_interval        = 1000
      min_transmit_interval       = 1000
      multiplier                  = 5
      session_initialization_mode = "ACTIVE"
    }
    md5_authentication_key = {
      name = "foo"
      key  = "bar"
    }
  }
  dedicated_interconnect_config = {
    bandwidth    = "BPS_10G"
    bgp_range    = "169.254.0.0/29"
    interconnect = "https://www.googleapis.com/compute/v1/projects/my-project/global/interconnects/interconnect-a"
    vlan_tag     = 12345
  }
}

# tftest modules=1 resources=5
```

If you don't specify the MD5 key, the module will generate a random 12 charachters key for you.

```hcl
resource "google_compute_router" "interconnect-router" {
  name    = "interconnect-router"
  network = "mynet"
  project = "myproject"
  region  = "europe-west8"
  bgp {
    advertise_mode    = "CUSTOM"
    asn               = 64514
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range = "10.255.255.0/24"
    }
    advertised_ip_ranges {
      range = "192.168.255.0/24"
    }
  }
}

module "example-va" {
  source      = "./fabric/modules/net-vlan-attachment"
  network     = "mynet"
  project_id  = "myproject"
  region      = "europe-west8"
  name        = "vlan-attachment"
  description = "Example vlan attachment"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router.name
    bfd = {
      min_receive_interval        = 1000
      min_transmit_interval       = 1000
      multiplier                  = 5
      session_initialization_mode = "ACTIVE"
    }
    md5_authentication_key = {
      name = "foo"
    }
  }
  dedicated_interconnect_config = {
    bandwidth    = "BPS_10G"
    bgp_range    = "169.254.0.0/30"
    interconnect = "interconnect-a"
    vlan_tag     = 12345
  }
}

# tftest modules=1 resources=5
```

### Partner Interconnect - Single VLAN Attachment (No SLA)

```hcl
resource "google_compute_router" "interconnect-router" {
  name    = "interconnect-router"
  network = "mynet"
  project = "myproject"
  region  = "europe-west8"
  bgp {
    advertise_mode    = "CUSTOM"
    asn               = 16550
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range = "10.255.255.0/24"
    }
    advertised_ip_ranges {
      range = "192.168.255.0/24"
    }
  }
}

module "example-va" {
  source      = "./fabric/modules/net-vlan-attachment"
  network     = "mynet"
  project_id  = "myproject"
  region      = "europe-west8"
  name        = "vlan-attachment"
  description = "Example vlan attachment"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router.name
  }
}
# tftest modules=1 resources=3
```

### Dedicated Interconnect - Two VLAN Attachments on a single region (99.9% SLA)

```hcl
resource "google_compute_router" "interconnect-router" {
  name    = "interconnect-router"
  network = "mynet"
  project = "myproject"
  region  = "europe-west8"
  bgp {
    asn               = 64514
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range = "10.255.255.0/24"
    }
    advertised_ip_ranges {
      range = "192.168.255.0/24"
    }
  }
}

module "example-va-a" {
  source      = "./fabric/modules/net-vlan-attachment"
  network     = "mynet"
  project_id  = "myproject"
  region      = "europe-west8"
  name        = "vlan-attachment-a"
  description = "interconnect-a vlan attachment 0"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router.name
  }
  dedicated_interconnect_config = {
    bandwidth    = "BPS_10G"
    bgp_range    = "169.254.0.0/29"
    interconnect = "https://www.googleapis.com/compute/v1/projects/my-project/global/interconnects/interconnect-a"
    vlan_tag     = 1001
  }
}

module "example-va-b" {
  source      = "./fabric/modules/net-vlan-attachment"
  network     = "mynet"
  project_id  = "myproject"
  region      = "europe-west8"
  name        = "vlan-attachment-b"
  description = "interconnect-b vlan attachment 0"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router.name
  }
  dedicated_interconnect_config = {
    bandwidth    = "BPS_10G"
    bgp_range    = "169.254.0.8/29"
    interconnect = "https://www.googleapis.com/compute/v1/projects/my-project/global/interconnects/interconnect-b"
    vlan_tag     = 1002
  }
}
# tftest modules=2 resources=9
```

### Partner Interconnect - Two VLAN Attachments on a single region (99.9% SLA)

```hcl
resource "google_compute_router" "interconnect-router" {
  name    = "interconnect-router"
  network = "mynet"
  project = "myproject"
  region  = "europe-west8"
  bgp {
    asn               = 16550
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range = "10.255.255.0/24"
    }
    advertised_ip_ranges {
      range = "192.168.255.0/24"
    }
  }
}

module "example-va-a" {
  source      = "./fabric/modules/net-vlan-attachment"
  network     = "mynet"
  project_id  = "myproject"
  region      = "europe-west8"
  name        = "vlan-attachment-a"
  description = "interconnect-a vlan attachment 0"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router.name
  }
  partner_interconnect_config = {
    edge_availability_domain = "AVAILABILITY_DOMAIN_1"
  }
}

module "example-va-b" {
  source      = "./fabric/modules/net-vlan-attachment"
  network     = "mynet"
  project_id  = "myproject"
  region      = "europe-west8"
  name        = "vlan-attachment-b"
  description = "interconnect-b vlan attachment 0"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router.name
  }
  partner_interconnect_config = {
    edge_availability_domain = "AVAILABILITY_DOMAIN_2"
  }
}
# tftest modules=2 resources=5
```

### Dedicated Interconnect - Four VLAN Attachments on two regions (99.99% SLA)

```hcl
resource "google_compute_router" "interconnect-router-ew8" {
  name    = "interconnect-router-ew8"
  network = "mynet"
  project = "myproject"
  region  = "europe-west8"
  bgp {
    asn               = 64514
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range = "10.255.255.0/24"
    }
    advertised_ip_ranges {
      range = "192.168.255.0/24"
    }
  }
}

resource "google_compute_router" "interconnect-router-ew12" {
  name    = "interconnect-router-ew12"
  network = "mynet"
  project = "myproject"
  region  = "europe-west12"
  bgp {
    asn               = 64514
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range = "10.255.255.0/24"
    }
    advertised_ip_ranges {
      range = "192.168.255.0/24"
    }
  }
}

module "example-va-a-ew8" {
  source      = "./fabric/modules/net-vlan-attachment"
  network     = "mynet"
  project_id  = "myproject"
  region      = "europe-west8"
  name        = "vlan-attachment-a-ew8"
  description = "interconnect-a-ew8 vlan attachment 0"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router-ew8.name
  }
  dedicated_interconnect_config = {
    bandwidth    = "BPS_10G"
    bgp_range    = "169.254.0.0/29"
    interconnect = "interconnect-a-ew8"
    vlan_tag     = 1001
  }
}

module "example-va-b-ew8" {
  source      = "./fabric/modules/net-vlan-attachment"
  network     = "mynet"
  project_id  = "myproject"
  region      = "europe-west8"
  name        = "vlan-attachment-b-ew8"
  description = "interconnect-b-ew8 vlan attachment 0"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router-ew8.name
  }
  dedicated_interconnect_config = {
    bandwidth    = "BPS_10G"
    bgp_range    = "169.254.0.8/29"
    interconnect = "interconnect-b-ew8"
    vlan_tag     = 1002
  }
}

module "example-va-a-ew12" {
  source      = "./fabric/modules/net-vlan-attachment"
  network     = "mynet"
  project_id  = "myproject"
  region      = "europe-west12"
  name        = "vlan-attachment-a-ew12"
  description = "interconnect-a-ew12 vlan attachment 0"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router-ew12.name
  }
  dedicated_interconnect_config = {
    bandwidth    = "BPS_10G"
    bgp_range    = "169.254.1.0/29"
    interconnect = "interconnect-a-ew12"
    vlan_tag     = 1003
  }
}

module "example-va-b-ew12" {
  source      = "./fabric/modules/net-vlan-attachment"
  network     = "mynet"
  project_id  = "myproject"
  region      = "europe-west12"
  name        = "vlan-attachment-b-ew12"
  description = "interconnect-b-ew12 vlan attachment 0"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router-ew12.name
  }
  dedicated_interconnect_config = {
    bandwidth    = "BPS_10G"
    bgp_range    = "169.254.1.8/29"
    interconnect = "interconnect-b-ew12"
    vlan_tag     = 1004
  }
}
# tftest modules=4 resources=18
```

### Partner Interconnect - Four VLAN Attachments on two regions (99.99% SLA)

```hcl
resource "google_compute_router" "interconnect-router-ew8" {
  name    = "interconnect-router-ew8"
  network = "mynet"
  project = "myproject"
  region  = "europe-west8"
  bgp {
    asn               = 16550
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range = "10.255.255.0/24"
    }
    advertised_ip_ranges {
      range = "192.168.255.0/24"
    }
  }
}

resource "google_compute_router" "interconnect-router-ew12" {
  name    = "interconnect-router-ew12"
  network = "mynet"
  project = "myproject"
  region  = "europe-west12"
  bgp {
    asn               = 16550
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range = "10.255.255.0/24"
    }
    advertised_ip_ranges {
      range = "192.168.255.0/24"
    }
  }
}

module "example-va-a-ew8" {
  source      = "./fabric/modules/net-vlan-attachment"
  network     = "mynet"
  project_id  = "myproject"
  region      = "europe-west8"
  name        = "vlan-attachment-a-ew8"
  description = "interconnect-a-ew8 vlan attachment 0"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router-ew8.name
  }
  partner_interconnect_config = {
    edge_availability_domain = "AVAILABILITY_DOMAIN_1"
  }
}

module "example-va-b-ew8" {
  source      = "./fabric/modules/net-vlan-attachment"
  network     = "mynet"
  project_id  = "myproject"
  region      = "europe-west8"
  name        = "vlan-attachment-b-ew8"
  description = "interconnect-b-ew8 vlan attachment 0"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router-ew8.name
  }
  partner_interconnect_config = {
    edge_availability_domain = "AVAILABILITY_DOMAIN_2"
  }
}

module "example-va-a-ew12" {
  source      = "./fabric/modules/net-vlan-attachment"
  network     = "mynet"
  project_id  = "myproject"
  region      = "europe-west12"
  name        = "vlan-attachment-a-ew12"
  description = "interconnect-a-ew12 vlan attachment 0"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router-ew12.name
  }
  partner_interconnect_config = {
    edge_availability_domain = "AVAILABILITY_DOMAIN_1"
  }
}

module "example-va-b-ew12" {
  source      = "./fabric/modules/net-vlan-attachment"
  network     = "mynet"
  project_id  = "myproject"
  region      = "europe-west12"
  name        = "vlan-attachment-b-ew12"
  description = "interconnect-b-ew12 vlan attachment 0"
  peer_asn    = "65000"
  router_config = {
    create = false
    name   = google_compute_router.interconnect-router-ew12.name
  }
  partner_interconnect_config = {
    edge_availability_domain = "AVAILABILITY_DOMAIN_2"
  }
}
# tftest modules=4 resources=10
```

### IPSec for Dedicated Interconnect

Refer to the [HA VPN over Interconnect Blueprint](../../blueprints/networking/ha-vpn-over-interconnect/) for an all-encompassing example.

```hcl
resource "google_compute_router" "encrypted-interconnect-underlay-router-ew8" {
  name                          = "encrypted-interconnect-underlay-router-ew8"
  project                       = "myproject"
  network                       = "mynet"
  region                        = "europe-west8"
  encrypted_interconnect_router = true
  bgp {
    advertise_mode = "DEFAULT"
    asn            = 64514
  }
}

module "example-va-a" {
  source      = "./fabric/modules/net-vlan-attachment"
  project_id  = "myproject"
  network     = "mynet"
  region      = "europe-west8"
  name        = "encrypted-vlan-attachment-a"
  description = "example-va-a vlan attachment"
  peer_asn    = "65001"
  router_config = {
    create = false
    name   = google_compute_router.encrypted-interconnect-underlay-router-ew8.name
  }
  dedicated_interconnect_config = {
    bandwidth    = "BPS_10G"
    bgp_range    = "169.254.0.0/29"
    interconnect = "https://www.googleapis.com/compute/v1/projects/my-project/global/interconnects/interconnect-a"
    vlan_tag     = 1001
  }
  vpn_gateways_ip_range = "10.255.255.0/29" # Allows for up to 8 tunnels
}

module "example-va-b" {
  source      = "./fabric/modules/net-vlan-attachment"
  project_id  = "myproject"
  network     = "mynet"
  region      = "europe-west8"
  name        = "encrypted-vlan-attachment-b"
  description = "example-va-b vlan attachment"
  peer_asn    = "65001"
  router_config = {
    create = false
    name   = google_compute_router.encrypted-interconnect-underlay-router-ew8.name
  }
  dedicated_interconnect_config = {
    bandwidth    = "BPS_10G"
    bgp_range    = "169.254.0.8/29"
    interconnect = "https://www.googleapis.com/compute/v1/projects/my-project/global/interconnects/interconnect-b"
    vlan_tag     = 1002
  }
  vpn_gateways_ip_range = "10.255.255.8/29" # Allows for up to 8 tunnels
}
# tftest modules=2 resources=11
```

### IPSec for Partner Interconnect

```hcl
module "example-va-a" {
  source      = "./fabric/modules/net-vlan-attachment"
  project_id  = "myproject"
  network     = "mynet"
  region      = "europe-west8"
  name        = "encrypted-vlan-attachment-a"
  description = "example-va-a vlan attachment"
  peer_asn    = "65001"
  router_config = {
    create = true
  }
  partner_interconnect_config = {
    edge_availability_domain = "AVAILABILITY_DOMAIN_1"
  }
  vpn_gateways_ip_range = "10.255.255.0/29" # Allows for up to 8 tunnels
}

module "example-va-b" {
  source      = "./fabric/modules/net-vlan-attachment"
  project_id  = "myproject"
  network     = "mynet"
  region      = "europe-west8"
  name        = "encrypted-vlan-attachment-b"
  description = "example-va-b vlan attachment"
  peer_asn    = "65001"
  router_config = {
    create = true
  }
  partner_interconnect_config = {
    edge_availability_domain = "AVAILABILITY_DOMAIN_2"
  }
  vpn_gateways_ip_range = "10.255.255.8/29" # Allows for up to 8 tunnels
}
# tftest modules=2 resources=8
```
<!-- BEGIN TFDOC -->
## Variables

| name | description | type | required | default |
|---|---|:---:|:---:|:---:|
| [description](variables.tf#L36) | VLAN attachment description. | <code>string</code> | ✓ |  |
| [name](variables.tf#L53) | The common resources name, used after resource type prefix and suffix. | <code>string</code> | ✓ |  |
| [network](variables.tf#L58) | The VPC name to which resources are associated to. | <code>string</code> | ✓ |  |
| [peer_asn](variables.tf#L75) | The on-premises underlay router ASN. | <code>string</code> | ✓ |  |
| [project_id](variables.tf#L80) | The project id where resources are created. | <code>string</code> | ✓ |  |
| [region](variables.tf#L85) | The region where resources are created. | <code>string</code> | ✓ |  |
| [router_config](variables.tf#L90) | Cloud Router configuration for the VPN. If you want to reuse an existing router, set create to false and use name to specify the desired router. | <code title="object&#40;&#123;&#10;  create &#61; optional&#40;bool, true&#41;&#10;  asn    &#61; optional&#40;number, 65001&#41;&#10;  bfd &#61; optional&#40;object&#40;&#123;&#10;    min_receive_interval        &#61; optional&#40;number&#41;&#10;    min_transmit_interval       &#61; optional&#40;number&#41;&#10;    multiplier                  &#61; optional&#40;number&#41;&#10;    session_initialization_mode &#61; optional&#40;string, &#34;ACTIVE&#34;&#41;&#10;  &#125;&#41;&#41;&#10;  custom_advertise &#61; optional&#40;object&#40;&#123;&#10;    all_subnets &#61; bool&#10;    ip_ranges   &#61; map&#40;string&#41;&#10;  &#125;&#41;&#41;&#10;  md5_authentication_key &#61; optional&#40;object&#40;&#123;&#10;    name &#61; string&#10;    key  &#61; optional&#40;string&#41;&#10;  &#125;&#41;&#41;&#10;  keepalive &#61; optional&#40;number&#41;&#10;  name      &#61; optional&#40;string, &#34;router&#34;&#41;&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> | ✓ |  |
| [admin_enabled](variables.tf#L17) | Whether the VLAN attachment is enabled. | <code>bool</code> |  | <code>true</code> |
| [dedicated_interconnect_config](variables.tf#L23) | Dedicated interconnect configuration. | <code title="object&#40;&#123;&#10;  bandwidth    &#61; optional&#40;string, &#34;BPS_10G&#34;&#41;&#10;  bgp_range    &#61; optional&#40;string&#41;&#10;  bgp_priority &#61; optional&#40;number&#41;&#10;  interconnect &#61; string&#10;  vlan_tag     &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [ipsec_gateway_ip_ranges](variables.tf#L41) | IPSec Gateway IP Ranges. | <code>map&#40;string&#41;</code> |  | <code>&#123;&#125;</code> |
| [mtu](variables.tf#L47) | The MTU associated to the VLAN attachment (1440 / 1500). | <code>number</code> |  | <code>1500</code> |
| [partner_interconnect_config](variables.tf#L63) | Partner interconnect configuration. | <code title="object&#40;&#123;&#10;  edge_availability_domain &#61; string&#10;&#125;&#41;">object&#40;&#123;&#8230;&#125;&#41;</code> |  | <code>null</code> |
| [vpn_gateways_ip_range](variables.tf#L115) | The IP range (cidr notation) to be used for the GCP VPN gateways. If null IPSec over Interconnect is not enabled. | <code>string</code> |  | <code>null</code> |

## Outputs

| name | description | sensitive |
|---|---|:---:|
| [attachment](outputs.tf#L17) | VLAN Attachment resource. |  |
| [id](outputs.tf#L22) | Fully qualified VLAN attachment id. |  |
| [md5_configuration](outputs.tf#L27) | MD5 configuration. |  |
| [name](outputs.tf#L38) | The name of the VLAN attachment created. |  |
| [pairing_key](outputs.tf#L43) | Opaque identifier of an PARTNER attachment used to initiate provisioning with a selected partner. |  |
| [router](outputs.tf#L48) | Router resource (only if auto-created). |  |
| [router_interface](outputs.tf#L53) | Router interface created for the VLAN attachment. |  |
| [router_name](outputs.tf#L58) | Router name. |  |
<!-- END TFDOC -->
