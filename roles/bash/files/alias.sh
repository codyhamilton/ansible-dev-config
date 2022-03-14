#!/bin/bash

alias ll="ls -lG";

cmd = "vim";
if command -v nvim; then
	cmd = "nvim"
fi

function v() {
	if [ -n "$@" ]; then
		$cmd -c "Telescope" -c "normal $@";
	else
		$cmd
	fi
}
