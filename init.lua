-- thank you https://boltless.me/posts/neovim-config-without-plugins-2025/ !!!

vim.cmd.colorscheme('habamax')
vim.cmd.tnoremap('<Esc>', '<C-\\><C-n>')
vim.cmd.set('relativenumber')
vim.cmd.set('number')
vim.cmd.set('ignorecase')
vim.cmd.set('smartcase')
vim.cmd.set('noswapfile')
vim.cmd.set('signcolumn=yes') -- prevent window from shfiting sidways on appreance  of diagnostics
vim.cmd.set('errorformat+=%f(%l\\\\,%c)%m') -- errorformat for free pascal
vim.opt.scrolloff = 10
vim.opt.completeopt = "fuzzy,menu,menuone,noselect"
vim.opt.list = true
-- vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.listchars = "tab:» ,trail:·,nbsp:␣"

-- Thaknk you u/gmes78 !
vim.o.tabstop = 4      -- A TAB character looks like 4 spaces
vim.o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
vim.o.softtabstop = 4  -- Number of spaces inserted instead of a TAB character
vim.o.shiftwidth = 4   -- Number of spaces inserted when indenting



if vim.g.neovide then
    vim.cmd.tnoremap('<C-[>', '<C-\\><C-n>')
    local scale_factors = {1.6, 1.55, 1.3, 0.95 --[[not 1 because neovide won't fill in the last column otherwise]], 0.8, 0.4}
    local scale_factor_idx = 4

    vim.g.neovide_cursor_antialiasing = false
    vim.g.neovide_scale_factor = scale_factors[scale_factor_idx]

    vim.keymap.set({'x', 'n', 'v'}, '<C-->', function()
        if scale_factor_idx <= #scale_factors then
            scale_factor_idx = scale_factor_idx + 1
            vim.g.neovide_scale_factor = scale_factors[scale_factor_idx]
        end
    end, {desc="increase neovides scale factor"})

    vim.keymap.set({'x', 'n', 'v'}, '<C-=>', function()
        if scale_factor_idx > 0 then
            scale_factor_idx = scale_factor_idx - 1
            vim.g.neovide_scale_factor = scale_factors[scale_factor_idx]
        end
    end, {desc="decrease neovides scale factor"})

    local function toggle_fullscreen()
        vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
    end

    vim.api.nvim_create_user_command('Fullscreen', function(_)
        toggle_fullscreen()
    end, {
        desc = "Toggle fullscreen when using neovide"
    })

    -- map Alt+Enter to toggling fullscreen
    vim.keymap.set({'x', 'n', 'v'}, '<M-cr>', toggle_fullscreen, {desc="Toggle fullscreen in neovide"})
end

if vim.uv.os_uname().sysname == "Windows" then
    print("this is a windows machine")
    vim.keymap.set('t', '<C-p>', function() return '<Up>' end, { expr = true })
    vim.keymap.set('t', '<C-n>', function() return '<Down>' end, { expr = true })
    -- vim.keymap.set('t', '<C-w>', function() return '<C-<BS>>' end, { expr = true })

    -- make yanking so system's clipboard work in wsl
    vim.cmd([[
        let g:clipboard = {
                    \   'name': 'WslClipboard',
                    \   'copy': {
                    \      '+': 'clip.exe',
                    \      '*': 'clip.exe',
                    \    },
                    \   'paste': {
                    \      '+': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                    \      '*': 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                   \   },
                    \   'cache_enabled': 0,
                    \ }
    ]])
end

-- require("vm-mapping")

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

-- Auto-install lazy.nvim if not present
if vim.uv.fs_stat(lazypath) == nil then
    print('Installing lazy.nvim....')
    local git_clone_result = vim.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', --branch=stable', -- latest stable release
        lazypath,
    }):wait()
    print(git_clone_result.stdout)
    if git_clone_result.code ~= 0 then
        print('Could not git clone lazy.nvim:')
        print(git_clone_result.stderr)
        print('aborting')
        do return end
    end
    print('Done.')
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'BurntSushi/ripgrep',
            'sharkdp/fd',
        },
    },
    { 'kylechui/nvim-surround', tag = 'v3.1.0' },
    { 'blazkowolf/gruber-darker.nvim' },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" }
    },
    { 'rose-pine/neovim', name = 'rose-pine' },
    { 'stevearc/oil.nvim',
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {
            default_file_explorer = false,
            columns = {
                "permissions",
                "size",
                "mtime",
            },
            delete_to_trash = true,
            watch_for_cahnges = true,
            view_options = {
                show_hidden = true
            },
        },
        dependencies = {}
    },

    { 'rebelot/kanagawa.nvim' },
    { 'j-hui/fidget.nvim' },
    { 'tpope/vim-fugitive' },
})

-- require("cmp").setup({
--     sources = { name = 'nvim_lsp' },
--     snippet = { expand = function(args) vim.snippet.expand(args.body) end }
-- })

vim.diagnostic.config({ virtual_text = true })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })
    end
  end,
})

-- thank you https://boltless.me/posts/neovim-config-without-plugins-2025/

-- local compatibilities = require('cmp_nvim_lsp').default_capabilities()

-- # Langauge Servers

-- I am keeping a 'personal' record of all my lsp configs so that i can iterate
-- over them for my user command :LspStart. vim.lsp.config allows access to
-- individual configs via the subscript operator but does not allow iterating
-- via iparis.
local my_lsps = {}
local function vim_lsp_config(name, config)
    vim.lsp.config(name, config)
    table.insert(my_lsps, name)
    -- my_lsp_config_record[name] = true--vim.lsp.config[name]
end

vim_lsp_config('lua_ls', {
    cmd = { "lua-language-server" },
    root_markers = { ".luarc.json", ".luarc.jsonc" },
    filetypes = { 'lua' },
    settings = {
        runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
            checkThirdParty = false,
            library = {
                vim.env.VIMRUNTIME
                -- Depending on the usage, you might want to add additional paths here.
                -- "${3rd}/luv/library"
                -- "${3rd}/busted/library",
            }
            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
            -- library = vim.api.nvim_get_runtime_file("", true)
        }
    }
})
vim.lsp.enable('lua_ls')

vim_lsp_config('clangd', {
    cmd = { 'clangd' }, -- --completion-style=detailed
    root_markers = { ".clangd", "compile_commands.json" },
    filetypes = { 'c', 'cpp', 'cxx' },
})
vim.lsp.enable('clangd')

vim_lsp_config('rust-analyzer', {
    cmd = { 'rust-analyzer' },
    root_markers = { "Cargo.toml", "Cargo.lock" },
    filetypes = { 'rust', 'rs' },
})
vim.lsp.enable('rust-analyzer')

vim_lsp_config('ols', {
    cmd = { 'ols' },
    filetypes = { 'odin' },
    root_markers = { "ols.json", ".git", "*.odin" },
    settings = { checker_args = "-vet-unused" },
})
vim.lsp.enable('ols')

vim_lsp_config('pylsp', {
    cmd = { 'pylsp' },
    filetypes = { 'py' },
    settings = { pylsp = { plugins = { pylint = { enabled = true } } } }
})
vim.lsp.enable('pylsp')

vim_lsp_config('tinymist', {
    cmd = { 'tinymist' },
    filetypes = { 'typst' },
})
vim.lsp.enable('tinymist')


-- local lsp_zero = require("lsp-zero")
-- lsp_zero.setup_servers({
--     'zls',
--     'clangd',
--     'rust_analyzer',
--     -- 'marksman',
--     'pylsp',
--     -- 'lua_ls',
--     'texlab',
--     'jdtls',
--     'cmake',
--     'ols',
-- })

vim.keymap.set('n', 'gl', vim.diagnostic.open_float)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration)
vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help)
vim.keymap.set('n', 'go', vim.lsp.buf.type_definition)


-- require('nvim-treesitter.configs').setup {
--     -- A list of parser names, or "all" (the listed parsers MUST always be installed)
--     -- ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
--     ensure_installed = { "c", "lua", "rust", "markdown", "markdown_inline" },
--
--     -- Install parsers synchronously (only applied to `ensure_installed`)
--     sync_install = false,
--
--     -- Automatically install missing parsers when entering buffer
--     -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
--     auto_install = false,
--
--     -- List of parsers to ignore installing (or "all")
--     ignore_install = { "latex" },
--
--     ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
--     -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!
--
--     highlight = {
--         enable = true,
--         disable = { "latex" },
--     },
-- }
--

-- require('lspconfig').lua_ls.setup {
--     on_init = function(client)
--         local path = client.workspace_folders[1].name
--         if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
--             return
--         end
--         client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
--             runtime = {
--                 -- Tell the language server which version of Lua you're using
--                 -- (most likely LuaJIT in the case of Neovim)
--                 version = 'LuaJIT'
--             },
--             -- Make the server aware of Neovim runtime files
--             workspace = {
--                 checkThirdParty = false,
--                 library = {
--                     vim.env.VIMRUNTIME
--                     -- Depending on the usage, you might want to add additional paths here.
--                     -- "${3rd}/luv/library"
--                     -- "${3rd}/busted/library",
--                 }
--                 -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
--                 -- library = vim.api.nvim_get_runtime_file("", true)
--             }
--         })
--     end,
--     settings = {
--         Lua = {}
--     }
-- }


-- setting up telescope
local telescope_builtin = require("telescope.builtin")
vim.keymap.set('n', '<Space>f', function()
    telescope_builtin.find_files({
        hidden = false,
        no_ignore = false,
    })
end)

vim.keymap.set('n', '<Space>F', function()
    telescope_builtin.find_files({
        hidden = true,
        no_igonre = true,
        no_ignore_parent = true,
        prompt_title = "Find Hidden Files (no ignore)",
    })
end)

-- telescope keybindings
vim.keymap.set('n', '<Space>b', function()
    telescope_builtin.buffers()
end)
vim.keymap.set('n', '<Space>D', function()
    telescope_builtin.diagnostics({ prompt_title = "diagnostics" })
end)
vim.keymap.set('n', '<Space>d', function()
    telescope_builtin.diagnostics({ bufnr = 0, prompt_title = "diagnostics for current buffer" }) --
end)
vim.keymap.set('n', '<Space>s', function()
    telescope_builtin.lsp_document_symbols()
end)
vim.keymap.set('n', '<Space>S', function()
    telescope_builtin.lsp_workspace_symbols()
end)
vim.keymap.set('n', '<Space>/', function()
    telescope_builtin.live_grep({})
end)
vim.keymap.set('n', '<Space>k', function()
    telescope_builtin.keymaps({})
end)
vim.keymap.set('n', '<Space>a', vim.lsp.buf.code_action)
vim.keymap.set({'n', 'x'}, '<Space>r', function()
    telescope_builtin.resume({})
end)
vim.keymap.set('n', '<Space>q', function()
    telescope_builtin.quickfix({})
end)

-- oil
vim.keymap.set('n', '<Space>o', function()
    vim.cmd("Oil")
end)

vim.api.nvim_create_user_command('Format', function(args)
    vim.cmd("LspZeroFormat")
end, {})

vim.api.nvim_create_user_command('Cmd', function(_)
    vim.cmd("term cmd.exe") -- used for developing on windows with wsl
end, {})

vim.api.nvim_create_user_command('BW', function()
    vim.cmd(":bn|:bd#")
end, {})

vim.api.nvim_create_user_command("LspStop", function(ops)
    local clients = vim.lsp.get_clients({bufnr = vim.api.nvim_get_current_buf()})
    for _, c in ipairs(clients) do
        c:stop()
        print("stopped '"..c.name.."'")
    end
    -- vim.ui.select({
    --     prompt = 'Which LSP-Server do you want to stop',
    --     format_item = function(item)
    --     end
    -- })
end, {
    nargs='*',
    desc='Stop the lsp-server(s) attached to the current buffer.'
})

vim.api.nvim_create_user_command("LspStart", function(ops)
    local function lsp_configs_by_file_type(file_type)
        local configs = {}
        for _, lsp_name in ipairs(my_lsps) do
            local c = vim.lsp.config[lsp_name]
            if c.filetypes ~= nil then
                for _, cft in ipairs(c.filetypes) do
                    if cft == file_type then
                        table.insert(configs, c)
                        break
                    end
               end
            else
                -- from :h vim.lsp.Config (with added emphasis):
                -- > • {filetypes}?     (`string[]`) Filetypes the client will attach to, if
                -- >                    activated by `vim.lsp.enable()`. If not provided,
                -- >                    then the client **will attach to all filetypes**.
                table.insert(configs, c)
            end
        end
        return configs
    end

    -- local clients = vim.lsp.get_clients({bufnr = vim.api.nvim_get_current_buf()})
    local configs = lsp_configs_by_file_type(vim.bo.filetype)
    for _, c in ipairs(configs) do
        vim.lsp.start(c)
        print("starting '"..c.name.."'")
    end
end, {
    nargs='*',
    desc='Start the lsp-server(s) attached to the current buffer.'
})

vim.api.nvim_create_user_command("LspEnable", function(ops)
    for _, lsp_name in pairs(my_lsps) do
        vim.lsp.enable(lsp_name, true)
    end
end, {
    nargs='*',
    desc='Enable all the configured lsp-servers.'
})

vim.api.nvim_create_user_command("LspDisable", function(ops)
    for _, lsp_name in pairs(my_lsps) do
        vim.lsp.enable(lsp_name, false)
    end
end, {
    nargs='*',
    desc='Disable all the configured lsp-servers'
})

vim.api.nvim_create_user_command("PrintLspNames", function(ops)
    local clients = vim.lsp.get_clients({bufnr = vim.api.nvim_get_current_buf()})
    if #clients == 0 then
        print("no clients")
    end
    for _, c in ipairs(clients) do
        print(c.name)
        -- local c_config = vim.lsp.config[c.name]
        -- if c_config ~= nil then
        --     vim.lsp.start(c_config)
        --     print("starting '"..c.name.."'")
        -- else
        --     print("could not find config for "..c.name)
        -- end
    end
end, {
    nargs='*',
    complete='shellcmd',
    desc='Start the lsp-server(s) attached to the current buffer.'
})

-- local function lsp_client_names(current)
--     local clients
--     if current then
--         clients = vim.lsp.get_clients({bufnr = vim.api.nvim_get_current_buf()})
--     else
--         clients = vim.lsp.get_clients()
--     end
--     local client_names = {}
--     for _, c in ipairs(clients) do
--         table.insert(client_names, c.name)
--     end
--     return client_names
-- end

-- -- TODO: Disable the lsp servers attached to the current buffer only when no
-- -- lsp server is specified (by name). Ohterwise disable the lsp-server that was
-- -- specified by name. Also support command completion by providing the names
-- -- of all the lsp-servers.
-- vim.api.nvim_create_user_command("LspDisable", function(ops)
--     if #ops.fargs == 0 then
--         -- local clients = vim.lsp.get_clients({bufnr = vim.api.nvim_get_current_buf()})
--         local current_client_names = lsp_client_names(true)
--         vim.lsp.enable(current_client_names, false)
--     else
--         vim.lsp.enable(ops.fargs, false)
--     end
-- end, {
--     nargs='?',
--     desc='Disable lsp-server(s) attached to the current buffer.',
--     complete=function(_, _, _)
--         return lsp_client_names(false)
--     end
-- })



vim.api.nvim_create_user_command('TreesitterStop', function()
    vim.treesitter.stop()
end, {})

vim.api.nvim_create_user_command('TreesitterStart', function()
    vim.treesitter.start()
end, {})

vim.api.nvim_create_user_command('PylintDisable', function()
    vim.lsp.config['pylsp'] = { settings = { pylsp = { plugins = { pylint = { enabled = false } } } } }
end, {})

vim.api.nvim_create_user_command('PylintEnable', function()
    vim.lsp.config['pylsp'] = { settings = { pylsp = { plugins = { pylint = { enabled = true } } } } }
end, {})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = { "*.tex" },
    command = "set ft=tex",
})
vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = { "Cargo.lock" },
    command = "set ft=toml",
})

-- thank you kickstart
vim.api.nvim_create_autocmd("TextYankPost", {
    desc="Hightlight yanknkop",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", {clear = true}),
    callback = function() vim.highlight.on_yank() end,
})

-- The following is no longer needed as of neovim v0.11+
-- -- Make ']<Space>' and '[<Space>' insert new line while staying
-- -- in normal mode.
-- vim.keymap.set('n', ']<Space>', function()
--     return "o<Escape>k"
-- end, { expr = true })
-- vim.keymap.set('n', '[<Space>', function()
--     return "O<Escape>j"
-- end, { expr = true })

-- -- # Setting up leap keybindings
-- -- require('leap').create_default_mappings()
-- vim.keymap.set({'n', 'x', 'o'}, 's',  '<Plug>(leap)')
-- vim.keymap.set({'n', 'x', 'o'}, '<leader>s', '<Plug>(leap-from-window)')

vim.keymap.set({'n', 'x', 'o',}, '<leader>n', '<cmd>noh<cr>')
vim.keymap.set({'n', 'x', 'o',}, '<leader>g', '<cmd>G log --graph --all --oneline --decorate<cr>')


-- harpoon
local harpoon = require("harpoon")
harpoon:setup()

vim.keymap.set('n', '<Space>hh', function()
    harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set('n', '<Space>ha', function()
    harpoon:list():add()
    local list_item = vim.api.nvim_buf_get_name(
        vim.api.nvim_get_current_buf()
    )
    print("Added "..list_item.." file to harpoon list")
end)

local recycle_terminal = require("recycle-terminal")
vim.keymap.set('n', '<Space>t', function()
    recycle_terminal.reuse_terminal()
end)

vim.api.nvim_create_user_command("T", function(ops)
    -- local args = ""
    -- for _, a in ipairs(ops.fargs) do
    --     args = args .. " " .. a
    -- end
    -- print(args)
    -- vim.cmd("split | term " .. args)
    vim.cmd("split |  term "..ops.args)
end, {
    nargs = "*",
    complete = "shellcmd",
    desc = "create a throw away terminal with vertical split",
})

vim.keymap.set("n", "<space>1", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<space>2", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<space>3", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<space>4", function() harpoon:list():select(4) end)
vim.keymap.set("n", "<space>5", function() harpoon:list():select(5) end)

-- vim surround
require("nvim-surround").setup({})

require("rose-pine").setup({
    variant = "moon",      -- auto, main, moon, or dawn
    dark_variant = "moon", -- main, moon, or dawn
    dim_inactive_windows = false,
    extend_background_behind_borders = false,

    enable = {
        terminal = true,
        legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
        migrations = true,        -- Handle deprecated options automatically
    },

    styles = {
        bold = true,
        italic = true,
        transparency = true,
    },

    groups = {
        border = "muted",
        link = "iris",
        panel = "surface",

        error = "love",
        hint = "iris",
        info = "foam",
        note = "pine",
        todo = "rose",
        warn = "gold",

        git_add = "foam",
        git_change = "rose",
        git_delete = "love",
        git_dirty = "rose",
        git_ignore = "muted",
        git_merge = "iris",
        git_rename = "pine",
        git_stage = "iris",
        git_text = "rose",
        git_untracked = "subtle",

        h1 = "iris",
        h2 = "foam",
        h3 = "rose",
        h4 = "gold",
        h5 = "pine",
        h6 = "foam",
    },

    highlight_groups = {
        -- fg = "muted"
        -- Comment = { fg = "foam" },
        -- VertSplit = { fg = "muted", bg = "muted" },
    },

    before_highlight = function(group, highlight, palette)
        -- Disable all undercurls
        -- if highlight.undercurl then
        --     highlight.undercurl = false
        -- end
        --
        -- Change palette colour
        -- if highlight.fg == palette.pine then
        --     highlight.fg = palette.foam
        -- end
    end,
})

-- Remember to run `:KanagawaCompile`
require('kanagawa').setup({
    transparent = true,
})

-- vim.cmd("colorscheme kanagawa-dragon")
vim.cmd("colorscheme gruber-darker")
-- vim.cmd("colorscheme rose-pine")

-- startup warning message
local warning_messages = {
    "Has anyone really been far even as decided to use even go want to do look more like?",
    "Did you know? If you put a wooden spoon on your pot while it's boiling, the pot spoon water will the spill water pot, the boiling pot water steam spoon wood.",
    "Ladies can you married a man who he is did not be that him he when is for and them date important why ladies?",
    "kijetesantakalu.",
    "Hello. My name is Inigo Montoya. You killed my father. Prepare to die.",
    "Why do they call it oven when you of in the cold food out hot eat the food.",
    "You'd have to stop the world just to stop the feeling.",
    "There is a certain logic to your logic.",
    "The fun will now commence.",
    "It's never just the shape below. Love is a kaleidoscope.",
    "A guilty conscience is a small price to pay for the safty of the Alpha-Quadrant",
    "We will start with the assumption that I am not crazy",
    "I don't care what happened to you. It should have happened to us. together. I love you.",
    "Do you picture me like I picture you?",
    "I used to have ant farm but I had to get rid of it because I couldn't find tractors that small",
    "IT'S NOT ABOUT THE PARAKEET",
    "I miss my wife, Tails. I miss her a lot",
    "One cherry is not worth twelve bits",
    "Why make things difficult, when it is possible to make them cryptic and totally illogical, with just a little bit more effort?", -- Aksel Peter Jørgensen (https://www.jjj.de/fxt/fxtbook.pdf)
    "42 is one of the designated funny numbers", -- jan Misali (paraphrased from https://www.youtube.com/watch?v=l-unefmAo9k&list=PLuYLhuXt4HrQqnfSceITmv6T_drx1hN84)
    "This is an automatic game with no opportuninty for skill, which is why it's so suitable for family play.", -- "The Mathematics of Games"
}
-- print("[WARNING] " .. warning_messages[math.random(#warning_messages)])
