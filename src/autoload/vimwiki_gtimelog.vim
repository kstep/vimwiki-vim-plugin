" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=79
" Vimwiki autoload plugin file
" Desc: Handle time logging according to http://mg.pov.lt/gtimelog/
" Author: Jean Jordaan <jean.jordaan@gmail.com>
" Home: 

" Load only once {{{
if exists("g:loaded_vimwiki_gtimelog_auto") || &cp
  finish
endif
let g:loaded_vimwiki_gtimelog_auto = 1

" Local constants
let s:timestamp_pat = "^\d\4-\d\2-\d\2 \d\2:\d\2: "
"}}}
"

function! vimwiki_gtimelog#log(index, from, ...) "{{{
  call Dfunc('vimwiki_gtimelog#log(index, from, ...)')
  call Decho("index: ".a:index)
  " Create today's diary, clean up logline, and add it to the diary.
  call vimwiki#select(a:index) "Set g:vimwiki_current_idx

  " Create or find diary page
  if a:0
    "call Decho("index passed: ".a:1)
    let link = vimwiki_diary#make_date_link(a:1)
  else
    "call Decho("default link")
    let link = vimwiki_diary#make_date_link()
  endif

  " optionally set logline and prefix
  let category = ""
  if a:0 > 1
    let logline = a:1
    "call Decho("logline passed: ".logline)
  else
    let logline = getline(".")
    "call Decho("logline currentline: ".logline)
  endif
  if a:0 == 2
    let category = a:2
  endif
  "call Decho("category: ".category)

  call s:add_logline(link, a:from, logline, category)
  call Dret("vimwiki_gtimelog#log")
endfunction "}}}


function! s:add_logline(link, from, logline, category) "{{{ 
  call Dfunc('s:add_logline(link, from, logline, category)')
  " Add a line like 'TIMESTAMP: category: logline' to today's diary.
  " If '*category: logline*' was the last thing logged, update that line
  " instead of adding. 

  let [category, from_link] = s:prefix(a:from)

  if a:category
    let category = a:category.": ".from_link
  elseif a:link != from_link
    let category = category.": ".from_link
  else
    " If we're logging to the current page, there is no auto-category.
    let category = ""
  endif

  if a:logline
    " strip list prefix and whitespace from logline
    let logline = substitute(a:logline, "^\\s\\{-}[#*-]\\( \\[.\\]\\)\\= \\(.\\{-}\\) *$", "\\2","")
    let logline = category.": ".logline
  else
    let logline = category
  endif
  let logline = substitute(a:logline, "^\\s\\+[#*-]\\( \\[.\\]\\)\\= \\(.\\{-}\\) *$", "\\2","")
  let logline = category.": ".logline

  " TODO: do this silently, without changing buffers
  " TODO: pass argument for prev_link
  " call vimwiki#open_link(":edit ", a:link, a:today)
  call vimwiki#open_link(":edit ", a:link)
  let last_logged = s:last_logged(logline) 
  let logline = s:timestamp(logline)

  if last_logged
    call setline(last_logged, logline)
  else
    call append(line("$"), logline)
  endif

  " Go back to where we were
  call vimwiki#open_link(":edit ", a:from, a:link)

  call Dret('s:add_logline')
endfunction "}}}

function! s:prefix(from) "{{{
  call Dfunc('s:prefix(from)')
  " For .../path/link.ext return 'path, link.ext'
  " Strip .ext if it is the wiki extension.

  let last_slash_idx = strridx(a:from, '/')
  let wiki_ext_idx = strridx(a:from, VimwikiGet('ext'))
  let category = a:from[strridx(a:from, '/', last_slash_idx-1)+1: last_slash_idx-1]
  if wiki_ext_idx > 1
    let from_link = a:from[last_slash_idx+1 : wiki_ext_idx-1]
  endif
  call Dret("s:prefix")
  return category, from_link
endfunction "}}}

function! s:last_logged(logline) "{{{
  call Dfunc('s:last_logged(logline)')
  "TODO: search for logline from bottom of file
  " Match '^<timestamp>.*<logline>.*'
  let cursorpos = getpos(".") "store
  " Go to last line
  normal G$
  " Search backward
  let logged_at = search(s:timestamp_pat.a:logline, "bcW")
  call setpos(".", cursorpos) "restore
  call Dret("s:last_logged")
  return logged_at
endfunction "}}}

function! s:timestamp(line) "{{{
  call Dfunc('s:timestamp(line)')
  if match(a:line, s:timestamp_pat) != -1
    let line = a:line[18:] " chomp the timestamp
  else
    let line = a:line
  endif
  let timestamp = strftime("%Y-%m-%d %H:%M: ")
  call Dret("s:timestamp")
  return timestamp.line
endfunction "}}}

"TODO: hook into wiki page save events (or all save events?)
"TODO: - write loglines for each save
"
"TODO: add functions for reporting
"TODO: - get all loglines on a page in order
"TODO: - get all loglines in these pages in order
"TODO: - parse loglines to report
"TODO: - reports: daily, monthly, csv, ... 
"
"TODO: export to gtimelog
"TODO: - append to timelog.txt
"TODO: - how to avoid creating duplicates?
