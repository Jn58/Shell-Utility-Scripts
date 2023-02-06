#!/bin/bash

# Append git status to PS1
PS1=$(echo $PS1 | sed -e 's/\\\$/$(__git_ps1)\\$ /')
