-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny


-- Install catppuccin color scheme
lvim.plugins = {
  { "catppuccin/nvim" }
}

-- Set vim settings
vim.opt.number = true
vim.opt.relativenumber = true


-- Set lvim settings
lvim.colorscheme = "catppuccin-frappe"
lvim.builtin.lualine.style = "default"
lvim.format_on_save.enabled = true

-- Set lvim keyboard mappings
lvim.keys.normal_mode["<C-d>"] = "<C-d>zz" -- center screen on page down
lvim.keys.normal_mode["<C-d>"] = "<C-d>zz" -- center screen on page down
lvim.keys.normal_mode["<C-f>"] = "<C-f>zz" -- center screen on page up half screen
lvim.keys.normal_mode["<C-b>"] = "<C-b>zz" -- center screen on page up half screen
