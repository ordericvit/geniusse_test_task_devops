output "cluster_name" {
  value     = "${google_container_cluster.primary.name}"
}

output "client_certificate" {
  value     = "${google_container_cluster.primary.master_auth.0.client_certificate}"
 sensitive = true
}

output "cluster_ca_certificate" {
  value     = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
 sensitive = true
}

output "host" {
  value     = "${google_container_cluster.primary.endpoint}"
 sensitive = true
}
