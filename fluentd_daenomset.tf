data "aws_elasticsearch_domain" "example" {
  domain_name = "example"
}


locals {
  name = "fluentd"

  labels = {
    k8s-app = "fluentd-logging"
    version = "v1"
    test = "MyExampleApp"
  }

  env_variables = {
    "HOST" : "${data.aws_elasticsearch_domain.example.endpoint}"
    "PORT" : "443",
    "SCHEME" : "http",
    "USER" : "elastic",
    "PASSWORD" : "changeme"
  }


}

resource "kubernetes_daemonset" "fluentd" {
  metadata {
    name      = local.name
    namespace = "kube-system"

    labels = local.labels
  }

  spec {
    selector {
      match_labels = {
        k8s-app = local.labels.k8s-app
        test = local.labels.test
      }
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        volume {
          name = "varlog"

          host_path {
            path = "/var/log"
          }
        }

        volume {
          name = "varlibdockercontainers"

          host_path {
            path = "/var/lib/docker/containers"
          }
        }

        container {
          name  = local.name
          image = "fluent/fluentd-kubernetes-daemonset:v1-debian-elasticsearch"

          dynamic "env" {
            for_each = local.env_variables
            content {
              name  = "FLUENT_ELASTICSEARCH_${env.key}"
              value = env.value
            }
          }

          resources {
            limits {
              memory = "200Mi"
            }

            requests {
              cpu    = "100m"
              memory = "200Mi"
            }
          }

          volume_mount {
            name       = "varlog"
            mount_path = "/var/log"
          }

          volume_mount {
            name       = "varlibdockercontainers"
            read_only  = true
            mount_path = "/var/lib/docker/containers"
          }
        }

        termination_grace_period_seconds = 30
        service_account_name             = local.name
      }
    }
  }
}
