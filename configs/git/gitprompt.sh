#!/bin/bash

if [ -f "$HOME/.bashrc.d/git-prompt/gitprompt.sh" ]; then
	GIT_PROMPT_THEME=Custom
	GIT_PROMPT_ONLY_IN_REPO=1
	source "$HOME/.bashrc.d/git-prompt/gitprompt.sh"
fi
