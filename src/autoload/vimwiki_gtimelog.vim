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
let s:timestamp_pat = "^\\d\\d\\d\\d-\\d\\d-\\d\\d \\d\\d:\\d\\d: "
"}}}
"

function! vimwiki_gtimelog#log(index, from, ...) "{{{
  " Create today's diary, clean up logline, and add it to the diary.
  " @index: index of wiki
  " @from: path of page we're logging from
  " @a:1 line to log (if not given: use current line
  " @a:2 category for log line (if not given, use wiki name)
"  call Dfunc('vimwiki_gtimelog#log(index="'.a:index.'", from="'.a:from.'")')

  let saved_cursor = getpos(".")
"  call Decho('saved_cursor = '.join(saved_cursor, ','))
  call vimwiki#select(a:index) "Set g:vimwiki_current_idx

  " Create or find diary page
  let link = vimwiki_diary#make_date_link()
"  call Decho('link: '.link)

  " optionally set logline and prefix
  let category = ""
  if a:0 > 1
    let logline = a:1
"    call Decho("logline passed: ".logline)
  else
    let logline = getline(".")
"    call Decho("logline currentline: ".logline)
  endif
  if a:0 == 2
    let category = a:2
  endif
"  call Decho("category: ".category)

  call s:add_logline(link, a:from, logline, category)
"  call Decho('Returning to saved_cursor = '.join(saved_cursor,','))
  call setpos('.', saved_cursor)
"  call Dret("vimwiki_gtimelog#log")
endfunction "}}}


function! s:add_logline(link, from, logline, category) "{{{ 
"  call Dfunc('s:add_logline(link="'.a:link.'", from="'.a:from.'", logline="'.a:logline.'", category="'.a:category.'")')
  " Add a line like 'TIMESTAMP: category: logline' to today's diary.
  " If '*category: logline*' was the last thing logged, update that line
  " instead of adding. 

  let [prefix, from_link] = s:prefix(a:from)
"  call Decho('category = "'.prefix.'", from_link = "'.from_link.'"')

  if a:category != ''
    " If we were passed a category, override the computed category
    let category = a:category.": ".from_link
"    call Decho('1. category = "'.category.': "')
  elseif a:link != from_link
    let category = prefix." ".from_link.": "
"    call Decho('2. category = "'.category.'"')
  else
    " If we're logging to the current page, there is no auto-category.
    let category = ""
"    call Decho('3. category = "'.category.'"')
  endif

  if a:logline != ''
    " strip list prefix and whitespace from logline
"    call Decho('strip list prefix and whitespace from logline')
    let logline = substitute(a:logline, "^\\s\\{-}[#*-]\\( \\[.\\]\\)\\= \\(.\\{-}\\) *$", "\\2","")
    let logline = category.logline
"    call Decho('1. logline = "'.logline.'"')
  else
    " Usually this will just log the page we're on
    let logline = category
"    call Decho('2. logline = "'.logline.'"')
  endif

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
"  call Decho('from="'.a:from.'", link="'.a:link.'")')
  let [wikiname, from_link] = s:prefix(a:from)
  call vimwiki#open_link(":edit ", from_link)

"  call Dret('s:add_logline')
endfunction "}}}

function! s:prefix(from) "{{{
  " For .../path/link.ext return 'path, link.ext' (strip '.ext' if it is the
  " wiki extension).
"  call Dfunc('s:prefix(from="'.a:from.'")')

  let last_slash_idx = strridx(a:from, '/')
  let wiki_ext_idx = strridx(a:from, VimwikiGet('ext'))
  let category = a:from[strridx(a:from, '/', last_slash_idx-1)+1: last_slash_idx-1]
  if wiki_ext_idx > 1
    " Wiki extension was found
    let from_link = a:from[last_slash_idx+1 : wiki_ext_idx-1]
  endif
"  call Decho('category: "'.category.'", from_link: "'.from_link.'"')
"  call Dret("s:prefix")
  return [category, from_link]
endfunction "}}}

function! s:last_logged(logline) "{{{
  " Return the line number where this line was last logged
  call Dfunc('s:last_logged(logline="'.a:logline.'")')

  if match(a:logline, s:timestamp_pat) == 0
"    call Decho('Matched timestamp')
    let logline = a:logline[18:] " chomp the timestamp
  else
    let logline = a:logline
  endif

  let curpos = getpos(".")
  " Go to last line
  normal G$
  call Decho('1. Searching for: '.s:timestamp_pat)
  let last_timestamp_line = search(s:timestamp_pat, "bcW")
  call Decho('last_timestamp_line: '.last_timestamp_line)
  normal G$
  call Decho('2. Searching for: '.s:timestamp_pat.logline.'$')
  " Match '^<timestamp>.*<logline>.*', search backward
  let logged_at = search(s:timestamp_pat.logline.'$', "bcW")
  call Decho('logged_at: '.logged_at)
  if logged_at < last_timestamp_line
    let logged_at = 0
  endif
  call Decho('logged_at: '.logged_at)
  call setpos('.', curpos)
  call Dret("s:last_logged")
  return logged_at
endfunction "}}}

function! s:timestamp(line) "{{{
"  call Dfunc('s:timestamp(line)')
  if match(a:line, s:timestamp_pat) == 0
"    call Decho('Matched timestamp')
    let line = a:line[18:] " chomp the timestamp
  else
"    call Decho('Match '.match(a:line, s:timestamp_pat))
"    call Decho('No timestamp in "'.a:line.'"')
    let line = a:line
  endif
  let timestamp = strftime("%Y-%m-%d %H:%M: ")
"  call Dret("s:timestamp")
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
