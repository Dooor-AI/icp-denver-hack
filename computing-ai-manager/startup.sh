#!/bin/bash

# Aguardar o diretório /data estar disponível
max_retries=30
count=0
while [ ! -d "/data" ] && [ $count -lt $max_retries ]; do
    echo "Waiting for /data directory to be mounted... ($count/$max_retries)"
    sleep 2
    count=$((count + 1))
done

if [ ! -d "/data" ]; then
    echo "Error: /data directory not available after waiting"
    exit 1
fi

# Criar arquivo de créditos se não existir
if [ ! -f "/data/user_credits.json" ]; then
    echo "{}" > /data/user_credits.json
    chmod 666 /data/user_credits.json
fi

# Garantir permissões corretas
chmod 777 /data
chmod 666 /data/user_credits.json

# Iniciar Ollama
ollama serve &

# Aguardar Ollama iniciar
while ! curl -s http://localhost:11434/api/tags >/dev/null; do
    echo "Waiting for Ollama to start..."
    sleep 1
done

# Download do modelo de teste
echo "Downloading test model..."
ollama pull nomic-embed-text:latest

# Iniciar Flask com Gunicorn
echo "Starting Flask application..."
exec gunicorn -w 4 -b 0.0.0.0:8080 --timeout 6000 app:app