# STAGE 1: Rust Builder (Standard Debian-based)
FROM rust:1.75-slim AS rust-builder
WORKDIR /app
COPY ./encryptor .
# Build normally for the standard Debian architecture
RUN cargo build --release

###################################################

# STAGE 1: Rust Builder (Standard Debian-based)
FROM python:3.11-slim AS python-builder
WORKDIR /py_app
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
COPY ./python/requirements.txt .
RUN pip install -r requirements.txt

########################################

# STAGE 2: TypeScript Builder
FROM node:20 AS base
WORKDIR /var/www/html/backend
COPY . .
RUN npm install typescript -g && npx tsc

###################################################

# STAGE 3: Production (Matching the Builder's OS)
FROM debian:11-slim AS prod
WORKDIR /var/www/html/backend

RUN if ! id -u himanshu > /dev/null 2>&1; then \
  useradd -m himanshu -s /bin/bash; \
fi

RUN chown himanshu:root .

# Download and install nvm:
RUN apt-get update && apt-get install -y curl ca-certificates gnupg \
  && mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_24.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
  && apt-get update && apt-get install -y nodejs python3 --no-install-recommends \
  && npm install -g pm2 \
  && rm -rf /var/lib/apt/lists/*

# 4. NOW this will work perfectly!
RUN which node
RUN node -v

# Ensure the virtual env is in the PATH so 'python3' uses your installed libs
ENV PATH="/opt/venv/bin:$PATH"

# 1. Copy the Python Virtual Env from the builder
COPY --from=python-builder --chown=himanshu:root /opt/venv /opt/venv

RUN chmod -R +x /opt/venv/bin

# Install PM2
RUN npm install -g pm2 

# Copy package files and install production dependencies
COPY --from=base --chown=himanshu:root /var/www/html/backend/src/package*.json ./

# Copy the compiled JS
COPY --from=base --chown=himanshu:root /var/www/html/backend/dist ./

# Copy the Rust binary (Note the path change: no musl here!)
COPY --from=rust-builder --chown=himanshu:root /app/target/release/encryptor ./bin/
RUN chmod +x ./bin/encryptor

COPY --chown=himanshu:root ./python ./python

EXPOSE 8000

USER himanshu

RUN npm install --only=production

CMD ["pm2-runtime", "start", "index.js", "--name", "server"]