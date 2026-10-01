return {
	{
		"vimtex",
		dir = plugin_path("vimtex"),
		name = "vimtex",
		ft = { "tex", "plaintex", "bib" },
		init = function()
			-- vimtex настраивается через глобальные переменные, которые нужно
			-- выставить ДО загрузки плагина — поэтому используем init(), а не config().

			-- Компилятор: latexmk из texlive (пакет: texlive.combined.scheme-full)
			vim.g.vimtex_compiler_method = "latexmk"
			vim.g.vimtex_compiler_latexmk = {
				build_dir = "build",
				options = {
					"-verbose",
					"-file-line-error",
					"-synctex=1",
					"-interaction=nonstopmode",
				},
			}

			-- Просмотрщик PDF с поддержкой SyncTeX (пакет: zathura)
			vim.g.vimtex_view_method = "zathura"

			-- texlab уже даёт диагностики/автодополнение — отключаем
			-- встроенный quickfix-парсер vimtex, чтоб не дублировать ошибки.
			vim.g.vimtex_quickfix_mode = 0

			-- Подсветка синтаксиса отдаём nvim-treesitter (парсер latex/bibtex),
			-- vimtex используется только для компиляции/навигации/сниппетов.
			vim.g.vimtex_syntax_enabled = 0

			vim.g.vimtex_fold_enabled = false
		end,
		keys = {
			{ "<leader>ll", "<cmd>VimtexCompile<cr>", desc = "LaTeX: compile (watch)", ft = "tex" },
			{ "<leader>lv", "<cmd>VimtexView<cr>", desc = "LaTeX: view PDF", ft = "tex" },
			{ "<leader>lt", "<cmd>VimtexTocToggle<cr>", desc = "LaTeX: toggle TOC", ft = "tex" },
			{ "<leader>lc", "<cmd>VimtexClean<cr>", desc = "LaTeX: clean aux files", ft = "tex" },
			{ "<leader>le", "<cmd>VimtexErrors<cr>", desc = "LaTeX: show errors", ft = "tex" },
			{ "<leader>ls", "<cmd>VimtexStop<cr>", desc = "LaTeX: stop compilation", ft = "tex" },
		},
	},
}
