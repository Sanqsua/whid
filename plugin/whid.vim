if exists('g:loaded_whid') | finish | endif " prevents loading the file twice

set s:save_cpo = &cpo " save user coptions

" command to run our plugin
command! Whid lua require'whid'.whid()

let &cpo = s:save_cpo " and restore after 

unlet s:save_cpo

let g:loaded_whid = 1 

"explanation of s:save_cpo
"let s:save_cpo = &cpo is a common practice preventing custom coptions (sequence of single character flags) to interfere with the plugin. For our own purposes, the lack of this line would probably not hurt, but it is considered as good practice (at least according to the vim help files). There is also command! Whid lua require'whid'.whid() which requires plugin's lua module and calls its main function.
"
