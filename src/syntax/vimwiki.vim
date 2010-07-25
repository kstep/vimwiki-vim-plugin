" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=79
" Vimwiki syntax file
" Author: Maxim Kim <habamax@gmail.com>
" Home: http://code.google.com/p/vimwiki/

" Quit if syntax file is already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

"" use max highlighting - could be quite slow if there are too many wikifiles
if VimwikiGet('maxhi')
  " Every WikiWord is nonexistent
  if g:vimwiki_camel_case
    execute 'syntax match VimwikiNoExistsLink /'.g:vimwiki_rxWikiWord.'/'
    execute 'syntax match VimwikiNoExistsLinkT /'.g:vimwiki_rxWikiWord.'/ contained'
  endif
  execute 'syntax match VimwikiNoExistsLink /'.g:vimwiki_rxWikiLink1.'/ contains=VimwikiNoLinkChar'
  execute 'syntax match VimwikiNoExistsLink /'.g:vimwiki_rxWikiLink2.'/ contains=VimwikiNoLinkChar'

  execute 'syntax match VimwikiNoExistsLinkT /'.g:vimwiki_rxWikiLink1.'/ contained'
  execute 'syntax match VimwikiNoExistsLinkT /'.g:vimwiki_rxWikiLink2.'/ contained'

  " till we find them in vimwiki's path
  call vimwiki#WikiHighlightLinks()
else
  " A WikiWord (unqualifiedWikiName)
  execute 'syntax match VimwikiLink /\<'.g:vimwiki_rxWikiWord.'\>/'
  " A [[bracketed wiki word]]
  execute 'syntax match VimwikiLink /'.g:vimwiki_rxWikiLink1.'/ contains=VimwikiLinkChar'
  execute 'syntax match VimwikiLink /'.g:vimwiki_rxWikiLink2.'/ contains=VimwikiLinkChar'

  execute 'syntax match VimwikiLinkT /\<'.g:vimwiki_rxWikiWord.'\>/ contained'
  execute 'syntax match VimwikiLinkT /'.g:vimwiki_rxWikiLink1.'/ contained'
  execute 'syntax match VimwikiLinkT /'.g:vimwiki_rxWikiLink2.'/ contained'
endif

execute 'syntax match VimwikiLink `'.g:vimwiki_rxWeblink.'`'

syn match VimwikiLinkChar contained /\[\[/ conceal
syn match VimwikiLinkChar contained /\]\]/ conceal
syn match VimwikiLinkChar contained /\[\[[^\[\]\|]\{-}|\ze.\{-}]]/ conceal
syn match VimwikiLinkChar contained /\[\[[^\[\]\|]\{-}]\[\ze.\{-}]]/ conceal

syn match VimwikiNoLinkChar contained /\[\[/ conceal
syn match VimwikiNoLinkChar contained /\]\]/ conceal
syn match VimwikiNoLinkChar contained /\[\[[^\[\]\|]\{-}|\ze.*]]/ conceal
syn match VimwikiNoLinkChar contained /\[\[[^\[\]\|]\{-}]\[\ze.*]]/ conceal

" Emoticons
syntax match VimwikiEmoticons /\%((.)\|:[()|$@]\|:-[DOPS()\]|$@]\|;)\|:'(\)/

let g:vimwiki_rxTodo = '\C\%(TODO:\|DONE:\|STARTED:\|FIXME:\|FIXED:\|XXX:\)'
execute 'syntax match VimwikiTodo /'. g:vimwiki_rxTodo .'/'

" Load concrete Wiki syntax
execute 'runtime! syntax/vimwiki_'.VimwikiGet('syntax').'.vim'



" Tables
" execute 'syntax match VimwikiTable /'.g:vimwiki_rxTable.'/'
" syntax conceal off
syntax match VimwikiTableRow /^\s*|.\+|\s*$/ 
      \ transparent contains=VimwikiCellSeparator,VimwikiLinkT,
      \ VimwikiNoExistsLinkT,VimwikiEmoticons,VimwikiTodo,
      \ VimwikiBoldT,VimwikiItalicT,VimwikiBoldItalicT,VimwikiItalicBoldT,
      \ VimwikiDelTextT,VimwikiSuperScriptT,VimwikiSubScriptT,VimwikiCodeT
syntax match VimwikiCellSeparator 
      \ /\%(|\)\|\%(-\@<=+\-\@=\)\|\%([|+]\@<=-\+\)/ contained
" syntax conceal on

" List items
execute 'syntax match VimwikiList /'.g:vimwiki_rxListBullet.'/'
execute 'syntax match VimwikiList /'.g:vimwiki_rxListNumber.'/'
execute 'syntax match VimwikiList /'.g:vimwiki_rxListDefine.'/'

execute 'syntax match VimwikiBold /'.g:vimwiki_rxBold.'/ contains=VimwikiBoldChar'
execute 'syntax match VimwikiBoldT /'.g:vimwiki_rxBold.'/ contained contains=VimwikiBoldCharT'

execute 'syntax match VimwikiItalic /'.g:vimwiki_rxItalic.'/ contains=VimwikiItalicChar'
execute 'syntax match VimwikiItalicT /'.g:vimwiki_rxItalic.'/ contained contains=VimwikiItalicCharT'

execute 'syntax match VimwikiBoldItalic /'.g:vimwiki_rxBoldItalic.'/ contains=VimwikiBoldItalicChar,VimwikiItalicBoldChar'
execute 'syntax match VimwikiBoldItalicT /'.g:vimwiki_rxBoldItalic.'/ contained contains=VimwikiBoldItalicChatT,VimwikiItalicBoldCharT'

execute 'syntax match VimwikiItalicBold /'.g:vimwiki_rxItalicBold.'/ contains=VimwikiBoldItalicChar,VimwikiItalicBoldChar'
execute 'syntax match VimwikiItalicBoldT /'.g:vimwiki_rxItalicBold.'/ contained contains=VimwikiBoldItalicCharT,VimsikiItalicBoldCharT'

execute 'syntax match VimwikiDelText /'.g:vimwiki_rxDelText.'/ contains=VimwikiDelTextChar'
execute 'syntax match VimwikiDelTextT /'.g:vimwiki_rxDelText.'/ contained contains=VimwikiDelTextChar'

execute 'syntax match VimwikiSuperScript /'.g:vimwiki_rxSuperScript.'/ contains=VimwikiSuperScriptChar'
execute 'syntax match VimwikiSuperScriptT /'.g:vimwiki_rxSuperScript.'/ contained contains=VimwikiSuperScriptCharT'

execute 'syntax match VimwikiSubScript /'.g:vimwiki_rxSubScript.'/ contains=VimwikiSubScriptChar'
execute 'syntax match VimwikiSubScriptT /'.g:vimwiki_rxSubScript.'/ contained contains=VimwikiSubScriptCharT'

execute 'syntax match VimwikiCode /'.g:vimwiki_rxCode.'/ contains=VimwikiCodeChar'
execute 'syntax match VimwikiCodeT /'.g:vimwiki_rxCode.'/ contained contains=VimwikiCodeCharT'

" <hr> horizontal rule
execute 'syntax match VimwikiHR /'.g:vimwiki_rxHR.'/'

execute 'syntax region VimwikiPre start=/'.g:vimwiki_rxPreStart.
      \ '/ end=/'.g:vimwiki_rxPreEnd.'/ contains=VimwikiComment'

" List item checkbox
syntax match VimwikiCheckBox /\[.\?\]/
if g:vimwiki_hl_cb_checked
  execute 'syntax match VimwikiCheckBoxDone /'.
        \ g:vimwiki_rxListBullet.'\s*\['.g:vimwiki_listsyms[4].'\].*$/'.
        \ ' contains=VimwikiNoExistsLink,VimwikiLink'
  execute 'syntax match VimwikiCheckBoxDone /'.
        \ g:vimwiki_rxListNumber.'\s*\['.g:vimwiki_listsyms[4].'\].*$/'.
        \ ' contains=VimwikiNoExistsLink,VimwikiLink'
endif

" placeholders
syntax match VimwikiPlaceholder /^\s*%toc\%(\s.*\)\?$/
syntax match VimwikiPlaceholder /^\s*%nohtml\s*$/

" html tags
syntax match VimwikiHTMLtag '<br\s*/\?>'
syntax match VimwikiHTMLtag '<hr\s*/\?>'

syntax region VimwikiComment start='<!--' end='-->'

if !vimwiki#hl_exists("VimwikiHeader1")
  execute 'syntax match VimwikiHeader /'.g:vimwiki_rxHeader.'/ contains=VimwikiTodo'
else
  " Header levels, 1-6
  execute 'syntax match VimwikiHeader1 /'.g:vimwiki_rxH1.'/ contains=VimwikiTodo,VimwikiHeaderChar'
  execute 'syntax match VimwikiHeader2 /'.g:vimwiki_rxH2.'/ contains=VimwikiTodo,VimwikiHeaderChar'
  execute 'syntax match VimwikiHeader3 /'.g:vimwiki_rxH3.'/ contains=VimwikiTodo,VimwikiHeaderChar'
  execute 'syntax match VimwikiHeader4 /'.g:vimwiki_rxH4.'/ contains=VimwikiTodo,VimwikiHeaderChar'
  execute 'syntax match VimwikiHeader5 /'.g:vimwiki_rxH5.'/ contains=VimwikiTodo,VimwikiHeaderChar'
  execute 'syntax match VimwikiHeader6 /'.g:vimwiki_rxH6.'/ contains=VimwikiTodo,VimwikiHeaderChar'
endif

" group names "{{{
if !vimwiki#hl_exists("VimwikiHeader1")
  hi def link VimwikiHeader Title
else
  hi def link VimwikiHeader1 Title
  hi def link VimwikiHeader2 Title
  hi def link VimwikiHeader3 Title
  hi def link VimwikiHeader4 Title
  hi def link VimwikiHeader5 Title
  hi def link VimwikiHeader6 Title
endif

hi def VimwikiBold term=bold cterm=bold gui=bold
hi def link VimwikiBoldT VimwikiBold

hi def VimwikiItalic term=italic cterm=italic gui=italic
hi def link VimwikiItalicT VimwikiItalic

hi def VimwikiBoldItalic term=bold cterm=bold gui=bold,italic
hi def link VimwikiItalicBold VimwikiBoldItalic
hi def link VimwikiBoldItalicT VimwikiBoldItalic
hi def link VimwikiItalicBoldT VimwikiBoldItalic

hi def link VimwikiCode PreProc
hi def link VimwikiCodeT VimwikiCode

hi def link VimwikiNoExistsLink Error
hi def link VimwikiNoExistsLinkT VimwikiNoExistsLink

hi def link VimwikiPre PreProc
hi def link VimwikiPreT VimwikiPre

hi def link VimwikiLink Underlined
hi def link VimwikiLinkT Underlined

hi def link VimwikiList Function
hi def link VimwikiCheckBox VimwikiList
hi def link VimwikiCheckBoxDone Comment
hi def link VimwikiEmoticons Character

hi def link VimwikiDelText Constant
hi def link VimwikiDelTextT VimwikiDelText

hi def link VimwikiSuperScript Number
hi def link VimwikiSuperScriptT VimwikiSuperScript

hi def link VimwikiSubScript Number
hi def link VimwikiSubScriptT VimwikiSubScript

hi def link VimwikiTodo Todo
hi def link VimwikiComment Comment

hi def link VimwikiCellSeparator SpecialKey
hi def link VimwikiPlaceholder SpecialKey
hi def link VimwikiHTMLtag SpecialKey

hi def link VimwikiBoldChar Ignore
hi def link VimwikiItalicChar Ignore
hi def link VimwikiBoldItalicChar Ignore
hi def link VimwikiItalicBoldChar Ignore
hi def link VimwikiDelTextChar Ignore
hi def link VimwikiSuperScriptChar Ignore
hi def link VimwikiSubScriptChar Ignore
hi def link VimwikiCodeChar Ignore
hi def link VimwikiHeaderChar Ignore
hi def link VimwikiLinkChar VimwikiLink
hi def link VimwikiNoLinkChar VimwikiNoExistsLink

hi def link VimwikiBoldCharT Ignore
hi def link VimwikiItalicCharT Ignore
hi def link VimwikiBoldItalicCharT Ignore
hi def link VimwikiItalicBoldCharT Ignore
hi def link VimwikiDelTextCharT Ignore
hi def link VimwikiSuperScriptCharT Ignore
hi def link VimwikiSubScriptCharT Ignore
hi def link VimwikiCodeCharT Ignore
hi def link VimwikiHeaderCharT Ignore
hi def link VimwikiLinkCharT VimwikiLinkT
hi def link VimwikiNoLinkCharT VimwikiNoExistsLinkT
"}}}

let b:current_syntax="vimwiki"

" EMBEDDED syntax setup "{{{
let nested = VimwikiGet('nested_syntaxes')
if !empty(nested)
  for [hl_syntax, vim_syntax] in items(nested)
    call vimwiki#nested_syntax(vim_syntax, 
          \ '^{{{\%(.*[[:blank:][:punct:]]\)\?'.
          \ hl_syntax.'\%([[:blank:][:punct:]].*\)\?',
          \ '^}}}', 'VimwikiPre')
  endfor
endif
"}}}
