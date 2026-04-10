-- 将<leader>设置为空格键
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 保存本地变量，用来设置快捷键
local map = vim.api.nvim_set_keymap
local opt = { noremap = true, silent = true }
-- 之后就可以这样映射按键了
-- map('模式','按键','映射为XX',opt)

-- 水平分屏 <leader> => space
map("n", "<leader>sw", ":vsp<CR>", opt)
-- 上下分屏
map("n", "<leader>sW", ":sp<CR>", opt)
-- 关闭当前分屏
map("n", "<leader>cw", "<C-w>c", opt)
-- 关闭全部分屏
map("n", "<leader>cW", "<C-w>o", opt)

-- 切换标签
map("n", "<C-h>", "<C-w>h", opt)
map("n", "<C-j>", "<C-w>j", opt)
map("n", "<C-k>", "<C-w>k", opt)
map("n", "<C-l>", "<C-w>l", opt)

-- 左侧打开文件目录
-- map("n", "<leader>e", ":Lex 20<CR>", opt)
map("n", "<leader>e", ":NvimTreeToggle<cr>", opt)
-- 在当前窗口打开文件目录
map("n", "<leader>E", ":Explore<CR>", opt)

-- 调整tab大小
map("n", "<leader>lS", ":resize +2<CR>", opt)
map("n", "<learder>nS", ":resize -2<CR>", opt)
map("n", "<leader>ls", ":vertical resize +2<CR>", opt)
map("n", "<leader>ns", ":vertical resize -2<CR>", opt)

-- 在buffer中前进/后退<S> => Shift
map("n", "<S-k>", ":bnext<CR>", opt)
map("n", "<S-j>", ":bprevious<CR>", opt)
-- 删除当前buffer
map("n", "<leader>w", ":Bdelete <CR>", opt)
-- 删除全部buffer
map("n", "<leader>W", ":bufdo <bar> :Bdelete <CR>", opt)

-- 切换tab
-- 切换下一个tab
map("n", "<leader><leader>k", ":tabn<CR>", opt)
-- 切换上一个tab
map("n", "<leader><leader>j", ":tabp<CR>", opt)
-- 新建并进入一个新的tab (empty buffer)
map("n", "<leader><leader>n", ":tabnew<CR>", opt)
-- 新建并进入一个新的tab (打开制定文件) :tabedit <filePath>
-- 关闭当前tab
map("n", "<leader><leader>w", ":tabc<CR>", opt)
-- 查看tab打开的文件 :tabs

-- 在Visual模式下改变锁进不会退出
map("v", "<", "<gv", opt)
map("v", ">", ">gv", opt)

-- wiondow下, 在Visual模式下上下移动所选文字, <A> => Alt
-- map("v", "<A-k>", ":m .+1<CR>==", opt)
-- map("v", "<A-j>", ":m .-1<CR>==", opt)
-- map("v", "p", "_dP", opt)

-- visual模式下, 移动代码块
map("x", "J", ":m '>+1<CR>gv-gv", opt)
map("x", "K", ":m '<-2<CR>gv-gv", opt)

-- insert 模式下, 移动cursor
map("i", "<C-h>", "<C-O>h", opt)
map("i", "<C-l>", "<C-O>l", opt)
map('i', "<C-j>", "<C-O>j", opt)
map('i', "<C-k>", "<C-O>k", opt)
map("i", "<C-w>", "<C-O>w", opt)
map("i", "<C-e>", "<C-O>e", opt)
map("i", "<C-b>", "<C-O>b", opt)
map('i', "<C-a>", "<C-O>A", opt)
map('i', "<C-i>", "<C-O>I", opt)

-- 保存
-- TODO: find a way to let nvim format before save
map("n", "<leader>s", "<cmd>lua vim.lsp.buf.formatting_sync()<CR>:w<CR>", opt)

-- Telescope: fuzzyfind时不限时preview
map("n", "<leader>f", "<cmd>lua require'telescope.builtin'.find_files(require('telescope.themes').get_ivy())<CR>", opt)
-- Telescope: livegrep
map("n", "<leader>fp", "<cmd>Telescope projects<CR>", opt)
-- Telescope: frecency search 
map("n", "<leader>fs", "<cmd>lua require('telescope').extensions.frecency.frecency()<CR>", opt)

-- lazygit 
map("n", "<leader>g", "<cmd>lua _LAZYGIT_TOGGLE()<cr>", opt)

-- toggleterm using <C-t>

