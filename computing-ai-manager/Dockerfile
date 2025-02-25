FROM python:3.9-slim

ENV APP_DIR=/app
ENV DATA_DIR=/data

# Instalar apenas dependências essenciais
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Instalar Ollama
RUN curl -L https://ollama.ai/install.sh | sh

# Configurar diretório e dependências Python mínimas
WORKDIR ${APP_DIR}

# Copiar arquivos de configuração
COPY requirements-light.txt .

# Limpar cache pip e instalar dependências com versões específicas
RUN pip cache purge && \
    pip install --no-cache-dir -r requirements-light.txt

# Copiar código da aplicação
COPY app.py .
COPY startup.sh .
RUN chmod +x startup.sh

EXPOSE 8080
EXPOSE 11434

# Create volume for persistent data
VOLUME ["/data"]

# Modify the CMD to use the data directory
ENV CREDITS_FILE=/data/user_credits.json
ENV MODELS_FILE=/data/models.json
ENV MODELS_FOLDER=/data/models
CMD ["./startup.sh"]
