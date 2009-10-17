fun! JsLint()

    w%
    let file = getcwd()."/".expand("%")

    execute ":Scratch"

    execute ":0,%delete"

    if has('mac')
        execute "r !/opt/local/bin/js ~/bin/jslint.js ".file." \"`cat ".file."`\""
    elseif has('unix')
        execute "r !/usr/bin/js ~/bin/jslint.js ".file." \"`cat ".file."`\""
    endif

endfun

nmap ,s :call JsLint()<cr>

