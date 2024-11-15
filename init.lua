local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)
vim.opt.tabstop = 4
vim.opt.shiftwidth=4
vim.diagnostic.config({
	signs=false
})

--@type LazySpec
local plugins = 'plugins'

-- Configure plugins.
require('lazy').setup(plugins)
require('hologram').setup{
    auto_display = true -- WIP automatic markdown image display, may be prone to breaking
}
