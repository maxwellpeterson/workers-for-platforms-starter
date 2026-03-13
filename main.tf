terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.18.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "cloudflare_zone" "target" {
  filter = {
    name = var.zone_name
    account = {
      id = var.account_id
    }
  }
}

resource "cloudflare_worker" "app_gateway" {
  account_id = var.account_id
  name       = "app-gateway"
}

resource "cloudflare_workers_for_platforms_dispatch_namespace" "apps" {
  account_id = var.account_id
  name       = "apps"
}

resource "cloudflare_worker_version" "app_gateway_v1" {
  account_id         = var.account_id
  worker_id          = cloudflare_worker.app_gateway.id
  compatibility_date = "2026-03-13"
  main_module        = "index.js"

  modules = [{
    name         = "index.js"
    content_type = "application/javascript+module"
    content_file = "${path.module}/build/index.js"
  }]

  bindings = [{
    name      = "APPS"
    type      = "dispatch_namespace"
    namespace = cloudflare_workers_for_platforms_dispatch_namespace.apps.name
  }]
}

resource "cloudflare_workers_deployment" "app_gateway" {
  account_id  = var.account_id
  script_name = cloudflare_worker.app_gateway.name
  strategy    = "percentage"

  versions = [{
    version_id = cloudflare_worker_version.app_gateway_v1.id
    percentage = 100
  }]
}

resource "cloudflare_workers_custom_domain" "app_gateway_apps" {
  account_id  = var.account_id
  zone_id     = data.cloudflare_zone.target.id
  hostname    = "apps.${var.zone_name}"
  service     = cloudflare_worker.app_gateway.name
  environment = "production"
}
