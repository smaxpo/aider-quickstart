BASHRC="$HOME/.bashrc"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Build the Docker image
echo "Building aider-docker image..."
docker build -t aider-docker "$SCRIPT_DIR"

# Backup current .bashrc
cp "$BASHRC" ./bashrc.bak
echo "Backed up $BASHRC to ./bashrc.bak"

# Define the new function bodies
read -r -d '' NEW_AIDER <<'FUNC' || true
aider () {
  local image="aider-docker"
  if ! docker image inspect "$image" >/dev/null 2>&1; then
    echo "Error: Docker image '$image' not found. Build it with: docker build -t $image <path-to-repo>"
    return 1
  fi

  local env_args=()
  if [ -f "$HOME/.env" ]; then
    env_args=(-v "$HOME/.env:/app/.env")
  else
    echo "Warning: ~/.env not found. Create it from .env.example with your Copilot OAuth token."
  fi

  docker run --rm -it \
    -v "$PWD:/app" \
    -w "/app" \
    "${env_args[@]}" \
    "$image" "$@"
}
FUNC

read -r -d '' NEW_AIDCMD <<'FUNC' || true
aidcmd () {
  if [ $# -eq 0 ]; then
    echo "Usage: aidcmd <what you want to do>" >&2
    return 2
  fi

  local req="$*"
  aider --yes-always --message \
    "Output ONLY the single shell command to run (one line). No markdown, no backticks, no explanation. Task: ${req}"
}
FUNC

# Extract an existing function block from .bashrc
# Usage: extract_function <func_name>
extract_function () {
  local name="$1"
  awk -v fn="$name" '
    $0 ~ "^"fn" \\(\\)" { found=1; depth=0 }
    found {
      print
      for (i=1; i<=length($0); i++) {
        c = substr($0,i,1)
        if (c == "{") depth++
        if (c == "}") depth--
      }
      if (depth == 0 && found) { found=0 }
    }
  ' "$BASHRC"
}

# Remove an existing function block from .bashrc (in-place)
# Usage: remove_function <func_name>
remove_function () {
  local name="$1"
  local tmp
  tmp=$(mktemp)
  awk -v fn="$name" '
    $0 ~ "^"fn" \\(\\)" { found=1; depth=0 }
    found {
      for (i=1; i<=length($0); i++) {
        c = substr($0,i,1)
        if (c == "{") depth++
        if (c == "}") depth--
      }
      if (depth == 0 && found) { found=0; next }
      next
    }
    { print }
  ' "$BASHRC" > "$tmp"
  mv "$tmp" "$BASHRC"
}

# Install or update a single function in .bashrc
# Usage: install_function <func_name> <new_body>
install_function () {
  local name="$1"
  local new_body="$2"
  local existing
  existing=$(extract_function "$name")

  if [ -n "$existing" ]; then
    if [ "$existing" = "$new_body" ]; then
      echo "'$name' is already up to date in $BASHRC."
      return 0
    fi
    echo ""
    echo "Function '$name' already exists in $BASHRC with differences:"
    echo ""
    diff --color=always \
      <(echo "$existing") \
      <(echo "$new_body") || true
    echo ""
    read -rp "Replace '$name' in $BASHRC? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      remove_function "$name"
      printf '\n%s\n' "$new_body" >> "$BASHRC"
      echo "Updated '$name'."
    else
      echo "Skipped '$name'."
    fi
  else
    printf '\n%s\n' "$new_body" >> "$BASHRC"
    echo "Added '$name' to $BASHRC."
  fi
}

install_function "aider" "$NEW_AIDER"
install_function "aidcmd" "$NEW_AIDCMD"

echo ""
echo "Changes made to $BASHRC:"
diff --color=always ./bashrc.bak "$BASHRC" || true

echo ""
read -rp "Delete backup ./bashrc.bak? [y/N] " del_answer
if [[ "$del_answer" =~ ^[Yy]$ ]]; then
  rm ./bashrc.bak
  echo "Deleted ./bashrc.bak."
else
  echo "Kept ./bashrc.bak."
fi

source $HOME/.bashrc
echo "Setup complete! You can now use 'aider' and 'aidcmd'."
