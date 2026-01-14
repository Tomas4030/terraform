FROM python:3.11-slim

WORKDIR /app
ENV PYTHONPATH=/app

# Instalação de dependências do sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libpq-dev git && \
    pip install poetry && \
    rm -rf /var/lib/apt/lists/*

# --- CORREÇÃO DOS CAMINHOS ---
# 1. Copia os arquivos de configuração que estão na raiz do projeto
COPY pyproject.toml poetry.lock* ./

# 2. Instala as dependências
RUN poetry install --no-root --only main

# 3. Copia a pasta backend para dentro do container
COPY backend/ /app/backend/

EXPOSE 8000

# O comando assume que o main.py está em backend/src/main.py
CMD ["poetry", "run", "uvicorn", "backend.src.main:app", "--host", "0.0.0.0", "--port", "8000"]