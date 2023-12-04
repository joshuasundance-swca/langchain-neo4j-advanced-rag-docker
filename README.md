# langchain-neo4j-advanced-rag-docker

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![python](https://img.shields.io/badge/Python-3.11-3776AB.svg?style=flat&logo=python&logoColor=white)](https://www.python.org)

[![Push to Docker Hub](https://github.com/joshuasundance-swca/langchain-neo4j-advanced-rag-docker/actions/workflows/docker-hub.yml/badge.svg)](https://github.com/joshuasundance-swca/langchain-neo4j-advanced-rag-docker/actions/workflows/docker-hub.yml)
[![langchain-neo4j-advanced-rag-docker on Docker Hub](https://img.shields.io/docker/v/joshuasundance/langchain-neo4j-advanced-rag-docker?label=langchain-neo4j-advanced-rag-docker&logo=docker)](https://hub.docker.com/r/joshuasundance/langchain-neo4j-advanced-rag-docker)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/joshuasundance/langchain-neo4j-advanced-rag-docker/latest)](https://hub.docker.com/r/joshuasundance/langchain-neo4j-advanced-rag-docker)

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Ruff](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/charliermarsh/ruff/main/assets/badge/v1.json)](https://github.com/charliermarsh/ruff)
[![Checked with mypy](http://www.mypy-lang.org/static/mypy_badge.svg)](http://mypy-lang.org/)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

[![security: bandit](https://img.shields.io/badge/security-bandit-yellow.svg)](https://github.com/PyCQA/bandit)
![Known Vulnerabilities](https://snyk.io/test/github/joshuasundance-swca/langchain-neo4j-advanced-rag-docker/badge.svg)

This repo provides a docker setup to run the LangChain neo4j-advanced-rag template using langserve.

- [Relevant LangChain documentation](https://python.langchain.com/docs/templates/neo4j-advanced-rag)


- Example LangSmith traces (using the Dune content from the template)
  - [_What is spice?_](https://smith.langchain.com/public/27a7ac53-6a4a-4245-8fcf-a685d2680f36/r)
  - [_Who are the main characters?_](https://smith.langchain.com/public/ff11d4ac-fb30-474d-bb56-ece908cf695f/r)

## Quickstart

### Docker Compose (_recommended_)

1. Create a `.env` file:

```.env
OPENAI_API_KEY=sk-...

LANGCHAIN_API_KEY=ls__...
LANGCHAIN_ENDPOINT=https://api.smith.langchain.com
LANGCHAIN_TRACING_V2=true
LANGCHAIN_PROJECT="langchain-neo4j-advanced-rag-docker"

NEO4J_PASSWORD=langchain-neo4j-advanced-rag-docker
```

2. Create a `docker-compose.yml` file:

```docker-compose.yml
version: '3.8'

services:
  neo4j:
    image: neo4j:5.14.0
    container_name: neo4j
    volumes:
      - neo4j-data:/data
    environment:
      - "NEO4J_AUTH=neo4j/${NEO4J_PASSWORD:-langchain-neo4j-advanced-rag-docker}"
      - "NEO4J_PLUGINS=[\"apoc\"]"
    networks:
      - langchain-neo4j-advanced-rag-docker
    healthcheck:
      test: wget http://localhost:7474 || exit 1
      interval: 1s
      timeout: 10s
      retries: 20
      start_period: 3s
    restart: always

  neo4j-init:
    image: joshuasundance/langchain-neo4j-advanced-rag-docker:1.0.1
    container_name: neo4j-init
    environment:
      - "OPENAI_API_KEY=${OPENAI_API_KEY:?}"
      - "NEO4J_URI=bolt://neo4j:7687"
      - "NEO4J_USERNAME=neo4j"
      - "NEO4J_PASSWORD=${NEO4J_PASSWORD:-langchain-neo4j-advanced-rag-docker}"
      - "LANGCHAIN_API_KEY=${LANGCHAIN_API_KEY-placeholder}"
      - "LANGCHAIN_TRACING_V2=${LANGCHAIN_TRACING_V2:-false}"
      - "LANGCHAIN_PROJECT=${LANGCHAIN_PROJECT:-langchain-neo4j-advanced-rag-docker}"
    depends_on:
      neo4j:
        condition: service_healthy
    networks:
      - langchain-neo4j-advanced-rag-docker
    command: ["/bin/bash", "/home/appuser/neo4j-advanced-rag/ingest.sh"]

  langchain-neo4j-advanced-rag-docker:
    image: joshuasundance/langchain-neo4j-advanced-rag-docker:1.0.1
    container_name: langchain-neo4j-advanced-rag-docker
    environment:
      - "OPENAI_API_KEY=${OPENAI_API_KEY:?}"
      - "NEO4J_URI=bolt://neo4j:7687"
      - "NEO4J_USERNAME=neo4j"
      - "NEO4J_PASSWORD=${NEO4J_PASSWORD:-langchain-neo4j-advanced-rag-docker}"
      - "LANGCHAIN_API_KEY=${LANGCHAIN_API_KEY-placeholder}"
      - "LANGCHAIN_TRACING_V2=${LANGCHAIN_TRACING_V2:-false}"
      - "LANGCHAIN_PROJECT=${LANGCHAIN_PROJECT:-langchain-neo4j-advanced-rag-docker}"
    ports:
      - "${APP_PORT:-8000}:8000"
    depends_on:
      neo4j:
        condition: service_healthy
      neo4j-init:
        condition: service_completed_successfully
    networks:
      - langchain-neo4j-advanced-rag-docker

volumes:
  neo4j-data:

networks:
  langchain-neo4j-advanced-rag-docker:
    driver: bridge
```

3. Start the services using `docker compose up`


### Using Docker with an existing Neo4j instance
```bash
docker run -d --name langchain-neo4j-advanced-rag-docker \
  -e OPENAI_API_KEY=sk-... \
  -e LANGCHAIN_API_KEY=ls__... \
  -e LANGCHAIN_TRACING_V2=true \
  -e LANGCHAIN_PROJECT=langchain-neo4j-advanced-rag-docker \
  -e NEO4J_URI=... \
  -e NEO4J_USERNAME=... \
  -e NEO4J_PASSWORD=... \
  -p 8000:8000 \
  joshuasundance/langchain-neo4j-advanced-rag-docker:1.0.1
```

## Usage

- The service will be available at `http://localhost:8000`.
- You can access the OpenAPI documentation at `http://localhost:8000/docs`, `http://localhost:8000/redoc`, and `http://localhost:8000/openapi.json`.
- Access the Research Playground at `http://127.0.0.1:8000/neo4j-advanced-rag/playground/`.

- You can also use the `RemoteRunnable` class to interact with the service:

```python
from langserve.client import RemoteRunnable

runnable = RemoteRunnable("http://localhost:8000/neo4j-advanced-rag")
```

See the [LangChain docs](https://python.langchain.com/docs/templates/neo4j-advanced-rag) for more information.
