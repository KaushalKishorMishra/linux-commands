#!/bin/bash

# Open VS Code for frontend
~/.local/bin/zed /mnt/kaushal/Tech/Office/Arbyte/tangible/tangible-vite/frontend

# Start a new tmux session named 'dev'
tmux new-session -d -s dev

# Create first window named 'back' and split into two panes
# Both panes will start in /mnt/kaushal/Tech/Office/Arbyte/tangible/tangible-vite/backend
tmux rename-window -t dev:1 back
tmux send-keys -t dev:1 "cd /mnt/kaushal/Tech/Office/Arbyte/tangible/tangible-vite/backend" C-m
tmux send-keys -t dev:1 "yarn dev" C-m
tmux split-window -h -t dev:1 back
tmux send-keys -t dev:1.1 "cd /mnt/kaushal/Tech/Office/Arbyte/tangible/tangible-vite/backend" C-m

# Create second window named 'front' and split into two panes
# Both panes will start in /mnt/kaushal/Tech/Office/Arbyte/tangible/tangible-vite/frontend
tmux new-window -t dev:2 -n front
tmux send-keys -t dev:2 "cd /mnt/kaushal/Tech/Office/Arbyte/tangible/tangible-vite/frontend" C-m
tmux send-keys -t dev:2 "yarn dev" C-m
tmux split-window -h -t dev:2
tmux send-keys -t dev:2.1 "cd /mnt/kaushal/Tech/Office/Arbyte/tangible/tangible-vite/frontend" C-m
