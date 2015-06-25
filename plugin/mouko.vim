" File:     mouko.vim
" Author:   Shinya Ohyanagi <sohyanagi@gmail.com>
" Version:  0.0.1
" WebPage:  http://github.com/heavenshell/vim-mouko/
" License:  This file is placed in the Public domain
" This function copy lots from toggeter-vim.
" see
" https://github.com/mattn/togetter-vim/blob/master/plugin/togetter.vim#L44
let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* -range=0 -complete=customlist,mouko#complete Mouko
  \ call mouko#search(<q-args>, <count>, <line1>, <line2>)

let &cpo = s:save_cpo
unlet s:save_cpo
