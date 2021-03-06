" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=79
" Vimwiki autoload plugin file
" Export to HTML
" Author: Maxim Kim <habamax@gmail.com>
" Home: http://code.google.com/p/vimwiki/

" XXX: This file should be refactored!

" Load only once {{{
if exists("g:loaded_vimwiki_html_auto") || &cp
  finish
endif
let g:loaded_vimwiki_html_auto = 1
"}}}

" UTILITY "{{{
function! s:root_path(subdir) "{{{
  return repeat('../', len(split(a:subdir, '[/\\]')))
endfunction "}}}

function! s:syntax_supported() " {{{
  return VimwikiGet('syntax') == "default"
endfunction " }}}

function! s:remove_blank_lines(lines) " {{{
  while !empty(a:lines) && a:lines[-1] =~ '^\s*$'
    call remove(a:lines, -1)
  endwhile
endfunction "}}}

function! s:is_web_link(lnk) "{{{
  if a:lnk =~ '^\%(https://\|http://\|www.\|ftp://\|file://\|mailto:\)'
    return 1
  endif
  return 0
endfunction "}}}

function! s:is_img_link(lnk) "{{{
  if a:lnk =~ '\.\%(png\|jpg\|gif\|jpeg\)$'
    return 1
  endif
  return 0
endfunction "}}}

function! s:has_abs_path(fname) "{{{
  if a:fname =~ '\(^.:\)\|\(^/\)'
    return 1
  endif
  return 0
endfunction "}}}

function! s:create_default_CSS(path) " {{{
  let path = expand(a:path)
  let css_full_name = path.VimwikiGet('css_name')
  if glob(css_full_name) == ""
    call vimwiki#mkdir(fnamemodify(css_full_name, ':p:h'))
    let lines = []

    call add(lines, 'body {font-family: Tahoma, Geneva, sans-serif; margin: 1em 2em 1em 2em; font-size: 100%; line-height: 130%;}')
    call add(lines, 'h1, h2, h3, h4, h5, h6 {font-family: Trebuchet MS, Helvetica, sans-serif; font-weight: bold; margin-top: 1.5em; margin-bottom: 0.5em; color: MediumOrchid;}')
    call add(lines, 'h1 {font-size: 2.1em; color: Fuchsia;}')
    call add(lines, 'h2 {font-size: 1.8em; color: Fuchsia;}')
    call add(lines, 'h3 {font-size: 1.6em; color: MediumVioletRed;}')
    call add(lines, 'h4 {font-size: 1.4em; color: MediumVioletRed;}')
    call add(lines, 'h5 {font-size: 1.2em; color: DarkMagenta;}')
    call add(lines, 'h6 {font-size: 1.1em; color: DarkMagenta;}')
    call add(lines, 'p, pre, blockquote, table, ul, ol, dl {margin-top: 1em; margin-bottom: 1em;}')
    call add(lines, 'ul ul, ul ol, ol ol, ol ul {margin-top: 0.5em; margin-bottom: 0.5em;}')
    call add(lines, 'li {margin: 0.3em auto;}')
    call add(lines, 'ul {margin-left: 2em; padding-left: 0.5em;}')
    call add(lines, 'dt {font-weight: bold;}')
    call add(lines, 'img {border: none;}')
    call add(lines, 'pre {border-left: 1px solid #ccc; margin-left: 2em; padding-left: 0.5em;}')
    call add(lines, 'blockquote {padding: 0.4em; background-color: #f6f5eb;}')
    call add(lines, 'th, td {border: 1px solid #ccc; padding: 0.3em;}')
    call add(lines, 'th {background-color: #f0f0f0;}')
    call add(lines, 'hr {border: none; border-top: 1px solid #ccc; width: 100%;}')
    call add(lines, 'del {text-decoration: line-through; color: #777777;}')
    call add(lines, '.toc li {list-style-type: none;}')
    call add(lines, '.todo {font-weight: bold; background-color: #f0ece8; color: #a03020;}')
    call add(lines, '.justleft {text-align: left;}')
    call add(lines, '.justright {text-align: right;}')
    call add(lines, '.justcenter {text-align: center;}')
    call add(lines, '.center {margin-left: auto; margin-right: auto;}')
    call add(lines, '/* classes for items of todo lists */')
    call add(lines, '.done0:before {content: "\2592\2592\2592\2592"; color: SkyBlue;}')
    call add(lines, '.done1:before {content: "\2588\2592\2592\2592"; color: SkyBlue;}')
    call add(lines, '.done2:before {content: "\2588\2588\2592\2592"; color: SkyBlue;}')
    call add(lines, '.done3:before {content: "\2588\2588\2588\2592"; color: SkyBlue;}')
    call add(lines, '.done4:before {content: "\2588\2588\2588\2588"; color: SkyBlue;}')
    call add(lines, '/* comment the next four or five lines out   *')
    call add(lines, ' * if you do not want color-coded todo lists */ ')
    call add(lines, '.done0 {color: #c00000;}')
    call add(lines, '.done1 {color: #c08000;}')
    call add(lines, '.done2 {color: #80a000;}')
    call add(lines, '.done3 {color: #00c000;}')
    call add(lines, '.done4 {color: #7f7f7f; text-decoration: line-through;}')

    call writefile(lines, css_full_name)
    echomsg "Default style.css has been created."
  endif
endfunction "}}}

function! s:template_full_name(name) "{{{
  if a:name == ''
    let name = VimwikiGet('template_default')
  else
    let name = a:name
  endif

  let fname = expand(VimwikiGet('template_path').
        \name.
        \VimwikiGet('template_ext'))

  if filereadable(fname)
    return fname
  else
    return ''
  endif
endfunction "}}}

function! s:get_html_template(subdir, wikifile, template) "{{{
  let lines=[]

  let template_name = s:template_full_name(a:template)
  if template_name != ''
    try
      let lines = readfile(template_name)
      return lines
    catch /E484/
      echomsg 'vimwiki: html template '.template_name.
            \ ' does not exist!'
    endtry
  endif

  let css_name = expand(VimwikiGet('css_name'))
  let css_name = substitute(css_name, '\', '/', 'g')
  if !s:has_abs_path(css_name)
    " Relative css file for deep links: [[dir1/dir2/dir3/filename]]
    let css_name = s:root_path(a:subdir).css_name
  endif

  let enc = &fileencoding
  if enc == ''
    let enc = &encoding
  endif

  " if no VimwikiGet('html_template') set up or error while reading template
  " file -- use default one.
  call add(lines, '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">')
  call add(lines, '<html>')
  call add(lines, '<head>')
  call add(lines, '<link rel="Stylesheet" type="text/css" href="'.
        \ css_name.'">')
  call add(lines, '<title>%title%</title>')
  call add(lines, '<meta http-equiv="Content-Type" content="text/html;'.
        \ ' charset='.&enc.'">')
  call add(lines, '</head>')
  call add(lines, '<body>')
  call add(lines, '%content%')
  call add(lines, '</body>')
  call add(lines, '</html>')
  return lines
endfunction "}}}

function! s:safe_html(line) "{{{
  "" htmlize symbols: < > &

  let line = substitute(a:line, '&', '\&amp;', 'g')

  let tags = join(split(g:vimwiki_valid_html_tags, '\s*,\s*'), '\|')
  let line = substitute(line,'<\%(/\?\%('
        \.tags.'\)\%(\s\{-1}\S\{-}\)\{-}/\?>\)\@!', 
        \'\&lt;', 'g')
  let line = substitute(line,'\%(</\?\%('
        \.tags.'\)\%(\s\{-1}\S\{-}\)\{-}/\?\)\@<!>',
        \'\&gt;', 'g')
  return line
endfunction "}}}

function! s:delete_html_files(path) "{{{
  let htmlfiles = split(glob(a:path.'**/*.html'), '\n')
  for fname in htmlfiles
    " ignore user html files, e.g. search.html,404.html
    if stridx(g:vimwiki_user_htmls, fnamemodify(fname, ":t")) >= 0
      continue
    endif

    " delete if there is no corresponding wiki file
    let subdir = vimwiki#subdir(VimwikiGet('path_html'), fname)
    let wikifile = VimwikiGet("path").subdir.
          \fnamemodify(fname, ":t:r").VimwikiGet("ext")
    if filereadable(wikifile)
      continue
    endif

    try
      call delete(fname)
    catch
      echomsg 'vimwiki: Cannot delete '.fname
    endtry
  endfor
endfunction "}}}

function! s:remove_comments(lines) "{{{

  " Kind of a Finite State Machine
  function! s:strip_comment(line, state) "{{{
    let state = a:state
    let line = ''
    let bufline = ''
    let idx = 0
    while idx < len(a:line)
      if state == 'normal'
        if a:line[idx] == '<'
          let state = '<'
        elseif a:line[idx] == '{'
          let state = '{'
        elseif a:line[idx] == '`'
          let state = 'code'
        endif
        let bufline .= a:line[idx]
      elseif state == '<'
        if a:line[idx] == '!'
          let state = '<!'
        elseif a:line[idx] == '{'
          let state = '{'
        elseif a:line[idx] == '`'
          let state = 'code'
        else
          let state = 'normal'
        endif
        let bufline .= a:line[idx]
      elseif state == '<!'
        if a:line[idx] == '-'
          let state = '<!-'
        elseif a:line[idx] == '{'
          let state = '{'
        elseif a:line[idx] == '`'
          let state = 'code'
        else
          let state = 'normal'
        endif
        let bufline .= a:line[idx]
      elseif state == '<!-'
        if a:line[idx] == '-'
          let state = 'comment'
          let bufline = ''
        elseif a:line[idx] == '{'
          let state = '{'
          let bufline .= a:line[idx]
        elseif a:line[idx] == '`'
          let state = 'code'
          let bufline .= a:line[idx]
        else
          let state = 'normal'
          let bufline .= a:line[idx]
        endif
      elseif state == '{'
        if a:line[idx] == '{'
          let state = '{{'
        elseif a:line[idx] == '<'
          let state = '<'
        elseif a:line[idx] == '`'
          let state = 'code'
        else
          let state = 'normal'
        endif
        let bufline .= a:line[idx]
      elseif state == '{{'
        if a:line[idx] == '{'
          let state = 'pre'
        elseif a:line[idx] == '<'
          let state = '<'
        elseif a:line[idx] == '`'
          let state = 'code'
        else
          let state = 'normal'
        endif
        let bufline .= a:line[idx]
      elseif state == 'comment'
        if a:line[idx] == '-'
          let state = '-'
        endif
      elseif state == '-'
        if a:line[idx] == '-'
          let state = '--'
        else
          let state = 'comment'
        endif
      elseif state == '--'
        if a:line[idx] == '>'
          let state = 'normal'
          let bufline = ''
        else
          let state = 'comment'
        endif
      elseif state == 'pre'
        if a:line[idx] == '}'
          let state = '}'
        endif
        let bufline .= a:line[idx]
      elseif state == '}'
        if a:line[idx] == '}'
          let state = '}}'
        else
          let state = 'pre'
        endif
        let bufline .= a:line[idx]
      elseif state == '}}'
        if a:line[idx] == '}'
          let state = 'normal'
        else
          let state = 'pre'
        endif
        let bufline .= a:line[idx]
      elseif state == 'code'
        if a:line[idx] == '`'
          let state = 'normal'
        endif
        let bufline .= a:line[idx]
      endif

      if state == 'normal' || state == 'pre' || state == 'code'
        let line = line . bufline
        let bufline = ''
      endif

      let idx += 1
    endwhile
    return [line, state]
  endfunction "}}}

  let res = []
  let state = 'normal'

  let idx = 0
  while idx < len(a:lines)
    let line = a:lines[idx]
    let idx += 1

    let [strip_line, state] = s:strip_comment(line, state)
    if !len(strip_line) && len(line)
      continue
    endif

    call add(res, strip_line)
  endwhile
  return res
endfunction "}}}

function! s:mid(value, cnt) "{{{
  return strpart(a:value, a:cnt, len(a:value) - 2 * a:cnt)
endfunction "}}}

function! s:subst_func(line, regexp, func) " {{{
  " Substitute text found by regexp with result of
  " func(matched) function.

  let pos = 0
  let lines = split(a:line, a:regexp, 1)
  let res_line = ""
  for line in lines
    let res_line = res_line.line
    let matched = matchstr(a:line, a:regexp, pos)
    if matched != ""
      let res_line = res_line.{a:func}(matched)
    endif
    let pos = matchend(a:line, a:regexp, pos)
  endfor
  return res_line
endfunction " }}}

function! s:save_vimwiki_buffer() "{{{
  if &filetype == 'vimwiki'
    silent update
  endif
endfunction "}}}

function! s:trim(string) "{{{
  let res = substitute(a:string, '^\s\+', '', '')
  let res = substitute(res, '\s\+$', '', '')
  return res
endfunction "}}}

function! s:get_html_toc(toc_list) "{{{
  " toc_list is list of [level, header_text, header_id]
  " ex: [[1, "Header", "toc1"], [2, "Header2", "toc2"], ...]
  function! s:close_list(toc, plevel, level) "{{{
    let plevel = a:plevel
    while plevel > a:level
      call add(a:toc, '</ul>')
      let plevel -= 1
    endwhile
    return plevel
  endfunction "}}}

  if empty(a:toc_list)
    return []
  endif

  let toc = ['<div class="toc">']
  let level = 0
  let plevel = 0
  for [level, text, id] in a:toc_list
    if level > plevel
      call add(toc, '<ul>')
    elseif level < plevel
      let plevel = s:close_list(toc, plevel, level)
    endif

    let toc_text = s:process_tags_remove_links(text)
    let toc_text = s:process_tags_typefaces(toc_text)
    call add(toc, '<li><a href="#'.id.'">'.toc_text.'</a>')
    let plevel = level
  endfor
  call s:close_list(toc, level, 0)
  call add(toc, '</div>')
  return toc
endfunction "}}}

" insert toc into dest.
function! s:process_toc(dest, placeholders, toc) "{{{
  let toc_idx = 0
  if !empty(a:placeholders)
    for [placeholder, row, idx] in a:placeholders
      let [type, param] = placeholder
      if type == 'toc'
        let toc = a:toc[:]
        if !empty(param)
          call insert(toc, '<h1>'.param.'</h1>')
        endif
        let shift = toc_idx * len(toc)
        call extend(a:dest, toc, row + shift)
        let toc_idx += 1
      endif
    endfor
  endif
endfunction "}}}

" get title.
function! s:process_title(placeholders, default_title) "{{{
  if !empty(a:placeholders)
    for [placeholder, row, idx] in a:placeholders
      let [type, param] = placeholder
      if type == 'title' && !empty(param)
        return param
      endif
    endfor
  endif
  return a:default_title
endfunction "}}}

function! s:is_html_uptodate(wikifile) "{{{
  let tpl_time = -1

  let tpl_file = s:template_full_name('')
  if tpl_file != ''
    let tpl_time = getftime(tpl_file)
  endif

  let wikifile = fnamemodify(a:wikifile, ":p")
  let subdir = vimwiki#subdir(VimwikiGet('path'), wikifile)
  let htmlfile = expand(VimwikiGet('path_html').subdir.
        \fnamemodify(wikifile, ":t:r").".html")

  if getftime(wikifile) <= getftime(htmlfile) && tpl_time <= getftime(htmlfile)
    return 1
  endif
  return 0
endfunction "}}}

function! s:html_insert_contents(html_lines, content) "{{{
  let lines = []
  for line in a:html_lines
    if line =~ '%content%'
      let parts = split(line, '%content%', 1)
      if empty(parts)
        call extend(lines, a:content)
      else
        for idx in range(len(parts))
          call add(lines, parts[idx])
          if idx < len(parts) - 1
            call extend(lines, a:content)
          endif
        endfor
      endif
    else
      call add(lines, line)
    endif
  endfor
  return lines
endfunction "}}}
"}}}

" INLINE TAGS "{{{
function! s:tag_em(value) "{{{
  return '<em>'.s:mid(a:value, 1).'</em>'
endfunction "}}}

function! s:tag_strong(value) "{{{
  return '<strong>'.s:mid(a:value, 1).'</strong>'
endfunction "}}}

function! s:tag_todo(value) "{{{
  return '<span class="todo">'.a:value.'</span>'
endfunction "}}}

function! s:tag_strike(value) "{{{
  return '<del>'.s:mid(a:value, 2).'</del>'
endfunction "}}}

function! s:tag_super(value) "{{{
  return '<sup><small>'.s:mid(a:value, 1).'</small></sup>'
endfunction "}}}

function! s:tag_sub(value) "{{{
  return '<sub><small>'.s:mid(a:value, 2).'</small></sub>'
endfunction "}}}

function! s:tag_code(value) "{{{
  return '<code>'.s:mid(a:value, 1).'</code>'
endfunction "}}}

function! s:tag_pre(value) "{{{
  return '<code>'.s:mid(a:value, 3).'</code>'
endfunction "}}}

function! s:tag_internal_link(value) "{{{
  " Make <a href="This is a link">This is a link</a>
  " from [[This is a link]]
  " Make <a href="link">This is a link</a>
  " from [[link|This is a link]]
  " Make <a href="link">This is a link</a>
  " from [[link][This is a link]]
  " TODO: rename function -- it makes not only internal links.
  " TODO: refactor it.

  function! s:linkify(src, caption, style) "{{{
    if a:style == ''
      let style_str = ''
    else
      let style_str = ' style="'.a:style.'"'
    endif

    if s:is_img_link(a:caption)
      let link = '<a href="'.a:src.'"><img src="'.a:caption.'"'.style_str.' />'.
            \ '</a>'
    elseif vimwiki#is_non_wiki_link(a:src)
      let link = '<a href="'.a:src.'">'.a:caption.'</a>'
    elseif s:is_img_link(a:src)
      let link = '<img src="'.a:src.'" alt="'.a:caption.'"'. style_str.' />'
    elseif vimwiki#is_link_to_dir(a:src)
      if g:vimwiki_dir_link == ''
        let link = '<a href="'.vimwiki#safe_link(a:src).'">'.a:caption.'</a>'
      else
        let link = '<a href="'.vimwiki#safe_link(a:src).
              \ g:vimwiki_dir_link.'.html">'.a:caption.'</a>'
      endif
    else
      let link = '<a href="'.vimwiki#safe_link(a:src).
            \ '.html">'.a:caption.'</a>'
    endif

    return link
  endfunction "}}}

  let value = s:mid(a:value, 2)

  let line = ''
  if value =~ '|'
    let link_parts = split(value, "|", 1)
  else
    let link_parts = split(value, "][", 1)
  endif


  if len(link_parts) > 1
    if len(link_parts) < 3
      let style = ""
    else
      let style = link_parts[2]
    endif

    let line = s:linkify(link_parts[0], link_parts[1], style)

  else
    let line = s:linkify(value, value, '')
  endif
  return line
endfunction "}}}

function! s:tag_external_link(value) "{{{
  "" Make <a href="link">link desc</a>
  "" from [link link desc]

  let value = s:mid(a:value, 1)

  let line = ''
  if s:is_web_link(value)
    let lnkElements = split(value)
    let head = lnkElements[0]
    let rest = join(lnkElements[1:])
    if rest==""
      let rest=head
    endif
    if s:is_img_link(rest)
      if rest!=head
        let line = '<a href="'.head.'"><img src="'.rest.'" /></a>'
      else
        let line = '<img src="'.rest.'" />'
      endif
    else
      let line = '<a href="'.head.'">'.rest.'</a>'
    endif
  elseif s:is_img_link(value)
    let line = '<img src="'.value.'" />'
  else
    " [alskfj sfsf] shouldn't be a link. So return it as it was --
    " enclosed in [...]
    let line = '['.value.']'
  endif
  return line
endfunction "}}}

function! s:tag_wikiword_link(value) "{{{
  " Make <a href="WikiWord">WikiWord</a> from WikiWord
  if a:value[0] == '!'
    return a:value[1:]
  elseif g:vimwiki_camel_case
    let line = '<a href="'.a:value.'.html">'.a:value.'</a>'
    return line
  else
    return a:value
  endif
endfunction "}}}

function! s:tag_barebone_link(value) "{{{
  "" Make <a href="http://habamax.ru">http://habamax.ru</a>
  "" from http://habamax.ru

  if s:is_img_link(a:value)
    let line = '<img src="'.a:value.'" />'
  else
    let line = '<a href="'.a:value.'">'.a:value.'</a>'
  endif
  return line
endfunction "}}}

function! s:tag_no_wikiword_link(value) "{{{
  if a:value[0] == '!'
    return a:value[1:]
  else
    return a:value
  endif
endfunction "}}}

function! s:tag_remove_internal_link(value) "{{{
  let value = s:mid(a:value, 2)

  let line = ''
  if value =~ '|'
    let link_parts = split(value, "|", 1)
  else
    let link_parts = split(value, "][", 1)
  endif

  if len(link_parts) > 1
    if len(link_parts) < 3
      let style = ""
    else
      let style = link_parts[2]
    endif
    let line = link_parts[1]
  else
    let line = value
  endif
  return line
endfunction "}}}

function! s:tag_remove_external_link(value) "{{{
  let value = s:mid(a:value, 1)

  let line = ''
  if s:is_web_link(value)
    let lnkElements = split(value)
    let head = lnkElements[0]
    let rest = join(lnkElements[1:])
    if rest==""
      let rest=head
    endif
    let line = rest
  elseif s:is_img_link(value)
    let line = '<img src="'.value.'" />'
  else
    " [alskfj sfsf] shouldn't be a link. So return it as it was --
    " enclosed in [...]
    let line = '['.value.']'
  endif
  return line
endfunction "}}}

function! s:make_tag(line, regexp, func) "{{{
  " Make tags for a given matched regexp.
  " Exclude preformatted text and href links.

  let patt_splitter = '\(`[^`]\+`\)\|\({{{.\+}}}\)\|'.
        \ '\(<a href.\{-}</a>\)\|\(<img src.\{-}/>\)'
  if '`[^`]\+`' == a:regexp || '{{{.\+}}}' == a:regexp
    let res_line = s:subst_func(a:line, a:regexp, a:func)
  else
    let pos = 0
    " split line with patt_splitter to have parts of line before and after
    " href links, preformatted text
    " ie:
    " hello world `is just a` simple <a href="link.html">type of</a> prg.
    " result:
    " ['hello world ', ' simple ', 'type of', ' prg']
    let lines = split(a:line, patt_splitter, 1)
    let res_line = ""
    for line in lines
      let res_line = res_line.s:subst_func(line, a:regexp, a:func)
      let res_line = res_line.matchstr(a:line, patt_splitter, pos)
      let pos = matchend(a:line, patt_splitter, pos)
    endfor
  endif
  return res_line
endfunction "}}}

function! s:process_tags_remove_links(line) " {{{
  let line = a:line
  let line = s:make_tag(line, '\[\[.\{-}\]\]', 's:tag_remove_internal_link')
  let line = s:make_tag(line, '\[.\{-}\]', 's:tag_remove_external_link')
  return line
endfunction " }}}

function! s:process_tags_typefaces(line) "{{{
  let line = a:line
  let line = s:make_tag(line, g:vimwiki_rxNoWikiWord, 's:tag_no_wikiword_link')
  let line = s:make_tag(line, g:vimwiki_rxItalic, 's:tag_em')
  let line = s:make_tag(line, g:vimwiki_rxBold, 's:tag_strong')
  let line = s:make_tag(line, g:vimwiki_rxTodo, 's:tag_todo')
  let line = s:make_tag(line, g:vimwiki_rxDelText, 's:tag_strike')
  let line = s:make_tag(line, g:vimwiki_rxSuperScript, 's:tag_super')
  let line = s:make_tag(line, g:vimwiki_rxSubScript, 's:tag_sub')
  let line = s:make_tag(line, g:vimwiki_rxCode, 's:tag_code')
  let line = s:make_tag(line, g:vimwiki_rxPreStart.'.\+'.g:vimwiki_rxPreEnd,
        \ 's:tag_pre')
  return line
endfunction " }}}

function! s:process_tags_links(line) " {{{
  let line = a:line
  let line = s:make_tag(line, '\[\[.\{-}\]\]', 's:tag_internal_link')
  let line = s:make_tag(line, '\[.\{-}\]', 's:tag_external_link')
  let line = s:make_tag(line, g:vimwiki_rxWeblink, 's:tag_barebone_link')
  let line = s:make_tag(line, g:vimwiki_rxWikiWord, 's:tag_wikiword_link')
  return line
endfunction " }}}

function! s:process_inline_tags(line) "{{{
  let line = s:process_tags_links(a:line)
  let line = s:process_tags_typefaces(line)
  return line
endfunction " }}}
"}}}

" BLOCK TAGS {{{
function! s:close_tag_pre(pre, ldest) "{{{
  if a:pre[0]
    call insert(a:ldest, "</pre>")
    return 0
  endif
  return a:pre
endfunction "}}}

function! s:close_tag_quote(quote, ldest) "{{{
  if a:quote
    call insert(a:ldest, "</blockquote>")
    return 0
  endif
  return a:quote
endfunction "}}}

function! s:close_tag_para(para, ldest) "{{{
  if a:para
    call insert(a:ldest, "</p>")
    return 0
  endif
  return a:para
endfunction "}}}

function! s:close_tag_table(table, ldest) "{{{
  " The first element of table list is a string which tells us if table should be centered.
  " The rest elements are rows which are lists of columns:
  " ['center', 
  "   ['col1', 'col2', 'col3'],
  "   ['col1', 'col2', 'col3'],
  "   ['col1', 'col2', 'col3']
  " ]
  let table = a:table
  let ldest = a:ldest
  if len(table)
    if table[0] == 'center'
      call add(ldest, "<table class='center'>")
    else
      call add(ldest, "<table>")
    endif

    " Empty lists are table separators.
    " Search for the last empty list. All the above rows would be a table header.
    " We should exclude the first element of the table list as it is a text tag
    " that shows if table should be centered or not.
    let head = 0
    for idx in range(len(table)-1, 1, -1)
      if empty(table[idx])
        let head = idx
        break
      endif
    endfor
    if head > 0
      for row in table[1 : head-1]
        if !empty(filter(row, '!empty(v:val)'))
          call add(ldest, '<tr>')
          call extend(ldest, map(row, '"<th>".s:process_inline_tags(v:val)."</th>"'))
          call add(ldest, '</tr>')
        endif
      endfor
      for row in table[head+1 :]
        call add(ldest, '<tr>')
        call extend(ldest, map(row, '"<td>".s:process_inline_tags(v:val)."</td>"'))
        call add(ldest, '</tr>')
      endfor
    else
      for row in table[1 :]
        call add(ldest, '<tr>')
        call extend(ldest, map(row, '"<td>".s:process_inline_tags(v:val)."</td>"'))
        call add(ldest, '</tr>')
      endfor
    endif
    call add(ldest, "</table>")
    let table = []
  endif
  return table
endfunction "}}}

function! s:close_tag_list(lists, ldest) "{{{
  while len(a:lists)
    let item = remove(a:lists, 0)
    call insert(a:ldest, item[0])
  endwhile
endfunction! "}}}

function! s:close_tag_def_list(deflist, ldest) "{{{
  if a:deflist
    call insert(a:ldest, "</dl>")
    return 0
  endif
  return a:deflist
endfunction! "}}}

function! s:process_tag_pre(line, pre) "{{{
  " pre is the list of [is_in_pre, indent_of_pre]
  let lines = []
  let pre = a:pre
  let processed = 0
  if !pre[0] && a:line =~ '^\s*{{{[^\(}}}\)]*\s*$'
    let class = matchstr(a:line, '{{{\zs.*$')
    let class = substitute(class, '\s\+$', '', 'g')
    if class != ""
      call add(lines, "<pre ".class.">")
    else
      call add(lines, "<pre>")
    endif
    let pre = [1, len(matchstr(a:line, '^\s*\ze{{{'))]
    let processed = 1
  elseif pre[0] && a:line =~ '^\s*}}}\s*$'
    let pre = [0, 0]
    call add(lines, "</pre>")
    let processed = 1
  elseif pre[0]
    let processed = 1
    call add(lines, substitute(a:line, '^\s\{'.pre[1].'}', '', ''))
  endif
  return [processed, lines, pre]
endfunction "}}}

function! s:process_tag_quote(line, quote) "{{{
  let lines = []
  let quote = a:quote
  let processed = 0
  if a:line =~ '^\s\{4,}\S'
    if !quote
      call add(lines, "<blockquote>")
      let quote = 1
    endif
    let processed = 1
    call add(lines, substitute(a:line, '^\s*', '', ''))
  elseif quote
    call add(lines, "</blockquote>")
    let quote = 0
  endif
  return [processed, lines, quote]
endfunction "}}}

function! s:process_tag_list(line, lists) "{{{

  function! s:add_checkbox(line, rx_list, st_tag, en_tag) "{{{
    let st_tag = a:st_tag
    let en_tag = a:en_tag

    let chk = matchlist(a:line, a:rx_list)
    if len(chk) > 0
      if len(chk[1])>0
        "wildcard characters are difficult to match correctly
        if chk[1] =~ '[.*\\^$~]'
          let chk[1] ='\'.chk[1]
        endif
        let completion = match(g:vimwiki_listsyms, chk[1])
        if completion >= 0 && completion <=4 
          let st_tag = '<li class="done'.completion.'">'
        endif
      endif
    endif
    return [st_tag, en_tag]
  endfunction "}}}

  let in_list = (len(a:lists) > 0)

  " If it is not list yet then do not process line that starts from *bold*
  " text.
  if !in_list
    let pos = match(a:line, g:vimwiki_rxBold)
    if pos != -1 && strpart(a:line, 0, pos) =~ '^\s*$'
      return [0, []]
    endif
  endif

  let lines = []
  let processed = 0

  if a:line =~ g:vimwiki_rxListBullet
    let lstSym = matchstr(a:line, '[*-]')
    let lstTagOpen = '<ul>'
    let lstTagClose = '</ul>'
    let lstRegExp = g:vimwiki_rxListBullet
  elseif a:line =~ g:vimwiki_rxListNumber
    let lstSym = '#'
    let lstTagOpen = '<ol>'
    let lstTagClose = '</ol>'
    let lstRegExp = g:vimwiki_rxListNumber
  else
    let lstSym = ''
    let lstTagOpen = ''
    let lstTagClose = ''
    let lstRegExp = ''
  endif

  if lstSym != ''
    " To get proper indent level 'retab' the line -- change all tabs
    " to spaces*tabstop
    let line = substitute(a:line, '\t', repeat(' ', &tabstop), 'g')
    let indent = stridx(line, lstSym)

    let checkbox = '\s*\[\(.\?\)\]\s*'
    let [st_tag, en_tag] = s:add_checkbox(line,
          \ lstRegExp.checkbox, '<li>', '')

    if !in_list
      call add(a:lists, [lstTagClose, indent])
      call add(lines, lstTagOpen)
    elseif (in_list && indent > a:lists[-1][1])
      let item = remove(a:lists, -1)
      call add(lines, item[0])

      call add(a:lists, [lstTagClose, indent])
      call add(lines, lstTagOpen)
    elseif (in_list && indent < a:lists[-1][1])
      while len(a:lists) && indent < a:lists[-1][1]
        let item = remove(a:lists, -1)
        call add(lines, item[0])
      endwhile
    elseif in_list
      let item = remove(a:lists, -1)
      call add(lines, item[0])
    endif

    call add(a:lists, [en_tag, indent])
    call add(lines, st_tag)
    call add(lines,
          \ substitute(a:line, lstRegExp.'\%('.checkbox.'\)\?', '', ''))
    let processed = 1
  elseif in_list > 0 && a:line =~ '^\s\+\S\+'
    if g:vimwiki_list_ignore_newline
      call add(lines, a:line)
    else
      call add(lines, '<br />'.a:line)
    endif
    let processed = 1
  else
    call s:close_tag_list(a:lists, lines)
  endif
  return [processed, lines]
endfunction "}}}

function! s:process_tag_def_list(line, deflist) "{{{
  let lines = []
  let deflist = a:deflist
  let processed = 0
  let matches = matchlist(a:line, '\(^.*\)::\%(\s\|$\)\(.*\)')
  if !deflist && len(matches) > 0
    call add(lines, "<dl>")
    let deflist = 1
  endif
  if deflist && len(matches) > 0
    if matches[1] != ''
      call add(lines, "<dt>".matches[1]."</dt>")
    endif
    if matches[2] != ''
      call add(lines, "<dd>".matches[2]."</dd>")
    endif
    let processed = 1
  elseif deflist
    let deflist = 0
    call add(lines, "</dl>")
  endif
  return [processed, lines, deflist]
endfunction "}}}

function! s:process_tag_para(line, para) "{{{
  let lines = []
  let para = a:para
  let processed = 0
  if a:line =~ '^\s\{,3}\S'
    if !para
      call add(lines, "<p>")
      let para = 1
    endif
    let processed = 1
    call add(lines, a:line)
  elseif para && a:line =~ '^\s*$'
    call add(lines, "</p>")
    let para = 0
  endif
  return [processed, lines, para]
endfunction "}}}

function! s:process_tag_h(line, id) "{{{
  let line = a:line
  let processed = 0
  let h_level = 0
  let h_text = ''
  let h_id = ''
  if a:line =~ g:vimwiki_rxH6
    let h_level = 6
  elseif a:line =~ g:vimwiki_rxH5
    let h_level = 5
  elseif a:line =~ g:vimwiki_rxH4
    let h_level = 4
  elseif a:line =~ g:vimwiki_rxH3
    let h_level = 3
  elseif a:line =~ g:vimwiki_rxH2
    let h_level = 2
  elseif a:line =~ g:vimwiki_rxH1
    let h_level = 1
  endif
  if h_level > 0
    let a:id[h_level] += 1
    " reset higher level ids
    for level in range(h_level+1, 6)
      let a:id[level] = 0
    endfor

    let centered = 0
    if a:line =~ '^\s\+'
      let centered = 1
    endif

    let line = s:trim(line)

    let h_number = ''
    for l in range(1, h_level-1)
      let h_number .= a:id[l].'.'
    endfor
    let h_number .= a:id[h_level]

    let h_id = 'toc_'.h_number

    let h_part = '<h'.h_level.' id="'.h_id.'"'

    if centered
      let h_part .= ' class="justcenter">'
    else
      let h_part .= '>'
    endif

    let h_text = s:trim(strpart(line, h_level, len(line) - h_level * 2))
    if g:vimwiki_html_header_numbering
      let num = matchstr(h_number, 
            \ '^\(\d.\)\{'.(g:vimwiki_html_header_numbering-1).'}\zs.*')
      if !empty(num)
        let num .= g:vimwiki_html_header_numbering_sym
      endif
      let h_text = num.' '.h_text
    endif

    let line = h_part.h_text.'</h'.h_level.'>'
    let processed = 1
  endif
  return [processed, line, h_level, h_text, h_id]
endfunction "}}}

function! s:process_tag_hr(line) "{{{
  let line = a:line
  let processed = 0
  if a:line =~ '^-----*$'
    let line = '<hr />'
    let processed = 1
  endif
  return [processed, line]
endfunction "}}}

function! s:process_tag_table(line, table) "{{{
  function! s:table_empty_cell(value) "{{{
    if a:value =~ '^\s*$'
      return '&nbsp;'
    endif
    return a:value
  endfunction "}}}

  function! s:table_add_row(table, line) "{{{
    if empty(a:table)
      if a:line =~ '^\s\+'
        let row = ['center', []]
      else
        let row = ['normal', []]
      endif
    else
      let row = [[]]
    endif
    return row
  endfunction "}}}

  let table = a:table
  let lines = []
  let processed = 0

  if a:line =~ '^\s*|[-+]\+|\s*$'
    call extend(table, s:table_add_row(a:table, a:line))
    let processed = 1
  elseif a:line =~ '^\s*|.\+|\s*$'
    call extend(table, s:table_add_row(a:table, a:line))

    let processed = 1
    let cells = split(a:line, '\s*|\s*', 1)[1: -2]
    call map(cells, 's:table_empty_cell(v:val)')
    call extend(table[-1], cells)
  else
    let table = s:close_tag_table(table, lines)
  endif
  return [processed, lines, table]
endfunction "}}}

"}}}

" }}}

" WIKI2HTML "{{{
function! s:parse_line(line, state) " {{{
  let state = {}
  let state.para = a:state.para
  let state.quote = a:state.quote
  let state.pre = a:state.pre[:]
  let state.table = a:state.table[:]
  let state.lists = a:state.lists[:]
  let state.deflist = a:state.deflist
  let state.placeholder = a:state.placeholder
  let state.toc = a:state.toc
  let state.toc_id = a:state.toc_id

  let res_lines = []

  let line = s:safe_html(a:line)

  let processed = 0

  " nohtml -- placeholder
  if !processed
    if line =~ '^\s*%nohtml'
      let processed = 1
      let state.placeholder = ['nohtml']
    endif
  endif

  " title -- placeholder
  if !processed
    if line =~ '^\s*%title'
      let processed = 1
      let param = matchstr(line, '^\s*%title\s\zs.*')
      let state.placeholder = ['title', param]
    endif
  endif

  " html template -- placeholder "{{{
  if !processed
    if line =~ '^\s*%template'
      let processed = 1
      let param = matchstr(line, '^\s*%template\s\zs.*')
      let state.placeholder = ['template', param]
    endif
  endif
  "}}}

  " toc -- placeholder "{{{
  if !processed
    if line =~ '^\s*%toc'
      let processed = 1
      let param = matchstr(line, '^\s*%toc\s\zs.*')
      let state.placeholder = ['toc', param]
    endif
  endif
  "}}}

  " pres "{{{
  if !processed
    let [processed, lines, state.pre] = s:process_tag_pre(line, state.pre)
    " pre is just fine to be in the list -- do not close list item here.
    " if processed && len(state.lists)
      " call s:close_tag_list(state.lists, lines)
    " endif
    if processed && len(state.table)
      let state.table = s:close_tag_table(state.table, lines)
    endif
    if processed && state.deflist
      let state.deflist = s:close_tag_def_list(state.deflist, lines)
    endif
    if processed && state.quote
      let state.quote = s:close_tag_quote(state.quote, lines)
    endif
    if processed && state.para
      let state.para = s:close_tag_para(state.para, lines)
    endif
    call extend(res_lines, lines)
  endif
  "}}}

  " lists "{{{
  if !processed
    let [processed, lines] = s:process_tag_list(line, state.lists)
    if processed && state.quote
      let state.quote = s:close_tag_quote(state.quote, lines)
    endif
    if processed && state.pre[0]
      let state.pre = s:close_tag_pre(state.pre, lines)
    endif
    if processed && len(state.table)
      let state.table = s:close_tag_table(state.table, lines)
    endif
    if processed && state.deflist
      let state.deflist = s:close_tag_def_list(state.deflist, lines)
    endif
    if processed && state.para
      let state.para = s:close_tag_para(state.para, lines)
    endif

    call map(lines, 's:process_inline_tags(v:val)')

    call extend(res_lines, lines)
  endif
  "}}}

  " headers "{{{
  if !processed
    let [processed, line, h_level, h_text, h_id] = s:process_tag_h(line, state.toc_id)
    if processed
      call s:close_tag_list(state.lists, res_lines)
      let state.table = s:close_tag_table(state.table, res_lines)
      let state.pre = s:close_tag_pre(state.pre, res_lines)
      let state.quote = s:close_tag_quote(state.quote, res_lines)

      let line = s:process_inline_tags(line)

      call add(res_lines, line)

      " gather information for table of contents
      call add(state.toc, [h_level, h_text, h_id])
    endif
  endif
  "}}}

  " tables "{{{
  if !processed
    let [processed, lines, state.table] = s:process_tag_table(line, state.table)
    call extend(res_lines, lines)
  endif
  "}}}

  " quotes "{{{
  if !processed
    let [processed, lines, state.quote] = s:process_tag_quote(line, state.quote)
    if processed && len(state.lists)
      call s:close_tag_list(state.lists, lines)
    endif
    if processed && state.deflist
      let state.deflist = s:close_tag_def_list(state.deflist, lines)
    endif
    if processed && len(state.table)
      let state.table = s:close_tag_table(state.table, lines)
    endif
    if processed && state.pre[0]
      let state.pre = s:close_tag_pre(state.pre, lines)
    endif
    if processed && state.para
      let state.para = s:close_tag_para(state.para, lines)
    endif

    call map(lines, 's:process_inline_tags(v:val)')

    call extend(res_lines, lines)
  endif
  "}}}

  " horizontal rules "{{{
  if !processed
    let [processed, line] = s:process_tag_hr(line)
    if processed
      call s:close_tag_list(state.lists, res_lines)
      let state.table = s:close_tag_table(state.table, res_lines)
      let state.pre = s:close_tag_pre(state.pre, res_lines)
      call add(res_lines, line)
    endif
  endif
  "}}}

  " definition lists "{{{
  if !processed
    let [processed, lines, state.deflist] = s:process_tag_def_list(line, state.deflist)

    call map(lines, 's:process_inline_tags(v:val)')

    call extend(res_lines, lines)
  endif
  "}}}

  "" P "{{{
  if !processed
    let [processed, lines, state.para] = s:process_tag_para(line, state.para)
    if processed && len(state.lists)
      call s:close_tag_list(state.lists, lines)
    endif
    if processed && state.quote
      let state.quote = s:close_tag_quote(state.quote, res_lines)
    endif
    if processed && state.pre[0]
      let state.pre = s:close_tag_pre(state.pre, res_lines)
    endif
    if processed && len(state.table)
      let state.table = s:close_tag_table(state.table, res_lines)
    endif

    call map(lines, 's:process_inline_tags(v:val)')

    call extend(res_lines, lines)
  endif
  "}}}

  "" add the rest
  if !processed
    call add(res_lines, line)
  endif

  return [res_lines, state]

endfunction " }}}

function! vimwiki_html#Wiki2HTML(path, wikifile) "{{{

  let starttime = reltime()  " start the clock
  echo 'Generating HTML ... '
  if !s:syntax_supported()
    echomsg 'vimwiki: Only vimwiki_default syntax supported!!!'
    return
  endif

  let wikifile = fnamemodify(a:wikifile, ":p")
  let subdir = vimwiki#subdir(VimwikiGet('path'), wikifile)

  let lsource = s:remove_comments(readfile(wikifile))
  let ldest = []

  let path = expand(a:path).subdir
  call vimwiki#mkdir(path)

  " nohtml placeholder -- to skip html generation.
  let nohtml = 0

  " template placeholder
  let template_name = ''

  " for table of contents placeholders.
  let placeholders = []

  " current state of converter
  let state = {}
  let state.para = 0
  let state.quote = 0
  let state.pre = [0, 0] " [in_pre, indent_pre]
  let state.table = []
  let state.deflist = 0
  let state.lists = []
  let state.placeholder = []
  let state.toc = []
  let state.toc_id = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0 }

  for line in lsource
    let oldquote = state.quote
    let [lines, state] = s:parse_line(line, state)

    " Hack: There could be a lot of empty strings before s:process_tag_quote
    " find out `quote` is over. So we should delete them all. Think of the way
    " to refactor it out.
    if oldquote != state.quote
      call s:remove_blank_lines(ldest)
    endif

    if !empty(state.placeholder)
      if state.placeholder[0] == 'nohtml'
        let nohtml = 1
        break
      elseif state.placeholder[0] == 'template'
        let template_name = state.placeholder[1]
      else
        call add(placeholders, [state.placeholder, len(ldest), len(placeholders)])
      endif
      let state.placeholder = []
    endif

    call extend(ldest, lines)
  endfor


  if nohtml
    echon "\r"."%nohtml placeholder found"
    return
  endif

  let toc = s:get_html_toc(state.toc)
  call s:process_toc(ldest, placeholders, toc)
  call s:remove_blank_lines(ldest)

  "" process end of file
  "" close opened tags if any
  let lines = []
  call s:close_tag_quote(state.quote, lines)
  call s:close_tag_para(state.para, lines)
  call s:close_tag_pre(state.pre, lines)
  call s:close_tag_list(state.lists, lines)
  call s:close_tag_def_list(state.deflist, lines)
  call s:close_tag_table(state.table, lines)
  call extend(ldest, lines)

  let title = s:process_title(placeholders, fnamemodify(a:wikifile, ":t:r"))

  let html_lines = s:get_html_template(subdir, a:wikifile, template_name)

  " processing template variables (refactor to a function)
  call map(html_lines, 'substitute(v:val, "%title%", "'. title .'", "g")')
  call map(html_lines, 'substitute(v:val, "%root_path%", "'.
        \ s:root_path(subdir) .'", "g")')
  let html_lines = s:html_insert_contents(html_lines, ldest) " %contents%
  
  

  "" make html file.
  let wwFileNameOnly = fnamemodify(wikifile, ":t:r")
  call writefile(html_lines, path.wwFileNameOnly.'.html')

  " measure the elapsed time and cut away miliseconds and smaller
  let elapsedtimestr = matchstr(reltimestr(reltime(starttime)),'\d\+\(\.\d\d\)\=')
  echon "\r".wwFileNameOnly.'.html written (time: '.elapsedtimestr.'s)'
endfunction "}}}

function! vimwiki_html#WikiAll2HTML(path) "{{{
  if !s:syntax_supported()
    echomsg 'vimwiki: Only vimwiki_default syntax supported!!!'
    return
  endif

  echomsg 'Saving vimwiki files...'
  let save_eventignore = &eventignore
  let &eventignore = "all"
  let cur_buf = bufname('%')
  bufdo call s:save_vimwiki_buffer()
  exe 'buffer '.cur_buf
  let &eventignore = save_eventignore

  let path = expand(a:path)
  call vimwiki#mkdir(path)

  echomsg 'Deleting non-wiki html files...'
  call s:delete_html_files(path)

  echomsg 'Converting wiki to html files...'
  let setting_more = &more
  setlocal nomore

  let wikifiles = split(glob(VimwikiGet('path').'**/*'.VimwikiGet('ext')), '\n')
  for wikifile in wikifiles
    if !s:is_html_uptodate(wikifile)
      echomsg 'Processing '.wikifile
      call vimwiki_html#Wiki2HTML(path, wikifile)
    else
      echomsg 'Skipping '.wikifile
    endif
  endfor
  call s:create_default_CSS(path)
  echomsg 'Done!'

  let &more = setting_more
endfunction "}}}
"}}}
