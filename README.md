# NixOS Configuration

## Обзор (RU)

Это репозиторий с конфигурацией NixOS и Home Manager на Nix Flakes.
Структура построена вокруг трёх принципов:

1. **Разделение «машины» и «общего».** Всё, что зависит от конкретного
   железа (монитор, тачпад, батарея, bluetooth, имя хоста), живёт только в
   `hosts/<host>/`. Всё остальное — общие модули, одинаковые на любой машине.
2. **Интуитивность.** Каждый модуль отвечает ровно за одну вещь: конфиг
   neovim — только в `editors/neovim/`, oh-my-posh отдельно от zsh, kitty
   отдельно от hyprland. Пакеты лежат рядом с конфигом, который их использует.
3. **Тема отдельно от функциональности.** Все цвета, шрифты и имена тем
   собраны в одном месте — `themes/sunset-pines.nix`. Модули не содержат
   хардкоженных цветов, а читают их из аргумента `theme`.

## Overview (EN)

This repository holds NixOS and Home Manager configuration managed with
Nix Flakes. The layout is built around three principles:

1. **Machine vs. shared separation.** Everything that depends on a specific
   machine (monitor, touchpad, battery, bluetooth, hostname) lives only in
   `hosts/<host>/`. Everything else is a shared module, identical on any host.
2. **Intuitiveness.** Each module owns exactly one concern: neovim config
   only in `editors/neovim/`, oh-my-posh separate from zsh, kitty separate
   from hyprland. Packages sit next to the config that uses them.
3. **Theming decoupled from functionality.** All colors, fonts and theme
   names live in one place — `themes/sunset-pines.nix`. Modules contain no
   hardcoded colors; they read them from the `theme` argument.

## Стек / Tech stack

| Инструмент (RU)  | Tool (EN)         | Назначение (RU)          | Purpose (EN)          |
|------------------|-------------------|--------------------------|-----------------------|
| NixOS            | NixOS             | система (unstable)       | the OS (unstable)     |
| Nix Flakes       | Nix Flakes        | менеджмент конфигурации  | configuration management |
| Home Manager     | Home Manager      | пользовательское окружение | user environment    |
| nixfmt-rfc-style | nixfmt-rfc-style  | форматирование Nix       | Nix formatting        |

## Структура репозитория / Repository structure

```
NixOS/
├── flake.nix                        # входная точка: host + home-manager + тема
├── flake.lock
│
├── themes/                          # темы: единый источник правды для цветов
│   ├── default.nix                  #   выбор активной темы
│   └── sunset-pines.nix             #   палитра (цвета/шрифты/курсор/gtk/qt/обои)
│
├── hosts/                           # машины
│   └── honor-magicbook-x16-plus/
│       ├── default.nix              #   входная точка хоста
│       ├── device.nix               #   системные особенности железа
│       ├── home.nix                 #   home-особенности железа
│       └── hardware-configuration.nix  # сгенерирован, НЕ редактировать
│
├── home/
│   └── artemmkk-sh.nix              # входная точка пользователя (импортирует общие home-модули)
│
└── modules/
    ├── system/                      # общие системные модули (каждый хост импортирует)
    │   ├── base.nix                 #   nix/flakes, локаль, часовой пояс, пользователь
    │   ├── networking.nix           #   networkmanager, firewall, avahi
    │   ├── audio.nix                #   pipewire
    │   ├── printing.nix             #   CUPS + драйверы
    │   ├── fonts.nix                #   системные шрифты
    │   ├── theming.nix              #   системные пакеты тем (GTK/Qt)
    │   ├── desktop.nix              #   Hyprland-система, thunar, polkit, GUI-программы
    │   └── greeter.nix              #   greetd + ReGreet (экран входа)
    │
    └── home/                        # общие home-manager модули (один модуль — одна забота)
        ├── shell/
        │   ├── zsh.nix              #   zsh: история, плагины, алиасы, бинды
        │   └── oh-my-posh.nix       #   промпт (отдельно от zsh)
        ├── terminal/
        │   ├── kitty.nix            #   терминал
        │   ├── tmux.nix             #   tmux (клавиши/плагины/статус-бар)
        │   └── sessionizer.nix      #   tmux-sessionizer + fzf
        ├── editors/
        │   ├── git.nix              #   git
        │   └── neovim/              #   neovim + LSP/инструменты
        ├── hyprland/
        │   ├── hyprland.nix         #   сам WM (бинды/раскладка/порталы)
        │   ├── waybar.nix           #   панель
        │   ├── wofi.nix             #   лаунчер
        │   ├── mako.nix             #   уведомления
        │   ├── hyprlock.nix         #   экран блокировки
        │   ├── hypridle.nix         #   idle-менеджер
        │   └── hyprpaper.nix        #   обои
        ├── apps/
        │   ├── chat.nix             #   telegram, discord
        │   ├── browsers.nix         #   zen-browser
        │   ├── office.nix           #   libreoffice, obsidian, okular
        │   ├── media.nix            #   vlc, wiremix
        │   ├── network.nix          #   zapret, bluetooth, файлообмен
        │   └── dev.nix              #   zed, ripgrep, lazygit, opencode, direnv
        ├── fastfetch/               #   fastfetch (конфиг + скрипты + логотипы)
        └── theming.nix              #   применение темы: gtk/qt/курсор/dconf/xsettingsd
```

## Описание частей / Description of the parts

### `flake.nix` — входная точка / entry point

Собирает `nixosConfigurations."<host>"`:

- **`specialArgs`** (системные модули) и **`extraSpecialArgs`** (home-manager
  модули) передают `theme` и `inputs` каждому модулю.
- Пользовательская конфигурация собирается из двух кусков:
  `home/artemmkk-sh.nix` (общее) + `hosts/<host>/home.nix` (особенности
  конкретной машины).
- Активная тема подключается через `import ./themes/default.nix`.

The flake builds `nixosConfigurations."<host>"`:

- **`specialArgs`** (system modules) and **`extraSpecialArgs`** (home-manager
  modules) pass `theme` and `inputs` to every module.
- The user configuration is composed of two parts:
  `home/artemmkk-sh.nix` (shared) + `hosts/<host>/home.nix` (machine
  specifics).
- The active theme is wired in via `import ./themes/default.nix`.

### `themes/` — темы / themes

Единый источник правды для визуальной части. `default.nix` выбирает
активную тему, `sunset-pines.nix` описывает палитру:

- `colors` — семантические цвета (фон, текст, акцент, ошибка...);
- `terminal` — 16-цветная палитра терминала (kitty);
- `prompt` — цвета сегментов oh-my-posh;
- `fonts`, `cursor`, `gtk`, `qt` — имена и размеры;
- `wallpapers.desktop` — обои (путь относительно репозитория, без
  абсолютных путей).

**Соглашение о цветах:** hex хранится БЕЗ ведущего `#` (например
`"16141f"`). Потребители сами добавляют `#`, где формат требует (CSS,
kitty, oh-my-posh), либо используют «сырой» hex внутри `rgba()`/`rgb()`
для Hyprland/hyprlock:

```nix
"#${theme.colors.bg}"              # CSS / kitty
"rgba(${theme.colors.accent}ee)"   # Hyprland / hyprlock
```

Single source of truth for the visual layer. `default.nix` selects the
active theme, `sunset-pines.nix` defines the palette:

- `colors` — semantic colors (background, text, accent, error...);
- `terminal` — 16-color terminal palette (kitty);
- `prompt` — oh-my-posh segment colors;
- `fonts`, `cursor`, `gtk`, `qt` — names and sizes;
- `wallpapers.desktop` — wallpaper (repo-relative path, no absolute paths).

**Color convention:** hex is stored WITHOUT a leading `#` (e.g.
`"16141f"`). Consumers add `#` where the format requires it (CSS, kitty,
oh-my-posh), or use raw hex inside `rgba()`/`rgb()` for Hyprland/hyprlock:

```nix
"#${theme.colors.bg}"              # CSS / kitty
"rgba(${theme.colors.accent}ee)"   # Hyprland / hyprlock
```

### `hosts/<host>/` — машины / machines

Каталог на каждое физическое устройство. Это **единственное место**, где
лежат значения, зависящие от железа:

| Файл (RU)               | File (EN)               | Что внутри (RU)              | What's inside (EN)                    |
|-------------------------|-------------------------|------------------------------|---------------------------------------|
| `default.nix`           | `default.nix`           | импортирует hardware + device + общие system-модули | imports hardware + device + shared system modules |
| `device.nix`            | `device.nix`            | hostname, bootloader, tlp (батарея), bluetooth, GPU | hostname, bootloader, tlp (battery), bluetooth, GPU |
| `home.nix`              | `home.nix`              | монитор, тачпад, keyboard-name, периферия (logiops) | monitor, touchpad, keyboard-name, peripherals (logiops) |
| `hardware-configuration.nix` | `hardware-configuration.nix` | сгенерирован `nixos-generate-config`; **не редактировать** | generated by `nixos-generate-config`; **do not edit** |

Правило: специфичное для машины никогда не попадает в общие модули —
иначе непонятно, что менять для нового устройства.

A directory per physical device. This is the **only place** where
hardware-dependent values live:

| File (EN)               | What's inside (EN)                    | Что внутри (RU)              |
|-------------------------|---------------------------------------|------------------------------|
| `default.nix`           | imports hardware + device + shared system modules | импортирует hardware + device + общие system-модули |
| `device.nix`            | hostname, bootloader, tlp (battery), bluetooth, GPU | hostname, bootloader, tlp (батарея), bluetooth, GPU |
| `home.nix`              | monitor, touchpad, keyboard-name, peripherals (logiops) | монитор, тачпад, keyboard-name, периферия (logiops) |
| `hardware-configuration.nix` | generated by `nixos-generate-config`; **do not edit** | сгенерирован `nixos-generate-config`; **не редактировать** |

Rule: machine-specific values never go into shared modules — otherwise you
can't tell what needs to change for a new device.

### `modules/system/` — общие системные модули / shared system modules

Импортируются каждым хостом и не зависят от железа:

- **`base.nix`** — nix/flake настройки, `allowUnfree`, локаль, часовой
  пояс, пользователь `artemmkk-sh` (группы, shell), базовые CLI-пакеты
  (vim, wget, git, gparted).
- **`networking.nix`** — networkmanager, firewall, avahi.
- **`audio.nix`** — pipewire, rtkit.
- **`printing.nix`** — CUPS + драйверы (gutenprint, brlaser, hplip).
- **`fonts.nix`** — системные шрифты (noto, nerd-fonts...).
- **`theming.nix`** — системные пакеты тем (gnome-themes-extra,
  adwaita-*, qtwayland).
- **`desktop.nix`** — системная часть десктопа: Hyprland, XWayland/клавиатура,
  thunar/gvfs, polkit, firefox, throne.
- **`greeter.nix`** — greetd + ReGreet; цвета берёт из `theme`.

Imported by every host and independent of hardware:

- **`base.nix`** — nix/flake settings, `allowUnfree`, locale, timezone,
  user `artemmkk-sh` (groups, shell), essential CLI packages (vim, wget,
  git, gparted).
- **`networking.nix`** — networkmanager, firewall, avahi.
- **`audio.nix`** — pipewire, rtkit.
- **`printing.nix`** — CUPS + drivers (gutenprint, brlaser, hplip).
- **`fonts.nix`** — system fonts (noto, nerd-fonts...).
- **`theming.nix`** — system theme packages (gnome-themes-extra,
  adwaita-*, qtwayland).
- **`desktop.nix`** — desktop system parts: Hyprland, XWayland/keymap,
  thunar/gvfs, polkit, firefox, throne.
- **`greeter.nix`** — greetd + ReGreet; colors read from `theme`.

### `modules/home/` — общие home-модули / shared home modules

Главное правило: **один модуль — одна забота.** Пакеты и конфиг одной
программы лежат вместе:

- `shell/` — `zsh.nix` (сам шелл) и `oh-my-posh.nix` (промпт) разделены:
  промпт можно использовать с любым шеллом.
- `terminal/` — kitty, tmux (клавиши/плагины/статус-бар), sessionizer.
- `editors/` — git; `neovim/` — neovim со своими LSP/инструментами
  (внутри — `nvim/` с Lua-конфигом).
- `hyprland/` — каждый компонент десктопа отдельным файлом: сам WM,
  waybar, wofi, mako, hyprlock, hypridle, hyprpaper.
- `apps/` — пакеты приложений, сгруппированные по назначению (чат,
  браузеры, офис, медиа, сеть, разработка).
- `fastfetch/` — конфиг + скрипты + логотипы.
- `theming.nix` — применение активной темы на уровне пользователя:
  GTK, Qt/KDE, курсор, dconf, xsettingsd.

Main rule: **one module = one concern.** A program's packages and config
live together:

- `shell/` — `zsh.nix` (the shell) and `oh-my-posh.nix` (the prompt) are
  separated: the prompt can be used with any shell.
- `terminal/` — kitty, tmux (keys/plugins/status bar), sessionizer.
- `editors/` — git; `neovim/` — neovim with its LSP/tooling (inside —
  `nvim/` with the Lua config).
- `hyprland/` — each desktop component is its own file: the WM itself,
  waybar, wofi, mako, hyprlock, hypridle, hyprpaper.
- `apps/` — application packages grouped by purpose (chat, browsers,
  office, media, network, dev).
- `fastfetch/` — config + scripts + logos.
- `theming.nix` — applies the active theme at the user level: GTK,
  Qt/KDE, cursor, dconf, xsettingsd.

### `home/artemmkk-sh.nix` — пользователь / the user

Входная точка Home Manager: импортирует все общие home-модули и хранит
только идентичность (username, homeDirectory, `stateVersion`) и общие
session-переменные. Специфичное для машины добавляется флейком из
`hosts/<host>/home.nix`.

Home Manager entry point: imports all shared home modules and keeps only
identity (username, homeDirectory, `stateVersion`) and shared session
variables. Machine specifics are injected by the flake from
`hosts/<host>/home.nix`.

## Добавление новой машины / Adding a new machine

1. Сгенерируйте `hardware-configuration.nix` (`nixos-generate-config`).
2. Скопируйте каталог `hosts/<host>/` и заполните `device.nix` + `home.nix`
   под новое железо (монитор, тачпад, имя хоста, GPU-драйверы...).
3. Добавьте блок `nixosConfigurations."<new-host>"` в `flake.nix` по
   образцу существующего.

1. Generate `hardware-configuration.nix` (`nixos-generate-config`).
2. Copy the `hosts/<host>/` directory and fill `device.nix` + `home.nix`
   for the new hardware (monitor, touchpad, hostname, GPU drivers...).
3. Add a `nixosConfigurations."<new-host>"` block in `flake.nix` following
   the existing one.

## Правила темизации / Theming rules

- Тема передаётся каждому модулю как аргумент `theme`
  (`themes/default.nix`).
- Цвета хранятся без `#`; формат добавляют потребители (см. выше).
- Не хардкодьте цвета в функциональности — читайте их из `theme`.
- Поменять тему всей машины = отредактировать `themes/sunset-pines.nix`
  или заменить импорт в `themes/default.nix`.

- The theme is passed to every module as the `theme` argument
  (`themes/default.nix`).
- Colors are stored without `#`; consumers add the format (see above).
- Do not hardcode colors in functionality — read them from `theme`.
- To re-theme the whole machine, edit `themes/sunset-pines.nix` or swap
  the import in `themes/default.nix`.

## Команды / Commands

```bash
# Форматирование / formatting
nixfmt NixOS/*.nix NixOS/**/*.nix

# Проверка синтаксиса / syntax check
nix-instantiate --parse <file> > /dev/null

# Тестовая сборка / dry-run build
nixos-rebuild build --flake .#<hostname>

# Применение / apply
sudo nixos-rebuild switch --flake .#<hostname>

# Обновление входов / update inputs
nix flake update
```
