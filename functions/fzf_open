fzf_open() {
  local selected

  # Build a list of files and directories (skip .git). Adjust -maxdepth or other find args as you like.
  # We print paths relative to current directory.
  # selected=$(
  #   find . -path './.git' -prune -o -print 2> /dev/null \
  #     | sed 's#^\./##' \
  #     | fzf --height=40% --layout=reverse --border \
  #           --preview '[[ -d {} ]] && ls -la --color=always {} || (bat --style=numbers --color=always {} 2>/dev/null || sed -n "1,200p" {})' \
  #           --preview-window='right:50%' \
  #           --pointer='➜' \
  #           --prompt='Open> ' \
  #           --ansi
  # ) || return 0
  selected=$(
    fd --hidden --exclude '.git' . 2> /dev/null \
      | sed 's#^\./##' \
      | fzf --height=40% --layout=reverse --border \
            --preview '[[ -d {} ]] && ls -la --color=always {} || (bat --style=numbers --color=always {} 2>/dev/null || sed -n "1,200p" {})' \
            --preview-window='right:50%' \
            --pointer='➜' \
            --prompt='Open> ' \
            --ansi
  ) || return 0

  # If nothing selected, do nothing
  [[ -z $selected ]] && return 0

  # If it's a directory, cd into it (preserves in current shell)
  if [[ -d $selected ]]; then
    cd -- "$selected" || return $?
  else
    # Otherwise open the file in vim
    code -- "$selected"
  fi
}

# Short alias
alias fo='fzf_open'
