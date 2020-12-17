#!/bin/bash

session_name="purrpubs"

tmux new-session -d -s $session_name
tmux rename-window -t 0 "api"
tmux send-keys -t "api" "sleep 10 && docker-compose exec debian bash" C-m
tmux send-keys -t "api" "lein run" C-m
tmux split-window -v -t "api" "$SHELL"
tmux send-keys -t "api" "cd hzn-pubs-spa" C-m
tmux send-keys -t "api" "lein 10x" C-m
tmux split-window -h -t "api" "$SHELL"
tmux send-keys -t "api" "cat hzcms-docker/hubzero.secrets" C-m

tmux new-window -t $session:1 -n "docker"
tmux send-keys -t "docker" "docker-compose up" C-m

tmux attach-session -t $session_name:0
