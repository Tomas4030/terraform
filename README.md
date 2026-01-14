# 📂 Aplicação Fullstack K8s

Esta é uma aplicação de três camadas (Frontend, Backend e Base de Dados) totalmente conteinerizada e orquestrada via Kubernetes. 
O projeto demonstra o uso de volumes persistentes, segredos, configurações dinâmicas e exposição via Ingress.

## 🏗️ Arquitetura do Projeto

A aplicação segue a estrutura clássica de 3 camadas:

1. **Frontend**: Interface Web acessível via navegador.
2. **Backend**: API que processa a lógica de negócio.
3. **Database**: Base de dados relacional com persistência de dados.

```text
[ Utilizador ] ----> [ Ingress ] ----> [ Service: Frontend ]
                                            |
                                    [ Service: Backend ]
                                            |
                                    [ StatefulSet: DB ] <--- [ PVC/StorageClass ]

```

---

## 🛠️ Tecnologias Utilizadas

* **Minikube**: Cluster local.
* **Kubernetes**: Orquestração de containers.
* **PostgreSQL**: Armazenamento de dados.
* **Ingress Controller**: Gestão de acesso externo.

---

## 🚀 **Como Executar**  

### 1. Pré-requisitos

Certifique-se de ter instalado:

* [Docker](https://docs.docker.com/get-docker/)

### 2. Instalação e Inicialização

Ao executar o script de start, o projeto será totalmente preparado: todas as imagens são construídas, os recursos aplicados no cluster e as portas necessárias expostas automaticamente. No final do processo, o terminal irá mostrar o link para aceder à aplicação. Basta abrir esse link no navegador para começar a usar a interface.

🚀 **Como Executar**  
Para garantir que a aplicação é configurada corretamente, segue os passos abaixo no teu terminal.

### 1. Permissões de Execução
Antes de executar os scripts, é necessário conceder permissões para que o sistema os possa executar:

```bash
chmod +x ./scripts/start.sh
chmod +x ./scripts/test.sh
chmod +x ./scripts/cleanup.sh
```

### 2. Iniciar a Implementação
Agora, executa o script principal para preparar o cluster e instalar todos os componentes:

```bash
./scripts/start.sh

```

## 🧪 Testes de Validação

Para verificar se todos os componentes estão saudáveis, execute:

```bash
./scripts/test.sh

```

O script verificará o estado dos Pods, Services e a conectividade da base de dados.

---

## 🧹 Limpeza do Ambiente

Para remover todos os recursos criados e parar o cluster:

```bash
./scripts/cleanup.sh

```

---

## 📂 Estrutura do Repositório

```text
CStrader/
├── backend/
│   ├── src/
│   │   ├── database.py
│   │   ├── db_models.py
│   │   ├── models.py
│   │   ├── main.py
│   │   └── settings.py
│   └── tests/
├── infra/
│   ├── backend/        # Deployment e Service da API
│   ├── database/       # StatefulSet, PVC e Service do DB
│   ├── frontend/       # Deployment e Service da Interface
│   ├── ingress/        # Configuração do Ingress Controller
│   └── config/         # ConfigMaps e Secrets
├── scripts/            # Scripts de automação (.sh)
├── .env.example
├── docker-compose.yml
├── Makefile
├── pyproject.toml
└── README.md


```

