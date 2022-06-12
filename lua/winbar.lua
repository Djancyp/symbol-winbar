local W = {}
local status_web_devicons_ok, web_devicons = pcall(require, 'nvim-web-devicons')
local api = vim.api
local lsp = require('providers/lsp')
local gps = require('providers/gps')

local colors = {
    bg = '#ebdbb2',
    fg = '#abb2bf',
    yellow = '#fabd2f',
    cyan = '#56b6c2',
    darkblue = '#ebdbb2',
    green = '#8ec07c',
    orange = '#d19a66',
    violet = '#a9a1e1',
    magenta = '#c678dd',
    blue = '#83a598',
    red = '#e86671'
}

local function setLsp()
    local text = ''
    local errors = lsp.diagnostic_errors()
    local warnings = lsp.diagnostic_warnings()
    local info = lsp.diagnostic_info()
    local hints = lsp.diagnostic_hints()
    local e_fg = 'errorColor'
    local w_fg = 'warningColor'
    local i_fg = 'infoColor'
    local h_fg = 'hintColor'
    vim.api.nvim_set_hl(0, e_fg, { fg = colors.red })
    vim.api.nvim_set_hl(0, w_fg, { fg = colors.yellow })
    vim.api.nvim_set_hl(0, i_fg, { fg = colors.cyan })
    vim.api.nvim_set_hl(0, h_fg, { fg = colors.green })

    if errors ~= '' then
        errors = '%#' .. e_fg .. '#' .. ' ' .. '%*'
    end
    if warnings ~= '' then
        warnings = '%#' .. w_fg .. '#' .. ' ' .. '%*'
    end
    if info ~= '' then
        info = '%#' .. i_fg .. '#' .. ' ' .. '%*'
    end
    if hints ~= '' then
        hints = '%#' .. h_fg .. '#' .. ' ' .. '%*'
    end

    -- set hl for errors
    text = '%=' .. errors .. warnings .. info .. hints .. ' '
    return text

end

local function get_gps()
    local current_buffer = api.nvim_get_current_buf()
    local c = vim.lsp.buf_get_clients(current_buffer)
    for _, client in pairs(c) do
        if client.server_capabilities.documentSymbolProvider then
            -- print(client.name)
            gps.attach(client, current_buffer)
        end

    end
end

function W.init(opts)
    local file_path           = vim.fn.expand('%:~:.:h')
    local filename            = vim.fn.expand('%:t')
    local file_type           = vim.fn.expand('%:e')
    local hl_winbar_file_icon = 'WinBarFileIcon'
    local changed_icon_color  = "FileIconColor"
    api.nvim_set_hl(0, changed_icon_color, { fg = '#66EB73' })
    get_gps()

    local value = ''
    if vim.tbl_contains(opts.exclude_filetypes, file_type) then
        return
    end
    if file_type == '' then
        W.show('')
        return
    end
    file_path = file_path:gsub('^%.', '')
    file_path = file_path:gsub('^%/', '')
    if status_web_devicons_ok then
        file_icon, file_icon_color = web_devicons.get_icon_color(filename, file_type, { default = default })
    end
    vim.api.nvim_set_hl(0, hl_winbar_file_icon, { fg = file_icon_color })
    file_icon = '%#' .. hl_winbar_file_icon .. '#' .. file_icon .. ' %*'
    --split file path to lines
    local file_paths = vim.split(file_path, '/')
    if opts.full_path then
        for i, v in ipairs(file_paths) do
            value = v .. opts.separator_icon .. value
        end
        value = value .. ' ' .. filename .. ' ' .. file_icon
    else
        value = ' ' .. file_icon .. filename
    end
    if opts.gps then
        value = value .. '%=' .. gps.get_location()
    end
    if opts.lsp then
        value = value .. ' ' .. setLsp()
    end
    local buf = vim.api.nvim_get_current_buf()
    local change_icon = '%#' .. changed_icon_color .. '#' .. opts.changes_icon .. ' '
    if vim.api.nvim_buf_get_option(buf, 'modified') then
        value = value .. '  ' .. change_icon
    end
    W.show(value)
end

function W.show(value)
    local status_ok, _ = pcall(vim.api.nvim_set_option_value, 'winbar', value, { scope = 'local' })
    if not status_ok then
        return
    end
end

return W
