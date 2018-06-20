" Tab page extension for CtrlP
"
" Maintainer:   DeaR <nayuri@kuonn.mydns.jp>
" Last Change:  20-Jun-2018.
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

let s:tabnr_width = 2

function! s:format(bufnr)
  let parts = ctrlp#call('s:bufparts', a:bufnr)
  if !ctrlp#nosy() && ctrlp#getvar('s:has_conceal')
    return printf('%s%s',
    \ '<bn>' . parts[1], '{' . parts[2] . '}</bn>')
  else
    return parts[2]
  endif
endfunction

function! s:tabpage(tabnr, bufnr)
  let str = ''
  if !ctrlp#nosy() && ctrlp#getvar('s:has_conceal')
    let str .= printf('<nr>%' . s:tabnr_width . 's</nr>', a:tabnr)
  else
    let str .= printf('%' . s:tabnr_width . 's', a:tabnr)
  endif
  let str .= printf(' %-4s ', '')
  let str .= join(
  \ map(filter(tabpagebuflist(a:tabnr), 'v:val != a:bufnr'),
  \ 's:format(v:val)'), '|')
  return str
endfunction

function! s:syntax()
  call ctrlp#syntax()
  if !ctrlp#nosy() && ctrlp#getvar('s:has_conceal')
    syntax region CtrlPBufferNr     concealends matchgroup=Ignore start='<nr>' end='</nr>'
    syntax region CtrlPBufferInd    concealends matchgroup=Ignore start='<bi>' end='</bi>'
    syntax region CtrlPBufferRegion concealends matchgroup=Ignore start='<bn>' end='</bn>'
    \ contains=CtrlPBufferHid,CtrlPBufferHidMod,CtrlPBufferVis,CtrlPBufferVisMod,CtrlPBufferCur,CtrlPBufferCurMod
    syntax region CtrlPBufferHid    concealends matchgroup=Ignore     start='\s*{' end='}' contained
    syntax region CtrlPBufferHidMod concealends matchgroup=Ignore    start='+\s*{' end='}' contained
    syntax region CtrlPBufferVis    concealends matchgroup=Ignore   start='\*\s*{' end='}' contained
    syntax region CtrlPBufferVisMod concealends matchgroup=Ignore  start='\*+\s*{' end='}' contained
    syntax region CtrlPBufferCur    concealends matchgroup=Ignore  start='\*!\s*{' end='}' contained
    syntax region CtrlPBufferCurMod concealends matchgroup=Ignore start='\*+!\s*{' end='}' contained
    syntax region CtrlPBufferPath   concealends matchgroup=Ignore start='<bp>' end='</bp>'
  endif
endfunction

function! ctrlp#tabpage#init(bufnr)
  let tabs = []
  for each in filter(range(1, tabpagenr('$')), 'v:val != tabpagenr()')
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
