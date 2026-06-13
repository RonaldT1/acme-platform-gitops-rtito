output "network_id" {
  value = google_compute_network.this.id
}

output "network_name" {
  value = google_compute_network.this.name
}

output "subnet_ids" {
  value = { for k, v in google_compute_subnetwork.this : k => v.id }
}

output "cloud_router_name" {
  value = var.enable_cloud_nat ? google_compute_router.this[0].name : null
}

output "cloud_nat_name" {
  value = var.enable_cloud_nat ? google_compute_router_nat.this[0].name : null
}
