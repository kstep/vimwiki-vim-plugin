" Vimwiki autoload plugin file
" Desc: Handle diary notes
" Author: Maxim Kim <habamax@gmail.com>
" Home: http://code.google.com/p/vimwiki/

" Load only once {{{
if exists("g:loaded_vimwiki_diary_auto") || &cp
  finish
endif
let g:loaded_vimwiki_diary_auto = 1
"}}}

function! s:prefix_zero(num) "{{{
  if a:num < 10
    return '0'.a:num
  endif
  return a:num
endfunction "}}}

function! s:desc(d1, d2) "{{{
  return a:d1 == a:d2 ? 0 : a:d1 < a:d2 ? 1 : -1
endfunction "}}}
    
function! s:get_date_link(fmt) "{{{
  return strftime(a:fmt)
endfunction "}}}

function! s:diary_index() "{{{
  return VimwikiGet('path').VimwikiGet('diary_rel_path').
        \ VimwikiGet('diary_index').VimwikiGet('ext')
endfunction "}}}

function! s:diary_date_link() "{{{
  return s:get_date_link(VimwikiGet('diary_link_fmt'))
endfunction "}}}

function! s:link_exists(lines, link, header) "{{{
  let idx = 0
  let link_exists = 0
  let ln_header = -1
  for line in a:lines
    if ln_header != -1 && line =~ escape(a:link, '[]\')
      let link_exists = 1
      let ln_header = idx
      break
    endif
    if ln_header != -1 && line =~ '^\s*\(=\)\+.*\1\s*$'
      break
    endif
    if line =~ '^\s*\(=\)\+\s*'.a:header.'\s*\1\s*$'
      let ln_header = idx
    endif
    let idx += 1
  endfor
  return [link_exists, ln_header]
endfunction "}}}

function! s:get_file_contents(file_name) "{{{
  let lines = []
  let bufnr = bufnr(expand(a:file_name))
  if bufnr != -1
    let lines = getbufline(bufnr, 1, '$')
  else
    try
      let lines = readfile(expand(a:file_name))
    catch
    endtry
  endif
  return [lines, bufnr]
endfunction "}}}

function! s:get_links(line) "{{{
  let rx = '\[\[\d\{4}-\d\d-\d\d\]\]'
  let links = []
  let idx = match(a:line, rx)

  while idx != -1
    let link = matchstr(a:line, rx, idx)
    if !empty(link)
      call add(links, link)
    endif
    let idx = matchend(a:line, rx, idx)
  endwhile
  return links
endfunction "}}}

function! s:get_sorted_links(lines, ln_start) "{{{
  let links = []
  let idx = a:ln_start
  while idx < len(a:lines)
    let line = a:lines[idx]
    if line =~ '^\s*\(=\)\+.*\1\s*$' 
      break
    endif
    let links_on_line = s:get_links(line)
    if line !~ '^\s*$' && empty(links_on_line)
      break
    endif
    call extend(links, links_on_line)

    let idx += 1
  endwhile

  return [sort(links, 's:desc'), idx]
endfunction "}}}

function! s:sort_links(lines, ln_start) "{{{
  let [links, ln_end] = s:get_sorted_links(a:lines, a:ln_start)
  let link_lines = []
  let line = '| '
  let idx = 0
  let trigger = 0
  while idx < len(links)
    if idx/VimwikiGet('diary_link_count') > trigger
      let trigger = idx/VimwikiGet('diary_link_count')
      call add(link_lines, substitute(line, '\s\+$', '', ''))
      let line = '| '
    endif
    let line .= links[idx].' | '
    let idx += 1
  endwhile
  call add(link_lines, substitute(line, '\s\+$', '', ''))
  call extend(link_lines, ['', ''])

  let lines = copy(a:lines)
  let idx = ln_end - a:ln_start
  while idx > 0
    call remove(lines, a:ln_start)
    let idx -= 1
  endwhile
  
  call extend(lines, link_lines, a:ln_start)

  return lines
endfunction "}}}

function! s:add_link(page, header, link) "{{{
  let [lines, bufnr] = s:get_file_contents(a:page)

  let link = '[['.a:link.']]'

  let [link_exists, ln_header] = s:link_exists(lines, link, a:header)

  if !link_exists

    if ln_header == -1
      call insert(lines, '= '.a:header.' =')
      let ln_header = 0
    endif

    call insert(lines, link, ln_header+1)
    
    let lines = s:sort_links(lines, ln_header+1)

    if bufnr != -1
      exe 'buffer '.bufnr
      1,$delete _
      call append(1, lines)
      1,1delete _
    else
      call writefile(lines, expand(a:page))
    endif
  endif
endfunction "}}}

function! s:make_date_link(...) "{{{
  if a:0
    let link = a:1
  else
    let link = s:diary_date_link()
  endif
  let header = VimwikiGet('diary_header')
  call s:add_link(s:diary_index(), header, link)
  return VimwikiGet('diary_rel_path').link
endfunction "}}}

function! vimwiki_diary#make_note(index, ...) "{{{
  call vimwiki#select(a:index)
  call vimwiki#mkdir(VimwikiGet('path').VimwikiGet('diary_rel_path'))
  if a:0
    let link = s:make_date_link(a:1)
  else
    let link = s:make_date_link()
  endif
  call vimwiki#open_link(':e ', link, s:diary_index())
endfunction "}}}

" Calendar.vim callback.
function! vimwiki_diary#calendar_action(day, month, year, week, dir) "{{{
  let day = s:prefix_zero(a:day)
  let month = s:prefix_zero(a:month)

  let link = a:year.'-'.month.'-'.day
  if winnr('#') == 0
    if a:dir == 'V'
      vsplit
    else
      split
    endif
  else
    wincmd p
    if !&hidden && &modified
      new
    endif
  endif

  " Create diary note for a selected date in default wiki.
  call vimwiki_diary#make_note(1, link)
endfunction
