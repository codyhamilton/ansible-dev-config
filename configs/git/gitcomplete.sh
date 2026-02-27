#!/bin/bash
# gitcomplete.sh parameter-completion

_Git_Complete () {
	if [[ ${COMP_WORDS[COMP_CWORD - 1]} != '--' ]]; then
		COMPREPLY=( $( compgen -W "`git branch --list --column=always | tr -s '* \n' ' '`" -- ${COMP_WORDS[COMP_CWORD]} ) );
	else
		COMPREPLY=( $(compgen -f ${COMP_WORDS[${COMP_CWORD}]} ) )
	fi

  return 0
}
complete -F _Git_Complete -o filenames git
