# aider-quickstart

Run [aider](https://aider.chat) in a Docker container with pre-configured settings and shell helpers, using GitHub Copilot as the LLM provider.

## What's Included

| File | Purpose |
|---|---|
| `Dockerfile` | Builds the `aider-docker` image with aider pre-installed |
| `.aider.conf.yml` | Default aider configuration (model, provider, conventions, etc.) |
| `CONVENTIONS.md` | Baseline coding conventions for the AI agent, loaded in every session |
| `.env.example` | Template for your `.env` file with Copilot API credentials |
| `setup.sh` | Builds the image and installs shell functions into `~/.bashrc` |

## Prerequisites

- Docker
- A GitHub Copilot subscription
- A Copilot OAuth token (see below)

## Obtaining a Copilot OAuth Token

Aider connects to GitHub Copilot via its OpenAI-compatible API at `https://api.githubcopilot.com`. You need an OAuth token to authenticate.

The easiest way to get one is to sign in to Copilot from a JetBrains IDE (PyCharm, GoLand, etc.). After you authenticate, a file appears at:

```
~/.config/github-copilot/apps.json
```

On Windows:

```
%LOCALAPPDATA%\github-copilot\apps.json
```

Copy the `oauth_token` value from that file -- that string is your API key.

## Setting Up .env

Copy the example and fill in your token:

```bash
cp .env.example ~/.env
# Edit ~/.env and replace <your-copilot-oauth-token> with the real token
```

The `.env` file will be bind-mounted into the container at runtime.

## Quick Start

```bash
git clone <repo-url> && cd aider-quickstart
bash setup.sh
source ~/.bashrc
```

`setup.sh` will:
1. Build the `aider-docker` Docker image
2. Back up your current `~/.bashrc`
3. Add (or update) the `aider` and `aidcmd` shell functions, showing diffs and asking for confirmation if they already exist
4. Display the changes made and optionally delete the backup

## Usage

### Interactive Mode

Run aider in the current directory:

```bash
aider
```

This mounts `$PWD` into the container at `/app` and bind-mounts `~/.env` for API credentials.

### One-Shot Commands

Pass a message directly to aider:

```bash
aider --message "explain this codebase"
```

### aidcmd

Generate a shell command from a natural-language description:

```bash
aidcmd find all TODO comments in this project
```

## Configuration

Edit `.aider.conf.yml` to change the model, provider, or other settings. The config is baked into the image at `/home/devuser/.aider.conf.yml`.

See the [aider configuration docs](https://aider.chat/docs/config/aider_conf.html) for all available options.

### Discovering Available Models

List the models your Copilot subscription provides:

```bash
curl -s https://api.githubcopilot.com/models \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Copilot-Integration-Id: vscode-chat" | jq -r '.data[].id'
```

Each returned ID can be used with aider by prefixing it with `openai/`. For example:

```bash
aider --model openai/gpt-4o
aider --model openai/claude-sonnet-4-20250514
```

To change the default model, edit the `model` field in `.aider.conf.yml` and rebuild the image.

### Coding Conventions

`CONVENTIONS.md` is copied into the image and referenced via the `read` field in `.aider.conf.yml`. It provides baseline coding conventions for every aider session.

If a repository mounted into `/app` contains its own `CONVENTIONS.md`, you can add it to the chat with `/read CONVENTIONS.md` to layer project-specific conventions on top of the global ones.

## Rebuilding

After changing `Dockerfile`, `.aider.conf.yml`, or `CONVENTIONS.md`, rebuild:

```bash
docker build -t aider-docker .
```

Or re-run `setup.sh` which rebuilds automatically.
