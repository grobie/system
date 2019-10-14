" swap files
set directory=$HOME/.vim/swapfiles//

" vim bundles
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()

" solarized colors
let g:solarized_termtrans = 1
set background=dark
colorscheme solarized

set number
set relativenumber
set cursorline
set colorcolumn=80

set tabstop=4
set shiftwidth=4

" shortcuts
set pastetoggle=<F2>

" automatically delete trailing Dos-returns,whitespace
autocmd BufRead,BufWritePre,FileWritePre * silent! %s/[\r \t]\+$//

set wildmenu
set wildmode=list:longest,full

let g:go_fmt_command = "goimports"

noremap <Leader>W :w !sudo tee % > /dev/null

au FileType go nmap <Leader>s <Plug>(go-implements)
au FileType go nmap <Leader>i <Plug>(go-info)
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <Leader>gb <Plug>(go-doc-browser)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)
au FileType go nmap <Leader>e <Plug>(go-rename)
au FileType go nmap <Leader>ds <Plug>(go-def-split)

nmap <F8> :TagbarToggle<CR>
