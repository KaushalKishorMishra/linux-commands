#!/bin/bash

# Improved helper function to detect dev/start/server scripts
get_dev_command() {
  local dir="$1"
  local pkg_json="$dir/package.json"
  if [ -f "$pkg_json" ]; then
    # Check for dev/start/server scripts in priority order
    local cmd=$(jq -r '.scripts | .dev // .start // .server // empty' "$pkg_json")
    [ -n "$cmd" ] && echo "yarn $cmd" || echo ""
  fi
}

session_name=$(basename "$PWD")

# Check for existing session
if tmux has-session -t "$session_name" 2>/dev/null; then
  echo "Session '$session_name' is already running."
  exit 0
fi

declare -a windows_to_create
declare -a commands_to_run

# Check parent directory
if [ -f "package.json" ] || [ -f "yarn.lock" ] || [ -f "package-lock.json" ]; then
  dev_cmd=$(get_dev_command ".")
  windows_to_create+=("root")
  commands_to_run+=("$dev_cmd")
fi

# Process subdirectories
for dir in */; do
  dir_name="${dir%/}"
  [ -d "$dir" ] || continue

  if [ -d "$dir/.git" ]; then
    dev_cmd=$(get_dev_command "$dir")
    windows_to_create+=("$dir_name")
    commands_to_run+=("$dev_cmd")
  else
    printf "Directory '%s' has no .git repo. Initialize git? (y/N): " "$dir_name"
    read -r git_init
    if [[ "$git_init" =~ ^[Yy]$ ]]; then
      (cd "$dir" && git init)
      echo "Initialized git in $dir_name"
      dev_cmd=$(get_dev_command "$dir")
      windows_to_create+=("$dir_name")
      commands_to_run+=("$dev_cmd")
    fi
  fi
done

# Create tmux session and windows
tmux new-session -d -s "$session_name" -n "${windows_to_create[0]}"
tmux send-keys -t "$session_name:1" "cd \"${windows_to_create[0]#root}\"" C-m
[ -n "${commands_to_run[0]}" ] && tmux send-keys -t "$session_name:1" "${commands_to_run[0]}" C-m

# Create additional windows
for i in "${!windows_to_create[@]}"; do
  [ "$i" -eq 0 ] && continue
  tmux new-window -t "$session_name:" -n "${windows_to_create[$i]}"
  tmux send-keys -t "$session_name:$((i + 1))" "cd \"${windows_to_create[$i]}\"" C-m
  [ -n "${commands_to_run[$i]}" ] && tmux send-keys -t "$session_name:$((i + 1))" "${commands_to_run[$i]}" C-m
done

tmux attach-session -t "$session_name"
