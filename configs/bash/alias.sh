#!/bin/bash

alias ll="ls -lG";

cmd="vim"
if command -v nvim > /dev/null 2>&1; then
	cmd="nvim"
fi

function v() {
	if [ -n "$*" ]; then
		$cmd -c "Telescope" -c "normal $*";
	else
		$cmd
	fi
}

vimc() {
  local session="vimc"
  if ! command -v tmux > /dev/null 2>&1; then
    echo "vimc: tmux not installed" >&2
    return 1
  fi
  if tmux has-session -t "$session" 2>/dev/null; then
    [ -n "$TMUX" ] && tmux switch-client -t "$session" || tmux attach-session -t "$session"
    return
  fi
  # Layout: left 60% (vim) | right 40% split top 80% (claude) / bottom 20% (shell)
  tmux new-session -d -s "$session"
  tmux split-window -h -p 40 -t "$session"
  tmux split-window -v -p 20 -t "${session}:1.2"
  tmux send-keys -t "${session}:1.1" "$cmd" Enter
  tmux send-keys -t "${session}:1.2" "claude" Enter
  tmux select-pane -t "${session}:1.1"
  [ -n "$TMUX" ] && tmux switch-client -t "$session" || tmux attach-session -t "$session"
}
