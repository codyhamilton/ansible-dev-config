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

alias vimc="$cmd -c 'Claude'"
