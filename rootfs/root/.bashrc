# Display banner
[ -f "$HOME/.banner" ] && cat "$HOME/.banner"

# Display build message
[ -f "$HOME/.built" ] && cat "$HOME/.built"

export PS1="\[\e[32;1m\]\u@\w > \[\e[0m\]"
