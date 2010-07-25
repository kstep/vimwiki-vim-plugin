" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=79
" Vimwiki syntax file
" Default syntax
" Author: Maxim Kim <habamax@gmail.com>
" Home: http://code.google.com/p/vimwiki/

" text: *strong*
" let g:vimwiki_rxBold = '\*[^*]\+\*'
let g:vimwiki_rxBold = '\%(^\|\s\|[[:punct:]]\)\@<='.
      \'\*'.
      \'\%([^*`[:space:]][^*`]*[^*`[:space:]]\|[^*`[:space:]]\)'.
      \'\*'.
      \'\%([[:punct:]]\|\s\|$\)\@='
syn match VimwikiBoldChar contained "*" conceal
syn match VimwikiBoldCharT contained "*"

" text: _emphasis_
" let g:vimwiki_rxItalic = '_[^_]\+_'
let g:vimwiki_rxItalic = '\%(^\|\s\|[[:punct:]]\)\@<='.
      \'_'.
      \'\%([^_`[:space:]][^_`]*[^_`[:space:]]\|[^_`[:space:]]\)'.
      \'_'.
      \'\%([[:punct:]]\|\s\|$\)\@='
syn match VimwikiItalicChar contained "_" conceal
syn match VimwikiItalicCharT contained "_"

" text: *_bold italic_* or _*italic bold*_
let g:vimwiki_rxBoldItalic = '\%(^\|\s\|[[:punct:]]\)\@<='.
      \'\*_'.
      \'\%([^*_`[:space:]][^*_`]*[^*_`[:space:]]\|[^*_`[:space:]]\)'.
      \'_\*'.
      \'\%([[:punct:]]\|\s\|$\)\@='
syn match VimwikiBoldItalicChar contained "\*_" conceal
syn match VimwikiBoldItalicCharT contained "\*_"

let g:vimwiki_rxItalicBold = '\%(^\|\s\|[[:punct:]]\)\@<='.
      \'_\*'.
      \'\%([^*_`[:space:]][^*_`]*[^*_`[:space:]]\|[^*_`[:space:]]\)'.
      \'\*_'.
      \'\%([[:punct:]]\|\s\|$\)\@='
syn match VimwikiItalicBoldChar contained "_\*" conceal
syn match VimwikiItalicBoldCharT contained "_\*"

" text: `code`
let g:vimwiki_rxCode = '`[^`]\+`'
syn match VimwikiCodeChar contained "`" conceal
syn match VimwikiCodeCharT contained "`"

" text: ~~deleted text~~
let g:vimwiki_rxDelText = '\~\~[^~`]\+\~\~'
syn match VimwikiDelTextChar contained "\~\~" conceal
syn match VimwikiDelTextCharT contained "\~\~"

" text: ^superscript^
let g:vimwiki_rxSuperScript = '\^[^^`]\+\^'
syn match VimwikiSuperScriptChar contained "^" conceal
syn match VimwikiSuperScriptCharT contained "^"

" text: ,,subscript,,
let g:vimwiki_rxSubScript = ',,[^,`]\+,,'
syn match VimwikiSubScriptChar contained ",," conceal
syn match VimwikiSubScriptCharT contained ",,"

" Header levels, 1-6
let g:vimwiki_rxH1 = '^\s*=\{1}[^=]\+.*[^=]\+=\{1}\s*$'
let g:vimwiki_rxH2 = '^\s*=\{2}[^=]\+.*[^=]\+=\{2}\s*$'
let g:vimwiki_rxH3 = '^\s*=\{3}[^=]\+.*[^=]\+=\{3}\s*$'
let g:vimwiki_rxH4 = '^\s*=\{4}[^=]\+.*[^=]\+=\{4}\s*$'
let g:vimwiki_rxH5 = '^\s*=\{5}[^=]\+.*[^=]\+=\{5}\s*$'
let g:vimwiki_rxH6 = '^\s*=\{6}[^=]\+.*[^=]\+=\{6}\s*$'
let g:vimwiki_rxHeader = '\%('.g:vimwiki_rxH1.'\)\|'.
      \ '\%('.g:vimwiki_rxH2.'\)\|'.
      \ '\%('.g:vimwiki_rxH3.'\)\|'.
      \ '\%('.g:vimwiki_rxH4.'\)\|'.
      \ '\%('.g:vimwiki_rxH5.'\)\|'.
      \ '\%('.g:vimwiki_rxH6.'\)'

syn match VimwikiHeaderChar contained "\%(^\s*=\+\)\|\%(=\+\s*$\)"

" <hr>, horizontal rule
let g:vimwiki_rxHR = '^----.*$'

" List items start with optional whitespace(s) then '* ' or '# '
let g:vimwiki_rxListBullet = '^\s*\%(\*\|-\)\s'
let g:vimwiki_rxListNumber = '^\s*#\s'

let g:vimwiki_rxListDefine = '::\(\s\|$\)'

" Preformatted text
let g:vimwiki_rxPreStart = '{{{'
let g:vimwiki_rxPreEnd = '}}}'
