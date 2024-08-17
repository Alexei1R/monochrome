return {
    {
        "ngtuonghy/live-server-nvim",
        event = "VeryLazy",
        build = ":LiveServerInstall",
        config = function()
            require("live-server-nvim").setup({
                custom = {
                    -- "--port=8080",                                      -- Customize the port or other options
                    -- "--no-css-inject",                                  -- Prevent CSS injection
                },
                serverPath = vim.fn.stdpath("data") .. "/live-server/", -- Set the server path
                open = "folder",                                        -- Set to "folder" or "cwd" (current working directory)
            })
        end,
    },
}
