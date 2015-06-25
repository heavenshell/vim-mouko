" Last Change:  2015-06-25
" Maintainer:   Shinya Ohyanagi <sohyanagi@gmail.com>
" License:      This file is placed in the public domain.
let s:save_cpo = &cpo
set cpo&vim

let s:mouko_uri = 'http://botch.herokuapp.com/v0/scores/'
let s:mouko_req_params = ['date']

let s:team = {
  \ 'YS': 'ヤクルト    ',
  \ 'G':  '巨人        ',
  \ 'DB': 'DeNA        ',
  \ 'D':  '中日        ',
  \ 'T':  '阪神        ',
  \ 'C':  '広島        ',
  \ 'F':  '日本ハム    ',
  \ 'E':  '楽天        ',
  \ 'M':  'ロッテ      ',
  \ 'L':  '西武        ',
  \ 'BF': 'オリックス  ',
  \ 'H':  'ソフトバンク'
  \ }

function! s:build_query(args)
  let querys = split(a:args, ' ')
  let requests = []
  for query in querys
    let arg = split(query, '=')
    let key = substitute(arg[0], '^-', '', '')
    if count(s:mouko_req_params, key) == 0
      echohl WarningMsg
      echo printf("Request parameter '%s' is invalid.", key)
      echohl None
      return
    endif

    let val = ''
    if len(arg[1:]) > 1
      let val = join(arg[1:], '=')
    else
      let val = arg[1]
    endif
    call add(requests, printf('%s', val))
  endfor

  return join(requests, '&')
endfunction

function! mouko#complete(lead, cmd, pos)
  let args = map(copy(s:mouko_req_params), '"-" . v:val . "="')
  return filter(args, 'v:val =~# "^".a:lead')
endfunction

function! mouko#search(...)
  let query = s:build_query(a:000[0])
  if query == ''
    let query = strftime("%Y%m%d")
  else
    let query = printf('%s', query)
  endif
  let uri = s:mouko_uri . query
  echomsg uri

  redraw | echo "fetching feed..."
  let response = webapi#http#get(uri)
  let content = webapi#json#decode(response.content)
  let data = content['data']
  echomsg string(data)

  call s:mouko_list(data)
  redraw | echo ''
endfunction

function! s:mouko_list(data)
  " This function copy lots from toggeter-vim.
  " see https://github.com/mattn/togetter-vim/blob/master/plugin/togetter.vim#L44
  let winnum = bufwinnr(bufnr('^mouko$'))
  if winnum != -1
    if winnum != bufwinnr('%')
      exe winnum 'wincmd w'
    endif
  else
    exec 'silent noautocmd 6split mouko'
  endif
  setlocal modifiable
  silent %d

  call setline(1, map(deepcopy(a:data), 's:team[v:val["away"]["team"]]." | ".v:val["away"]["score"]." | vs | ".s:team[v:val["home"]["team"]]." | ".v:val["home"]["score"]." | ". v:val["info"]["start"]." | ".v:val["info"]["inning"]'))

  setlocal buftype=nofile bufhidden=delete noswapfile
  setlocal nomodified
  setlocal nomodifiable
  nmapclear <buffer>
  auto CursorMoved <buffer> setlocal cursorline
  syntax clear
  "syntax match SpecialKey /[\x21-\x7f]\+$/
  nnoremap <silent> <buffer> q :close<cr>
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
