return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha", -- You can choose between "latte", "frappe", "macchiato", "mocha"
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	--   {
	--   'folke/tokyonight.nvim',
	--   priority = 1000,
	--   init = function()
	--     vim.cmd.colorscheme 'tokyonight-night'
	--
	--     vim.cmd.hi 'Comment gui=none'
	--   end,
	-- },
}
