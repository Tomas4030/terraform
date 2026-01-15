# terraform/backend.tf

resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend"
    namespace = var.namespace
    labels = { app = "backend" }
  }

  spec {
    replicas = 1
    selector { match_labels = { app = "backend" } }
    template {
      metadata { labels = { app = "backend" } }
      spec {
        container {
          name  = "backend"
          image = "backend:latest"
          image_pull_policy = "IfNotPresent"
            port {
                container_port = 8000
            }

          env_from {
            secret_ref { name = "app-secret" }
          }

          resources {
            requests = { memory = "128Mi", cpu = "250m" }
            limits   = { memory = "512Mi", cpu = "500m" }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend"
    namespace = var.namespace
    labels = {
        app = "backend"
    }
    }

  spec {
    selector = { app = "backend" }
    port {
      port        = 8000
      target_port = 8000
      protocol    = "TCP"
    }
    type = "ClusterIP"
  }
}
