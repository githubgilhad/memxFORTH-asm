.. vim: ft=rst showbreak=--»\  noexpandtab fileencoding=utf-8 nomodified   wrap textwidth=0 foldmethod=marker foldmarker={{{,}}} foldcolumn=4 ruler showcmd lcs=tab\:|- list tabstop=8 noexpandtab nosmarttab softtabstop=0 shiftwidth=0 linebreak  


:date: 2026.03.21 12:56:01
:_modified: 1970.01.01 00:00:00
:tags: HowTo
:authors: Gilhad
:summary: vim_colors
:title: vim_colors
:nice_title: |logo| %title% |logo|

%HEADER%

vim_colors
--------------------------------------------------------------------------------

konvence 
**\*_s** safe - changes only its arguments
**\*_x** **un**\_safe - side effects

.. code::

	" ~/.vim/syntax/asm.vim
	
	
	" ----- FORTH project: -------
	"
	
	syn match asmCallNormal "\<call\s\+[a-zA-Z_.][a-zA-Z0-9_.]*\>"
	syn match asmCallSafe "\<call\s\+[a-zA-Z_.][a-zA-Z0-9_.]*_s\>"
	
	hi def asmCallNormal ctermfg=4 ctermbg=6  cterm=bold  " blue on cyan
	hi def asmCallSafe   ctermfg=2  cterm=bold            " green
	
	syn match asmFuncDecl "^\s*\%(func\|gfunc\|obj\|gobj\)\>" nextgroup=asmFuncName skipwhite
	syn match asmFuncName "\<[a-zA-Z_][a-zA-Z0-9_]*\>" contained
	
	hi def link asmFuncName Label
	hi def link asmFuncDecl Keyword
	
	syn match asmSafeSymbol "\<[a-zA-Z_][a-zA-Z0-9_]*_s\>"
	hi def asmSafeSymbol ctermfg=2  cterm=bold            " green
	
	syn match asmUnSafeSymbol "\<[a-zA-Z_][a-zA-Z0-9_]*_x\>"
	" hi def asmUnSafeSymbol ctermfg=4 ctermbg=6  cterm=bold  " blue on cyan
	hi def asmUnSafeSymbol ctermfg=1 ctermbg=0  cterm=bold  " red on black
	
	
	" -----------------------------------
