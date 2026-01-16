resource "kubernetes_secret" "postgres" {
  metadata {
    name      = "postgres-secret"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    POSTGRES_USER     = var.postgres_user
    POSTGRES_PASSWORD = var.postgres_password
    POSTGRES_DB       = var.postgres_db
  }

  type = "Opaque"
}


resource "kubernetes_secret" "app" {
  metadata {
    name      = "app-secret"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    SECRET_KEY = "UMA_CHAVE_MUITO_SEGURA"
    ALGORITHM = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES = "120"

    DATABASE_DRIVER   = "postgresql"
    DATABASE_USERNAME = var.postgres_user
    DATABASE_PASSWORD = var.postgres_password
    DATABASE_HOST     = "postgres"
    DATABASE_PORT     = "5432"
    DATABASE_NAME     = var.postgres_db
  }

}

