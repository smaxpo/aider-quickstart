# aider-quickstart

Run [aider](https://aider.chat) in a Docker container with pre-configured settings and shell helpers, using GitHub Copilot as the LLM provider.

## What's Included

| File | Purpose |
|---|---|
| `Dockerfile` | Builds the `aider-docker` image with aider pre-installed |
| `entrypoint.sh` | Handles GitHub Copilot device code authentication before launching aider |
| `.aider.conf.yml` | Default aider configuration (model, provider, conventions, etc.) |
| `CONVENTIONS.md` | Baseline coding conventions for the AI agent, loaded in every session |
| `setup.sh` | Builds the image and installs shell functions into `~/.bashrc` |

## Prerequisites

- Docker
- A GitHub Copilot subscription

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

## Authentication

On first run, the container performs the GitHub device code flow:

```
No Copilot OAuth token found. Starting device code authentication...

Please visit: https://github.com/login/device
Enter code:   ABCD-1234

Waiting for authorization (expires in 15 minutes)...
Authentication successful! Token saved.
```

Open the URL in your browser, enter the code displayed in the terminal, and authorize the application. The OAuth token is saved to `~/.config/aider-copilot/auth.json` on the host and reused for all subsequent sessions -- you only need to authenticate once.

To re-authenticate (e.g. if the token expires), delete the saved token and run aider again:

```bash
rm ~/.config/aider-copilot/auth.json
aider
```

## Usage

### Interactive Mode

Run aider in the current directory:

```bash
aider
```

This mounts `$PWD` into the container at `/app` and persists authentication state via `~/.config/aider-copilot`.

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

List the models your Copilot subscription provides. First, ensure you have authenticated (run `aider` once), then:

```bash
TOKEN=$(python3 -c "import json; print(json.load(open('$HOME/.config/aider-copilot/auth.json'))['oauth_token'])")
curl -s https://api.githubcopilot.com/models \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Copilot-Integration-Id: vscode-chat" | python3 -m json.tool
```

Each model ID can be used with aider by prefixing it with `openai/`. For example:

```bash
aider --model openai/gpt-4o
aider --model openai/claude-sonnet-4-20250514
```

To change the default model, edit the `model` field in `.aider.conf.yml` and rebuild the image.

### Coding Conventions

`CONVENTIONS.md` is copied into the image and referenced via the `read` field in `.aider.conf.yml`. It provides baseline coding conventions for every aider session.

If a repository mounted into `/app` contains its own `CONVENTIONS.md`, you can add it to the chat with `/read CONVENTIONS.md` to layer project-specific conventions on top of the global ones.

## Rebuilding

After changing `Dockerfile`, `.aider.conf.yml`, `CONVENTIONS.md`, or `entrypoint.sh`, rebuild:

```bash
docker build -t aider-docker .
```

Or re-run `setup.sh` which rebuilds automatically.
