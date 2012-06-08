function! IM_OpenMarkdown()
   if (g:im_server_state == "notstarted")
      call IM_StartServer()
   endif
   call IM_SendMarkdown()
endfunction

function! IM_StartServer()
   silent! exec "!echo " . IM_GetBufferAsShellString() . " | instant-markdown-d &>/dev/null &"
   let g:im_server_state = "started"
endfunction

function! IM_UpdateMarkdown()
   if (g:im_last_number_of_changes == -1 || g:im_last_number_of_changes != b:changetick)
      g:im_last_number_of_changes = b:changetick
      call IM_SendMarkdown()
   endif
endfunction

function! IM_SendMarkdown()
   silent! exec "!echo " . IM_GetBufferAsShellString() . " | curl -X PUT -T - http://localhost:8090/ &>/dev/null &"
endfunction

function! IM_GetBufferAsShellString()
   let current_buffer = join(getbufline("%", 1, "$"), "\n")
   return escape(shellescape(current_buffer), "%!#")
endfunction

function! IM_CloseServer()
   if (g:im_server_state == "started")
      silent! exec "silent! !curl -s -X DELETE http://localhost:8090/ &>/dev/null &"
   endif
endfunction

let g:im_server_state = "notstarted"
let g:im_last_number_of_changes = -1

autocmd BufEnter *.{md,mkd,mkdn,mark*} silent call IM_OpenMarkdown()
autocmd InsertLeave *.{md,mkd,mkdn,mark*} silent call IM_UpdateMarkdown()
autocmd VimLeavePre * silent call IM_CloseServer()
autocmd BufWritePost *.{md,mkd,mkdn,mark*} silent call IM_UpdateMarkdown()
