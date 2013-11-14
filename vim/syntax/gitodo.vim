" Vim syntax file
" Language:     Gitodo
" Maintainer:   Vain <pcode@uninformativ.de>
" Last Change:  2013 November 14

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
	syntax clear
elseif exists("b:current_syntax")
	finish
endif

syn match gtkey "\v^(prio|when|dead|what|subject|warn):"
syn match gtkey "^nocron$"
syn match gtsubjectline "\v(^(what|subject): )@<=.{0,41}"

hi def link gtkey Identifier
hi def link gtsubjectline String

let b:current_syntax = "gitodo"
