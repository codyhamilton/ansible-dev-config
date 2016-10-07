# This theme for gitprompt.sh is optimized for the "Solarized Dark" and "Solarized Light" color schemes 
# tweaked for Ubuntu terminal fonts

override_git_prompt_colors() {
  GIT_PROMPT_THEME_NAME="Solarized"
	
  PathShort="\A ${BoldBlue}\u:${Cyan}\W"

	GIT_PROMPT_PREFIX="${BrightYellow} " # Start of git info
	GIT_PROMPT_SUFFIX="${ResetColor}"     # end of git info
	GIT_PROMPT_SEPARATOR=""                  # separator between info items

	GIT_PROMPT_REMOTE=" "                 # The remote branch name and ahead/behind
	GIT_PROMPT_BRANCH="${BrightYellow}"   # Current branch name
  GIT_PROMPT_SYMBOLS_NO_REMOTE_TRACKING="✭ "                # Indicator for when there is no remote tracking branch

	GIT_PROMPT_START_USER="\A /\W"            # Start of user defined string
	GIT_PROMPT_END_USER=" $ "               # End of user string
	GIT_PROMPT_END_ROOT="${BoldRed} # "               # End of user string

  GIT_PROMPT_COMMAND_OK="${Green}✔"    # indicator if the last command returned with an exit code of 0
  GIT_PROMPT_COMMAND_FAIL="${Red}✘"  # indicator if the last command returned with an exit code of other than 0

  GIT_PROMPT_CLEAN=" ${Green}✔ "       # a colored flag indicating a "clean" repo
  GIT_PROMPT_STAGED=" ${Yellow}●"       # the number of staged files/directories
  GIT_PROMPT_CONFLICTS=" ${Red}✖ "         # the number of files in conflict
  GIT_PROMPT_CHANGED=" ${Blue}✚ "        # the number of changed files
  GIT_PROMPT_UNTRACKED=" ${Cyan}…"         # the number of untracked files/dirs
  GIT_PROMPT_STASHED=" ${BoldMagenta}⚑"  # the number of stashed files/dir
}

reload_git_prompt_colors "Solarized"
