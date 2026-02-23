# dotfiles Python CLI

A Python 3 CLI module invoked via `bin/dotfiles`.

## Commands

| Command | Args | Description |
|---|---|---|
| `dotfiles osinfo` | `-c` `-i` `-l` `-p` `-s` `-v` | Print OS information |
| `dotfiles repos [key]` | `--repos-path` `--file-path` `--list-keys` `--list-paths` `--sep` | Manage repo directory aliases |
| `dotfiles install php [version]` | `-e/--env {desktop,server}` `--composer [DIR]` | Install PHP (and optionally composer) |
| `dotfiles uninstall php [version]` | `--composer` | Uninstall PHP (and optionally composer) |

### `--composer` on install

- `--composer` alone → install composer to `/usr/local/bin`
- `--composer=/some/dir` → install composer to that directory
- Omitted → detect existing installations; prompt if none found

### `--composer` on uninstall

Boolean flag — removes `/usr/local/bin/composer` if present.

## Architecture

Dispatch uses argparse's `set_defaults(handler=fn)` idiom. Each subcommand is a plain function:

```python
def cmd_example(args: Namespace) -> None: ...
example_parser.set_defaults(handler=cmd_example)
```

Entry point: `main.py:cli()` → `args.handler(args)`

## Module layout

| File | Purpose |
|---|---|
| `main.py` | Parser tree + `cli()` entry point + `cmd_osinfo()` |
| `php.py` | `cmd_install_php()`, `cmd_uninstall_php()`, composer helpers |
| `repos.py` | `cmd_repos()`, `_get_repo_aliases()` |
| `osinfo.py` | OS detection helpers (`id()`, `codename()`, `ostype()`, …) |
| `utils.py` | `installed()`, `unique()`, `wrap()`, `exclude()` |
| `console.py` | Colorized output, `confirm()`, `choice()` |
| `run.py` | `command()` / `script()` subprocess helpers |
| `paths.py` | `home_path()`, `get_os_root_directory()` |
| `errors.py` | `ValidationError`, `EmptyAnswerError`, `InvalidAnswerError` |

## Adding a new command

1. Write a handler function anywhere (or in a new module):
   ```python
   def cmd_foo(args: Namespace) -> None:
       ...
   ```
2. Add a parser in `main.py:_build_parser()`:
   ```python
   foo_parser = subparsers.add_parser('foo', help='...')
   foo_parser.add_argument(...)
   foo_parser.set_defaults(handler=cmd_foo)
   ```
3. Import the handler at the top of `main.py`.

That's it — no base classes, no registration dictionaries.
