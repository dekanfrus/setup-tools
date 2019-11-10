#!/bin/sh 

SESSION_NAME="alves"

tmux new-session -s ${SESSION_NAME} -n msfconsole -d
tmux send-keys -t ${SESSION_NAME}:0 'msfdb init' C-m
tmux send-keys -t ${SESSION_NAME}:0 'msfconsole' C-m

tmux new-window -t ${SESSION_NAME} -n Serp-Cov
tmux split-window -h -t ${SESSION_NAME}:1
tmux send-keys -t ${SESSION_NAME}:1.0 'bash /opt/Serpico/start_serpico.sh' C-m
tmux send-keys -t ${SESSION_NAME}:1.1 'docker start covenant -ai' C-m

tmux new-window -t ${SESSION_NAME}
tmux send-keys -t ${SESSION_NAME}:2 'mount -t cifs -o username=user,domain=dom,vers=2.0 //10.0.0.0/share /mnt/share' C-m
tmux select-window -t ${SESSION_NAME}:0

tmux attach -t ${SESSION_NAME}
