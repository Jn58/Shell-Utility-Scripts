#!/bin/bash

# >>> alias for micromamba >>>
if [ -n "${MAMBA_EXE}" ]
then
    alias mm='micromamba'
    complete -o default -F _umamba_bash_completions mm
fi
# <<< alias for micromamba <<<

# Append git status to PS1
if which git > /dev/null 2>&1
then
    PS1=$(echo $PS1 | sed -e 's/\\\$/$(__git_ps1)\\$ /')
fi
