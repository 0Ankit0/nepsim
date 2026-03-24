#!/bin/bash
# tmux is required for this to work

tmux new-session -d -s nepsim 'cd backend && source .venv/bin/activate && task start'
tmux split-window -h -t nepsim 'cd frontend && bun run dev'
tmux attach -t nepsim