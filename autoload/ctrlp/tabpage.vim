" Tab page extension for CtrlP
"
" Maintainer:   DeaR <nayuri@kuonn.mydns.jp>
" Last Change:  14-Oct-2015.
" License:      Vim License  (see :help license)

if exists('g:loaded_ctrlp_tabpage') && g:loaded_ctrlp_tabpage
  finish
endif
let g:loaded_ctrlp_tabpage = 1

call add(g:ctrlp_ext_vars, {
\ 'init'   : 'ctrlp#tabpage#init(s:bufnr)',
\ 'accept' : 'ctrlp#tabpage#accept',
\ 'lname'  : 'tabpage',
\ 'sname'  : 'tab',
\ 'type'   : 'line'})

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

function! s:tabpage(tabnr, bufnr)
  let bufs = []
  for bufnr in filter(tabpagebuflist(a:tabnr), 'v:val != a:bufnr')
    let name = bufname(bufnr)
    let fname = fnamemodify(
    \ empty(name) ? ('[' . bufnr . '*No Name]') : name, ':.')
    if index(bufs, fname) < 0
      call add(bufs, fname)
    endif
  endfor

  let title = exists('*gettabvar') ? gettabvar(a:tabnr, 'title') : ''
  return a:tabnr .
  \ (!empty(title) ? (': ' . title) : '') .
  \ "\t|" . join(bufs, '|') . '|'
endfunction

function! s:syntax()
  if !ctrlp#nosy()
    call ctrlp#hicheck('CtrlPBufName', 'Directory')
    call ctrlp#hicheck('CtrlPTabExtra', 'Comment')
    syntax match CtrlPBufName '|\zs[^|]\+\ze|'
    syntax match CtrlPTabExtra '\zs\t.*\ze$' contains=CtrlPBufName
  endif
endfunction

function! ctrlp#tabpage#init(bufnr)
  let tabs = []
  for each in range(1, tabpagenr('$'))
    call add(tabs, s:tabpage(each, a:bufnr))
  endfor
  call s:syntax()
  return tabs
endfunction

function! ctrlp#tabpage#accept(mode, str)
  let tabnr = matchstr(a:str, '^\d\+')
  if empty(tabnr)
    return
  endif
  call ctrlp#exit()
  execute 'tabnext' tabnr
endfunction

function! ctrlp#tabpage#id()
  return s:id
endfunction
