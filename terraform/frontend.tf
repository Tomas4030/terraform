resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend"
    namespace = var.namespace
    labels = {
      app = "frontend"
    }
  }

  spec {
    replicas = 1
    

    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }

      spec {
        container {
          name  = "frontend"
          image = "frontend:latest"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 80
          }

          resources {
            requests = { memory = "128Mi", cpu = "250m" }
            limits   = { memory = "256Mi", cpu = "500m" }
          }
        }
      }
    }
  }
}
