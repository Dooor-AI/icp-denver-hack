# sidecar/Dockerfile
FROM --platform=linux/amd64 ubuntu:22.04

# Instalar dependências
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    python3 \
    python3-pip \
    git \
    openssl

# Instalar Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Configurar para compilação x86_64
RUN . $HOME/.cargo/env && \
    rustup target add x86_64-unknown-linux-gnu

# Clonar e compilar snpguest
RUN . $HOME/.cargo/env && \
    git clone https://github.com/virtee/snpguest.git && \
    cd snpguest && \
    cargo build --release --target x86_64-unknown-linux-gnu && \
    cp target/x86_64-unknown-linux-gnu/release/snpguest /usr/local/bin/ && \
    cd .. && rm -rf snpguest

# Instalar dependências Python
RUN pip3 install flask requests

# Copiar scripts
COPY verify-attestation.sh /usr/local/bin/
COPY api.py /usr/local/bin/
COPY start.sh /usr/local/bin/

# Tornar executável
RUN chmod +x /usr/local/bin/verify-attestation.sh \
    /usr/local/bin/api.py \
    /usr/local/bin/start.sh

EXPOSE 8080
CMD ["/usr/local/bin/start.sh"]