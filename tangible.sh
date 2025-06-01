#!/bin/bash

# Check if 'dev' tmux session already exists, return if it does
if tmux has-session -t dev 2>/dev/null; then
  echo "Session 'dev' is already running"
  exit 0
fi

# Open Zed editor for frontend
~/.local/bin/zed /mnt/kaushal/Tech/Office/Arbyte/tangible/tangible-vite/frontend

# Start a new tmux session named 'dev' and detach
tmux new-session -d -s dev

# Configure first window (named 'back') for backend
tmux rename-window -t dev:1 back
tmux send-keys -t dev:1 "cd /mnt/kaushal/Tech/Office/Arbyte/tangible/tangible-vite/backend" C-m
tmux send-keys -t dev:1 "yarn dev" C-m
tmux split-window -h -t dev:1
tmux send-keys -t dev:1.2 "cd /mnt/kaushal/Tech/Office/Arbyte/tangible/tangible-vite/backend" C-m

# Create second window (named 'front') for frontend
tmux new-window -t dev:2 -n front
tmux send-keys -t dev:2 "cd /mnt/kaushal/Tech/Office/Arbyte/tangible/tangible-vite/frontend" C-m
tmux send-keys -t dev:2 "yarn dev" C-m
tmux split-window -h -t dev:2
tmux send-keys -t dev:2.2 "cd /mnt/kaushal/Tech/Office/Arbyte/tangible/tangible-vite/frontend" C-m

# Attach to the tmux session
tmux attach-session -t dev
