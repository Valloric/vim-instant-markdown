function! s:OpenMarkdown()
   if (g:im_server_state == "notstarted")
      call s:StartServer()
   endif
   call s:SendMarkdown()
endfunction

function! s:StartServer()
   silent! exec "!echo " . s:GetBufferAsShellString() . " | instant-markdown-d &>/dev/null &"
   let g:im_server_state = "started"
endfunction

function! s:UpdateMarkdown()
   if (g:im_server_state == "notstarted")
     return
   endif

   if (g:im_last_number_of_changes == -1 || g:im_last_number_of_changes != b:changetick)
      g:im_last_number_of_changes = b:changetick
      call s:SendMarkdown()
   endif
endfunction

function! s:SendMarkdown()
   silent! exec "!echo " . s:GetBufferAsShellString() . " | curl -X PUT -T - http://localhost:8090/ &>/dev/null &"
endfunction

function! s:GetBufferAsShellString()
   let current_buffer = join(getbufline("%", 1, "$"), "\n")
   return escape(shellescape(current_buffer), "%!#")
endfunction

function! s:CloseServer()
   if (g:im_server_state == "started")
      silent! exec "silent! !curl -s -X DELETE http://localhost:8090/ &>/dev/null &"
   endif
endfunction

let g:im_server_state = "notstarted"
let g:im_last_number_of_changes = -1

autocmd InsertLeave *.{md,mkd,mkdn,mark*} silent call s:UpdateMarkdown()
autocmd VimLeavePre * silent call s:CloseServer()
autocmd BufWritePost *.{md,mkd,mkdn,mark*} silent call s:UpdateMarkdown()

command! StartMarkdownServer call <sid>OpenMarkdown()
command! StopMarkdownServer call <sid>CloseServer()
