FROM python:3.12-slim

RUN apt-get update && apt-get install -y curl git && rm -rf /var/lib/apt/lists/*

RUN useradd -m devuser
USER devuser

RUN pip install --no-cache-dir aider-chat

USER root
RUN mkdir -p /home/devuser/.config/aider-copilot \
 && chown -R devuser:devuser /home/devuser/.config
USER devuser

COPY --chown=devuser:devuser .aider.conf.yml /home/devuser/.aider.conf.yml
COPY --chown=devuser:devuser CONVENTIONS.md /home/devuser/CONVENTIONS.md
COPY --chown=devuser:devuser entrypoint.sh /home/devuser/entrypoint.sh

WORKDIR /app
ENTRYPOINT ["/home/devuser/entrypoint.sh"]
