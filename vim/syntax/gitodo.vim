" Vim syntax file
" Language:     Gitodo
" Maintainer:   Vain <pcode@uninformativ.de>
" Last Change:  2010 Dec 11

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
	syntax clear
elseif exists("b:current_syntax")
	finish
endif

syn match gtkey "\v^(prio|when|dead|what|subject|warn):"
syn match gtsubjectline contains=gtumlaut "\v(^(what|subject): )@<=.*"
syn match gtumlaut "\vö|Ö|ä|Ä|ü|Ü|ß"

hi def link gtkey Identifier
hi def link gtsubjectline String
hi def link gtumlaut ErrorMsg

let b:current_syntax = "gitodo"
