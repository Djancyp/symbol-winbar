local M = {}
function M.get_current_node()

    -- local ts_utils = require('nvim-treesitter.ts_utils')
    local parsers = require "nvim-treesitter.parsers"
    local ts_utils = require('nvim-treesitter.ts_utils')
    parsers.reset_cache()
    local node = ts_utils.get_node_at_cursor()
    local buf = vim.api.nvim_win_get_buf(0)
    local buffer_lang = parsers.get_buf_lang(buf)
    local root_lang_tree = parsers.get_parser(buf, buffer_lang)
    if not root_lang_tree then
        return
    end
    local name = M.find_name(node)
    -- vim.winbar_set_title(name)
    -- remove single & double quotes form name
    name = name:gsub("'", "")
    name = name:gsub('"', "")
    -- vim convert to string
    name = tostring(name)
    -- name = vim.fn('"%s"', name)
    M.P(name)
    -- vim.cmd("setlocal winbar=" .. "\\ " .. name)
end

function M.find_name(node)
    local ts_utils = require('nvim-treesitter.ts_utils')
    local type_patterns = { "class", "function", "method", "if", "for", "array-name", "arrow_funtion", "object-name" }
    local transform_line = function(line)
        return line:gsub("%s*[%[%(%{]*%s*$", "")
    end
    local bufnr = 0
    local indicator_size = 100
    local transform_fn = transform_line
    local separator = " -> "


    local lines = {}
    local expr = node

    while expr do
        local line = ts_utils._get_line_for_node(expr, type_patterns, transform_fn, bufnr)
        if line ~= "" and not vim.tbl_contains(lines, line) then
            table.insert(lines, 1, line)
        end
        expr = expr:parent()
    end

    local text = table.concat(lines, separator)
    local text_len = #text
    if text_len > indicator_size then
        return "..." .. text:sub(text_len - indicator_size, text_len)
    end

    return text
end

function M.get_root_for_node(node)
    local parent = node
    local result = node

    while parent ~= nil do
        result = parent
        parent = result:parent()
    end

    return result
end


return M
