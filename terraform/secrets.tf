resource "kubernetes_secret" "postgres" {
  metadata {
    name      = "postgres-secret"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    POSTGRES_USER     = base64encode(var.postgres_user)
    POSTGRES_PASSWORD = base64encode(var.postgres_password)
    POSTGRES_DB       = base64encode(var.postgres_db)
  }

  type = "Opaque"
}


resource "kubernetes_secret" "app" {
  metadata {
    name      = "app-secret"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    DATABASE_URL = base64encode("postgresql://...")
    SECRET_KEY  = base64encode("supersecret")
  }
}

