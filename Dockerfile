FROM python:3.11-slim-bookworm

RUN apt-get update && apt-get install -y git && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN adduser --uid 1000 --disabled-password --gecos '' appuser
USER 1000

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/home/appuser/.local/bin:$PATH" \
    PYTHONPATH="/home/appuser/neo4j-advanced-rag/packages/neo4j-advanced-rag:$PYTHONPATH"

RUN pip install --user --no-cache-dir --upgrade pip

COPY ./requirements.txt /home/appuser/requirements.txt
RUN pip install --user --no-cache-dir  --upgrade -r /home/appuser/requirements.txt

WORKDIR /home/appuser

RUN langchain app new neo4j-advanced-rag --package neo4j-advanced-rag --pip

COPY ./check_for_data.py /home/appuser/neo4j-advanced-rag/check_for_data.py
COPY ./ingest.sh /home/appuser/neo4j-advanced-rag/ingest.sh
COPY ./server.py /home/appuser/neo4j-advanced-rag/app/server.py

WORKDIR /home/appuser/neo4j-advanced-rag

EXPOSE 8000

CMD ["langchain", "serve", "--host", "0.0.0.0", "--port", "8000"]
