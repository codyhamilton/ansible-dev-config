#!/bin/bash

alias ll="ls -lG";

function v() {
	if [ -n "$@" ]; then
		nvim -c "CtrlP" -c "normal $@";
	else
		nvim
	fi
}
