FROM python:3.12-slim

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

RUN useradd -m devuser
USER devuser

RUN pip install --no-cache-dir aider-chat

COPY --chown=devuser:devuser .aider.conf.yml /home/devuser/.aider.conf.yml
COPY --chown=devuser:devuser CONVENTIONS.md /home/devuser/CONVENTIONS.md

WORKDIR /app
ENTRYPOINT ["aider"]
