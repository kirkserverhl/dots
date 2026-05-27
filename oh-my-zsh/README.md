# oh-my-zsh

This package deploys your entire `~/.oh-my-zsh` directory via GNU Stow.

## Why this structure?

The package is laid out as:

```
oh-my-zsh/
└── oh-my-zsh/          ← the actual contents of ~/.oh-my-zsh
    ├── custom/
    ├── plugins/
    ├── themes/
    └── ...
```

When you run `stow oh-my-zsh`, it creates:

```
~/.oh-my-zsh → ~/.dots/oh-my-zsh/oh-my-zsh
```

This allows you to keep your custom plugins, themes, and modifications under version control.

## Populating the package

From your current setup (recommended):

```bash
rsync -a --delete ~/.oh-my-zsh/ ~/.dots/oh-my-zsh/oh-my-zsh/
```

Or from the old backup:

```bash
rsync -a --delete /home/kirk/.hyprgruv/home/.oh-my-zsh/ ~/.dots/oh-my-zsh/oh-my-zsh/
```

## Deployment

```bash
cd ~/.dots
./migrate.sh oh-my-zsh
```

Or if using dotctl:

```bash
dotctl install oh-my-zsh
```

## Notes

- `.oh-my-zsh` contains its own `.git` directory. You may want to exclude it from your main dots repo (add it to `.gitignore` inside this package if desired).
- Custom plugins and themes should live in `custom/`.
- After deploying on a new machine, you may need to run `omz update` or reinstall certain plugins.
