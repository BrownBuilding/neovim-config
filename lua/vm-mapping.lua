vim.cmd([[
let g:VM_maps = {}
let g:VM_maps['Find Under']                  = '<C-g>' " default keybinding overwrites ctrl-n (the well known emacs keybinding for DOWN)
let g:VM_maps['Find Subword Under']          = '<C-g>'
let g:VM_maps["Select All"]                  = '\\A' 
let g:VM_maps["Start Regex Search"]          = '\\/'
let g:VM_maps["Add Cursor Down"]             = '<M-j>'
let g:VM_maps["Add Cursor Up"]               = '<M-k>'
let g:VM_maps["Add Cursor At Pos"]           = '\\\'

let g:VM_maps["Visual Regex"]                = '\\/'
let g:VM_maps["Visual All"]                  = '\\A' 
let g:VM_maps["Visual Add"]                  = '\\a'
let g:VM_maps["Visual Find"]                 = '\\f'
let g:VM_maps["Visual Cursors"]              = '\\c' 
]])
