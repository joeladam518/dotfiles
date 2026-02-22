# dotfiles

My config files. Everything useful I have found or created.

## Installation

### One-line install (curl)

The install script is self-bootstrapping — if the dotfiles repo isn't already
cloned it will clone it to `~/repos/dotfiles` automatically.

> **Note:** Use `bash <(curl ...)` (process substitution) rather than
> `curl ... | bash` so you can pass arguments to the script.

**Auto-detect environment, install bash config (default):**
```sh
bash <(curl -fsSL https://raw.githubusercontent.com/joeladam518/dotfiles/master/install.sh)
```

**Install zsh config:**
```sh
bash <(curl -fsSL https://raw.githubusercontent.com/joeladam518/dotfiles/master/install.sh) --zsh
```

**Override environment detection:**
```sh
# Force linux + bash
bash <(curl -fsSL https://raw.githubusercontent.com/joeladam518/dotfiles/master/install.sh) -e linux

# Force mac + zsh
bash <(curl -fsSL https://raw.githubusercontent.com/joeladam518/dotfiles/master/install.sh) --zsh -e mac

# Force server + bash
bash <(curl -fsSL https://raw.githubusercontent.com/joeladam518/dotfiles/master/install.sh) -e server
```

**wget equivalent:**
```sh
bash <(wget -qO- https://raw.githubusercontent.com/joeladam518/dotfiles/master/install.sh)
```

### Manual install

```sh
git clone https://github.com/joeladam518/dotfiles.git ~/repos/dotfiles
cd ~/repos/dotfiles
./install.sh [--bash|--zsh] [-e {linux|mac|server}]
```

### Options

| Option | Description |
|--------|-------------|
| `--bash` | Install bash config (default) |
| `--zsh` | Install zsh config |
| `-e`, `--env` `{linux\|mac\|server}` | Override auto-detection |
| `-h`, `--help` | Show usage |

If `--env` is omitted, the script detects the environment automatically
(`uname` + `systemctl get-default`).

## Uninstall

```sh
cd ~/repos/dotfiles
./uninstall.sh [--bash|--zsh] [-e {linux|mac|server}]
```

## Scripts

Once dotfiles are installed these scripts are available in your `$PATH`:

1. `cmsg` — add color to your terminal messages
2. `dkr` — docker helper script
3. `dotfiles` — CLI tool built in Python with helper commands
4. `repo` — aliases for `cd`-ing into repo directories
5. `transMP4grify` — convert to mp4 and strip audio (useful for Jira uploads)
