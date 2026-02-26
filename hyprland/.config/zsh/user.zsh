#  Startup 
# Commands to execute on startup (before the prompt is shown)
# Check if the interactive shell option is set
if [[ $- == *i* ]]; then
    # This is a good place to load graphic/ascii art, display system information, etc.
    if command -v pokego >/dev/null; then
        pokego --no-title -r 1,3,6
    elif command -v pokemon-colorscripts >/dev/null; then
        pokemon-colorscripts --no-title -r 1,3,6
    elif command -v fastfetch >/dev/null; then
        if do_render "image"; then
            fastfetch --logo-type kitty
        fi
    fi
fi

#   Overrides 
# HYDE_ZSH_NO_PLUGINS=1 # Set to 1 to disable loading of oh-my-zsh plugins, useful if you want to use your zsh plugins system 
# unset HYDE_ZSH_PROMPT # Uncomment to unset/disable loading of prompts from HyDE and let you load your own prompts
# HYDE_ZSH_COMPINIT_CHECK=1 # Set 24 (hours) per compinit security check // lessens startup time
# HYDE_ZSH_OMZ_DEFER=1 # Set to 1 to defer loading of oh-my-zsh plugins ONLY if prompt is already loaded

if [[ ${HYDE_ZSH_NO_PLUGINS} != "1" ]]; then
    #  OMZ Plugins 
    # manually add your oh-my-zsh plugins here
    plugins=(
        "sudo"
    )
fi

# PATH additions
# ~/bin and ~/.npm-global/bin are not added by HyDE's env.zsh, so we add them here.
# Note: ZDOTDIR is set to ~/.config/zsh, so ~/.zshrc is not sourced automatically.
export PATH="$HOME/bin:$HOME/.npm-global/bin:$PATH"

# NOTE: Atuin init is in $ZDOTDIR/.zshrc (not here) because it must run AFTER
# _load_completions() in terminal.zsh, which sources completions/fzf.zsh and
# runs "eval $(fzf --zsh)". That call binds Ctrl+R to fzf-history-widget and
# would overwrite atuin's Ctrl+R binding if atuin ran here. $ZDOTDIR/.zshrc
# is read by zsh after terminal.zsh completes, so atuin wins there.
