" Coppied from the example .vimrc file and then modified
"
" Maintainer: Joel Haker
" Last change: 08/25/17

"-------------------------------------------------------------------------------
" => These options and commands enable some very useful features in Vim, that no 
"    user should have to live without.
"-------------------------------------------------------------------------------

" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" *** Only for Winows vim Version ***
" Activate all the handy Windows key-bindings we're used to.
if has("win64") || has("win32")
	source $VIMRUNTIME/mswin.vim
	behave mswin
endif

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Sets how many lines of history VIM has to remember
set history=500

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on

" Set to auto read when a file is changed from the outside
set autoread

" Enable syntax highlighting
syntax on

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file
let mapleader = " "
let g:mapleader = " "

" Fast saving and quiting
nmap <silent> <leader>w :w!<cr>
nmap <silent> <leader>Q :q!<cr>

" :W - sudo save (useful for handling the permission-denied error)
command W w !sudo tee % > /dev/null
" :Q - exit without any changes
command Q q! 


"-------------------------------------------------------------------------------
" Vim-Plug -> https://github.com/junegunn/vim-plug (plugin manager)
"-------------------------------------------------------------------------------
" Commands:
" PlugInstall  -> Install plugins
" PlugUpdate   -> Install or update plugins  
" PlugClean[!] -> Remove unused directories (! = clean without prompt)
" PlugUpgrade  -> Upgrade vim-plug itself
" PlugStatus   -> Check the status of plugins
" PlugDiff     -> Examine changes from the previous update and the pending changes
" PlugSnapshot[!] [outputpath] -> Create script to restore current snapshot of plugins

" Start Vim-plug
call plug#begin('~/.vim/plugged')

" -> Colorschemes 
Plug 'NLKNguyen/papercolor-theme'
Plug 'phanviet/vim-monokai-pro'

" -> Plugins
" https://github.com/junegunn/fzf.vim -> Fzf for vim
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } 
" https://github.com/sheerun/vim-polygloti -> Comprehensive language pack 
Plug 'sheerun/vim-polyglot' 
" https://github.com/tpope/vim-commentary -> Commenting plugin 
Plug 'tpope/vim-commentary' 

" End &&  Initialize plugin system
call plug#end()


"-------------------------------------------------------------------------------
" Colorscheme && Gui Settings for both terminal and GUI
"-------------------------------------------------------------------------------
" Set Term color setting to 256 colors
set t_Co=256

set background=dark

if has('gui_running')

    " font & font size
    if has("gui_macvim")
        set guifont=Menlo\ Regular:h16
    elseif has("gui_win64") || has("gui_win32")
        set guifont=Droid_Sans_Mono:h12
    else
        set guifont=Droid\ Sans\ Mono\ 16
    endif

    "set guioptions-=m  "remove menu bar
    set guioptions-=T   "remove toolbar
    set guioptions-=r   "remove right-hand scroll bar
    set guioptions-=L   "remove left-hand scroll bar

    "colorscheme pablo
    colorscheme PaperColor
else
    "colorscheme pablo
    colorscheme PaperColor
endif

"augroup vimrc 
"   autocmd!
"   autocmd ColorScheme * highlight Normal ctermbg=none guibg=black
"   autocmd ColorScheme * highlight NonText ctermbg=none guibg=black
"augroup END


"-------------------------------------------------------------------------------
" => Must have options (Highly recommended options.)
"-------------------------------------------------------------------------------
" Vim with default settings does not allow easy switching between multiple
" files in the same editor window. Users can use multiple split windows or
" multiple tab pages to edit multiple files, but it is still best to enable 
" an option to allow easier switching between files.

" One such option is the 'hidden' option, which allows you to re-use the 
" same window and switch from an unsaved buffer without saving it first. 
" Also allows you to keep an undo history for multiple files when re-using 
" the same window in this way. Note that using persistent undo also lets 
" you undo in multiple files even in the same window, but is less 
" efficient and is actually designed for keeping undo history after closing 
" Vim entirely. Vim will complain if you try to quit without saving, and 
" swap files will keep you safe if your computer crashes.
set hidden

" Note that not everyone likes working this way (with the hidden option).
" Alternatives include using tabs or split windows instead of re-using 
" the same window as mentioned above, and/or either of the following options:
" set confirm
" set autowriteall
 
" Better command-line completion
set wildmenu
 
" Show partial commands in the last line of the screen
set showcmd

" highlight matching [{()}]
set showmatch          

" Makes search act like search in modern browsers
set incsearch
 
" Highlight searches 
" Use <C-L> to temporarily turn off highlighting; See the mapping of <C-L> below
set hlsearch

" Modelines have historically been a source of security vulnerabilities. As
" such, it may be a good idea to disable them and use the securemodelines
" script, <http://www.vim.org/scripts/script.php?script_id=1876>.
set nomodeline


"-------------------------------------------------------------------------------
" => Usability options
"-------------------------------------------------------------------------------
" These are options that users frequently set in their .vimrc. Some of them
" change Vim's behaviour in ways which deviate from the true Vi way, but
" which are considered to add usability. Which, if any, of these options to
" use is very much a personal preference, but they are harmless.

" Don't redraw while executing macros (good performance config)
set lazyredraw 

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase
 
" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent
 
" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline
 
" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler
 
" Always display the status line, even if only one window is displayed
set laststatus=2
 
" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm
 
" Use visual bell instead of beeping when doing something wrong
set visualbell
 
" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
" set t_vb=
 
" Enable use of the mouse for all modes
if has('gui_running')
    set mouse=a
else
    set mouse=
endif
 
" Set the command window height to 2 lines, to avoid many cases of having to press <Enter> to continue"
set cmdheight=2
 
" Display line numbers on the left
set number
 
" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200
 
" Use <F10> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F10>

" For regular expressions turn magic on
set magic

" Set hilighted cursor line
set cursorline

"-------------------------------------------------------------------------------
" => Indentation optiondif & Hidden characters
"-------------------------------------------------------------------------------

" Be smart when using tabs ;)
set smarttab

" Indentation settings for using 4 spaces instead of tabs.
" Do not change 'tabstop' from its default value of 8 with this setup.
set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab

" Viewing hidden characters
set listchars=eol:¬,tab:▸\ ,space:\.

"-------------------------------------------------------------------------------
" => User Defined Function
"-------------------------------------------------------------------------------

fu! ToggleCurline ()
  if &cursorline 
    set nocursorline
  else
    set cursorline
  endif
endfunction

"-------------------------------------------------------------------------------
" => User Defined Mappings
"-------------------------------------------------------------------------------

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy, 
" which is the default
nmap Y y$

" Map <C-L> (redraw screen) to also turn off search highlighting until the next search
"nmap <C-L> :noh<CR><C-L>

" Disable highlight when <leader><cr> is pressed
nmap <silent> <leader><CR> :noh<CR><C-L>

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo, so that 
" you can undo CTRL-U after inserting a line break.
"inoremap <C-U> <C-G>u<C-U>

" set mouse functions
map <silent> <leader>m  :set mouse=<CR>
map <silent> <leader>ma :set mouse=a<CR>
map <silent> <leader>mn :set mouse=n<CR>
map <silent> <leader>mv :set mouse=v<CR>
map <silent> <leader>mi :set mouse=i<CR>
map <silent> <leader>mc :set mouse=c<CR>

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Move up/down editor lines
nnoremap j gj
nnoremap k gk

" Close the current buffer
noremap <silent> <leader><S-q> :bd<CR>
noremap <silent> <leader><C-q> :tabclose<CR>

" Move in between buffers
noremap <leader>l :bnext<CR>
noremap <leader>h :bprevious<CR>
noremap <leader><S-l> :tabn<CR>
noremap <leader><S-h> :tabp<CR>

" Call hilight line and column
map <silent> <leader>- :call ToggleCurline()<CR>

" Netrw Open and return from explorer
nmap <silent> <leader>E :Explore<CR>
nmap <silent> <leader>R :Rex<CR>

" Proper clipboard copy / paste
vmap <silent> <leader>rc "+y
vmap <silent> <leader>rx "+c
nmap <silent> <leader>rv k"+p
vmap <silent> <leader>rv c<ESC>k"+p
imap <silent> <C-v> <ESC>k"+p


"---------------------------
" Vim FZF mappings
"---------------------------
" Open a file in new buffer
nnoremap <silent> <leader>f<leader> :call fzf#run({
\   'sink': 'e',
\   'options': '--multi'
\ })<CR>
" Open a file in a new tab
nnoremap <silent> <leader>ft :call fzf#run({
\   'sink': 'tabedit', 
\   'options': '--multi'
\ })<CR>
" Open a file in a new vertical split
nnoremap <silent> <leader>fv :call fzf#run({
\   'right': winwidth('.') / 2,
\   'sink': 'vertical split'
\ })<CR>
" Open a file in a new horizontial split
nnoremap <silent> <leader>fh :call fzf#run({
\   'down': winwidth('.') / 2,
\   'sink': 'split'
\ })<CR>
" Choose color scheme using fzf 
nnoremap <silent> <leader><S-p> :call fzf#run({
\   'source': map(split(globpath(&rtp, "colors/*.vim"), "\n"),
\   "substitute(fnamemodify(v:val, ':t'), '\\..\\{-}$', '', '')"),
\   'sink': 'colo',
\   'options': '+m',
\   'left': 30
\ })<CR>

"-------------------------------------------------------------------------------
" User Defined Commands
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Syntax Highlighting
"-------------------------------------------------------------------------------

" Forthe Smarty file type
au BufRead,BufNewFile *.tpl set filetype=smarty
" For any .bash_* files
autocmd BufRead .bash_*   set syntax=sh

