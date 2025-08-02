# tmuxioner (Tmux Session Manager)

A fuzzy <ins>tmux</ins> sess<ins>ion</ins> manag<ins>er</ins> with preview capabilities, creating, renaming and deleting.

## Prerequisites

- [tpm](https://github.com/tmux-plugins/tpm)
- [fzf](https://github.com/junegunn/fzf)

## Install

Add this to your `.tmux.conf` and run `<prefix> + I` for TPM to install the plugin.

```
set -g @plugin 'adkevin3307/tmuxioner'
```

## Configure

The default binding for this plugin is `<prefix> + T`. You can change it by adding this line with your desired key.

```
set -g @tmuxioner-key '<key>'
```

## Thanks

Inspired by these plugins.

- [tmux-sessionx](https://github.com/omerxx/tmux-sessionx)
- [sesh](https://github.com/joshmedeski/sesh)

