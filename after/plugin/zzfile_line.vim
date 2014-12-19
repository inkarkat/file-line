" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_file_line') || (v:version < 700)
	finish
endif
let g:loaded_file_line = 1

function! s:gotoline()
	let file = bufname("%")

	" :e command calls BufRead even though the file is a new one.
	" As a workarround Jonas Pfenniger<jonas@pfenniger.name> added an
	" AutoCmd BufRead, this will test if this file actually exists before
	" searching for a file and line to goto.
	if (filereadable(file))
		return
	endif

	" Accept file:line:column: or file:line:column and file:line also
	let names =  matchlist( file, '\(.\{-1,}\):\%(\(\d\+\)\%(:\(\d*\):\?\)\?\)\?$')

	if empty(names)
		return
	endif

	let file_name = names[1]
	let line_num  = names[2] == ''? '0' : names[2]
	let  col_num  = names[3] == ''? '0' : names[3]

	if filereadable(file_name)
		let l:bufn = bufnr("%")

		let edit_cmd = 'edit ' . ingo#compat#fnameescape(file_name)
		if argc() > 0
			let argidx = argidx()
			if file ==# argv(argidx)
				exec (argidx + 1) . 'argdelete'
				exec argidx . 'argadd' ingo#compat#fnameescape(file_name)
				let edit_cmd = (argidx + 1) . 'argument'
			endif
		endif

		exec "keepalt" edit_cmd
		exec line_num . "normal! " . col_num . '|'
		if foldlevel(line_num) > 0
			exec "normal! zv"
		endif
		exec "normal! zz"

		exec l:bufn "bwipeout"
	endif

endfunction

autocmd! BufNewFile *:* nested call s:gotoline()
autocmd! BufRead *:* nested call s:gotoline()
