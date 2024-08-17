return {
	{
		dir = "~/Code/personal/ts-error-translator.nvim",
		enabled = false,
		-- branch = "pr18",
		config = function()
			require("ts-error-translator").setup()
		end,
	},
	{
		"dmmulroy/tsc.nvim",
		lazy = true,
		ft = { "typescript", "typescriptreact" },
		config = function()
			require("tsc").setup({
				auto_open_qflist = true,
				pretty_errors = false,
			})
		end,
	},
}
