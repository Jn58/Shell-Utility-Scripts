" >>> Import defaults_vim >>>
unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim
" <<< Import defaults_vim <<<

set et 
set nu
set ts=4
set sw=4
set sws=4
set ai
set scrolloff=7


silent !mkdir -p ~/.vim/temp/undo
silent !mkdir -p ~/.vim/temp/backup
silent !mkdir -p ~/.vim/temp/swp
set undodir=~/.vim/temp/undo//
set backupdir=~/.vim/temp/backup//
set directory=~/.vim/temp/swp//
