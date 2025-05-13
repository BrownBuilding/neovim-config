local m = {}

-- Reuse a terminal buffer or create one if there is none to reuse.
function m.reuse_terminal()
    -- Find buffer that with name starting with 'term://'
    local reuseable_terminal_buffer = vim.iter(vim.api.nvim_list_bufs())
        :filter(vim.api.nvim_buf_is_loaded)
        :find(function(buffer)
            local buffername = vim.api.nvim_buf_get_name(buffer)
            return vim.startswith(buffername, 'term://')
        end)
    -- open new terminal if there is no old terminal
    if reuseable_terminal_buffer then
        vim.api.nvim_win_set_buf(0, reuseable_terminal_buffer)
    else
        vim.cmd.term()
    end
end

return m
