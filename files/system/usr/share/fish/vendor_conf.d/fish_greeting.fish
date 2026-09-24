function fish_greeting
    # Aurora's uwelcome banner is replaced by a fastfetch
    # system summary (borealis.txt logo). Skipped if the bash login already
    # greeted us (UWELCOME_SHOWN is inherited from the parent shell).
    if test -e ~/.config/no-show-user-motd
        return
    end
    if test -n "$UWELCOME_SHOWN"
        return
    end
    if not set -q UWELCOME_SHOWN
        set -gx UWELCOME_SHOWN 1
        type -q ublue-fastfetch; and ublue-fastfetch
    end
end