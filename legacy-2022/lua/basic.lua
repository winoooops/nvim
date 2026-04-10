-- ujtf8
-- vim.g.encoding = "UTF-8"
vim.o.fileencoding = 'utf-8'

-- 打开全彩
vim.g.termguicolor = true

-- tokyonight 主题配置
vim.g.tokyonight_transparent_sidebar = true

-- airline 主题
vim.g.airline_theme = 'murmur'
vim.g.airline_poweline_fonts = 1
-- airline 右下section配置
vim.g.airline_section_z = '%p%%'

-- highlight current row
vim.wo.cursorline = true

-- 禁止创建备份文件
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false

-- 新行对齐当前行，空格替代tab
vim.o.expandtab = true
vim.bo.expandtab = true

vim.bo.autoindent = true
vim.o.smartindent = true

-- tab定义为4个空格
vim.o.softtabstop = 2
vim.o.shiftwidth = 2

-- 搜索大小写不敏感，除非包含大写
vim.o.ignorecase = true
vim.o.smartcase = false

-- 行结尾可以跳到下一行
vim.o.whichwrap = 'b,s,<,>,[,],h,l'

-- 补全增强
vim.o.wildmenu = true

-- 显示左侧图标指示列
-- vim.wo.signcolumn = "yes"
-- 右侧参考线，超过表示代码太长了，考虑换行
-- vim.wo.colorcolumn = '80'

-- 显示行数
vim.o.number = true
vim.wo.number = true

-- 鼠标支持
vim.o.mouse = 'a'

-- 禁止创建备份文件
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false

-- split window 从下边和右边出现
vim.o.splitbelow = true
vim.o.splitright = true

-- 当文件被外部程序修改时，自动加载
vim.o.autoread = true
vim.bo.autoread = true

-- 命令行高为2，提供足够的显示空间
vim.o.cmdheight = 2

-- 自动补全不自动选中
vim.g.completeopt = "menu,menuone,noselect,noinsert"

-- 超时
vim.o.timeoutlen = 500

-- markdown preview 设置
vim.g.glow_binary_path = vim.env.HOME .. "/bin"
vim.g.glow_border = "rounded"
vim.g.glow_width = 200

-- nvim 系统粘贴板权限
vim.o.clipboard = vim.o.clipboard .. 'unnamedplus'

