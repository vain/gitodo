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

syn match gtprio "^prio:"
syn match gtwhen "^when:"
syn match gtdead "^dead:"
syn match gtwhat "^what:"
syn match gtsubject "^subject:"

syn match gtumlaut "\vö|Ö|ä|Ä|ü|Ü|ß"

hi def link gtprio Identifier
hi def link gtwhen gtprio
hi def link gtdead gtprio
hi def link gtwhat gtprio
hi def link gtsubject gtprio

hi def link gtumlaut ErrorMsg

let b:current_syntax = "gitodo"
