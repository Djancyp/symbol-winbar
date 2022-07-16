local M = {}
local winbar = require('winbar')
local api = vim.api
local opts = {
    full_path = false,
    file_icons = true,
    lsp = true,
    gps = true,
    separator_icon = '  ',
    changes_icon = '',
    icons = {
        ["class"] = "",
        ["function"] = "",
        ["method"] = "",
        ["if"] = "",
        ["for"] = "",
        ["array-name"] = "",
        ["arrow_funtion"] = "",
        ["object-name"] = "",
    },
    exclude_filetypes = {
        'help',
        'startify',
        'dashboard',
        'packer',
        'neogitstatus',
        'NvimTree',
        'Trouble',
        'alpha',
        'lir',
        'Outline',
        'spectre_panel',
        'toggleterm',
        'telescope',
        'neo-tree',
        'qf',
    }
}
local cmd = vim.api.nvim_create_autocmd
function M.setup(config)
    opts = vim.tbl_deep_extend("force", opts, config or {})


    cmd({ 'DirChanged', 'CursorMoved', 'CursorMovedI', 'BufWinEnter', 'BufFilePost', 'InsertEnter', 'BufWritePost' }, {
        callback = function()
            local current_buffer = api.nvim_get_current_buf()
            local current_buffer_name = api.nvim_buf_get_name(current_buffer)
            if current_buffer_name == '' then
                return
            end
            winbar.init(opts)
        end
    })
end

return M
