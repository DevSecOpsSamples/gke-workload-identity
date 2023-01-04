module "autopilot-cluster" {
  source = "./autopilot-cluster"
}

module "standard-cluster" {
  source = "./standard-cluster"
}

module "workload-identity" {
  source = "./workload-identity"
}