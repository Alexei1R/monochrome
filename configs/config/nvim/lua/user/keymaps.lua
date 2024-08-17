local nnoremap = require("user.keymap_utils").nnoremap
local vnoremap = require("user.keymap_utils").vnoremap
local inoremap = require("user.keymap_utils").inoremap
local tnoremap = require("user.keymap_utils").tnoremap
local xnoremap = require("user.keymap_utils").xnoremap
local harpoon_ui = require("harpoon.ui")
local harpoon_mark = require("harpoon.mark")



local M = {}

_G.insert_template = function()
    -- Get the current filename in uppercase and replace dots with underscores
    local file_name = vim.fn.expand("%:t"):gsub("%.", "_"):upper()

    -- Current date
    local date_today = os.date("%Y-%m-%d")

    -- Template text
    local text = string.format("//\n" ..
        "// Created by toor on %s.\n" ..
        "//\n\n" ..
        "#ifndef %s\n" ..
        "#define %s\n\n" ..
        "#endif\n",
        date_today, file_name, file_name)

    -- Go to the start of the document
    vim.api.nvim_win_set_cursor(0, { 1, 0 })

    -- Insert the text at the beginning of the buffer
    vim.api.nvim_buf_set_lines(0, 0, 0, false, vim.split(text, "\n", true))
end

-- Map the function to <leader>nn
vim.api.nvim_set_keymap('n', '<leader>nn', '<cmd>lua _G.insert_template()<CR>', { noremap = true, silent = true })

-- Save with leader key
vim.api.nvim_set_keymap('n', '<leader>w', '<cmd>w<cr>', { noremap = true, silent = false })

-- Quit with leader key
vim.api.nvim_set_keymap('n', '<leader>q', '<cmd>q<cr>', { noremap = true, silent = false })

-- Save and Quit with leader key
vim.api.nvim_set_keymap('n', '<leader>z', '<cmd>wq<cr>', { noremap = true, silent = false })

-- Map Oil to <leader>e
vim.api.nvim_set_keymap('n', '<leader>e', "<cmd>lua require('oil').toggle_float()<cr>", { noremap = true, silent = true })

-- Center buffer while navigating
local navigation_mappings = {
    ["<C-u>"] = "<C-u>zz",
    ["<C-d>"] = "<C-d>zz",
    ["{"] = "{zz",
    ["}"] = "}zz",
    ["N"] = "Nzz",
    ["n"] = "nzz",
    ["G"] = "Gzz",
    ["gg"] = "ggzz",
    ["<C-i>"] = "<C-i>zz",
    ["<C-o>"] = "<C-o>zz",
    ["%"] = "%zz",
    ["*"] = "*zz",
    ["#"] = "#zz",
}

for key, cmd in pairs(navigation_mappings) do
    vim.api.nvim_set_keymap('n', key, cmd, { noremap = true, silent = true })
end

-- Press 'S' for quick find/replace for the word under the cursor
vim.api.nvim_set_keymap('n', 'S', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { noremap = true, silent = false })

-- Press 'H', 'L' to jump to start/end of a line (first/last char)
vim.api.nvim_set_keymap('n', 'L', '$', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'H', '^', { noremap = true, silent = true })

-- Press 'U' for redo
vim.api.nvim_set_keymap('n', 'U', '<C-r>', { noremap = true, silent = true })

-- Press 'H', 'L' to jump to start/end of a line (first/last char) in visual mode
vim.api.nvim_set_keymap('v', 'L', '$<left>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'H', '^', { noremap = true, silent = true })

-- Paste without losing the contents of the register
vim.api.nvim_set_keymap('v', '<A-j>', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<A-k>', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

vim.api.nvim_set_keymap('x', '<leader>p', '"_dP', { noremap = true, silent = true })

-- Terminal --
-- Enter normal mode while in a terminal
vim.api.nvim_set_keymap('t', '<esc>', [[<C-\><C-n>]], { noremap = true, silent = true })

-- Window navigation from terminal
local terminal_nav_mappings = {
    ["<C-h>"] = [[<Cmd>wincmd h<CR>]],
    ["<C-j>"] = [[<Cmd>wincmd j<CR>]],
    ["<C-k>"] = [[<Cmd>wincmd k<CR>]],
    ["<C-l>"] = [[<Cmd>wincmd l<CR>]],
}

for key, cmd in pairs(terminal_nav_mappings) do
    vim.api.nvim_set_keymap('t', key, cmd, { noremap = true, silent = true })
end

-- Reenable default <space> functionality to prevent input delay
vim.api.nvim_set_keymap('n', '<space>', '<space>', { noremap = true, silent = true })


--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })


--Telescope
-- Enable Telescope extensions if they are installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

vim.keymap.set('n', '<leader>/', function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
    })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>s/', function()
    builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
    }
end, { desc = '[S]earch [/] in Open Files' })

vim.keymap.set('n', '<leader>sn', function()
    builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })




-- Harpoon keybinds --
-- Open harpoon ui
nnoremap("<leader>ho", function()
    harpoon_ui.toggle_quick_menu()
end)

-- Add current file to harpoon
nnoremap("<leader>ha", function()
    harpoon_mark.add_file()
end)

-- Remove current file from harpoon
nnoremap("<leader>hr", function()
    harpoon_mark.rm_file()
end)

-- Remove all files from harpoon
nnoremap("<leader>hc", function()
    harpoon_mark.clear_all()
end)

-- Quickly jump to harpooned files
nnoremap("<leader>1", function()
    harpoon_ui.nav_file(1)
end)

nnoremap("<leader>2", function()
    harpoon_ui.nav_file(2)
end)

nnoremap("<leader>3", function()
    harpoon_ui.nav_file(3)
end)

nnoremap("<leader>4", function()
    harpoon_ui.nav_file(4)
end)

nnoremap("<leader>5", function()
    harpoon_ui.nav_file(5)
end)






-- LSP Keybinds (exports a function to be used in ../../after/plugin/lsp.lua b/c we need a reference to the current buffer) --
M.map_lsp_keybinds = function(buffer_number)
    nnoremap("<leader>rn", vim.lsp.buf.rename, { desc = "LSP: [R]e[n]ame", buffer = buffer_number })
    nnoremap("<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: [C]ode [A]ction", buffer = buffer_number })

    nnoremap("gd", vim.lsp.buf.definition, { desc = "LSP: [G]oto [D]efinition", buffer = buffer_number })

    -- Telescope LSP keybinds --
    nnoremap(
        "gr",
        require("telescope.builtin").lsp_references,
        { desc = "LSP: [G]oto [R]eferences", buffer = buffer_number }
    )

    nnoremap(
        "gi",
        require("telescope.builtin").lsp_implementations,
        { desc = "LSP: [G]oto [I]mplementation", buffer = buffer_number }
    )

    nnoremap(
        "<leader>bs",
        require("telescope.builtin").lsp_document_symbols,
        { desc = "LSP: [B]uffer [S]ymbols", buffer = buffer_number }
    )

    nnoremap(
        "<leader>ps",
        require("telescope.builtin").lsp_workspace_symbols,
        { desc = "LSP: [P]roject [S]ymbols", buffer = buffer_number }
    )

    -- See `:help K` for why this keymap
    -- nnoremap("K", vim.lsp.buf.hover, { desc = "LSP: Hover Documentation", buffer = buffer_number })
    nnoremap("<leader>k", vim.lsp.buf.signature_help, { desc = "LSP: Signature Documentation", buffer = buffer_number })
    inoremap("<C-k>", vim.lsp.buf.signature_help, { desc = "LSP: Signature Documentation", buffer = buffer_number })

    -- Lesser used LSP functionality
    nnoremap("gD", vim.lsp.buf.declaration, { desc = "LSP: [G]oto [D]eclaration", buffer = buffer_number })
    nnoremap("td", vim.lsp.buf.type_definition, { desc = "LSP: [T]ype [D]efinition", buffer = buffer_number })
end



return M
