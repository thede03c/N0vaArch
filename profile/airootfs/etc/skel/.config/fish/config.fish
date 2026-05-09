if status is-interactive
    set -gx EDITOR nano
    set -gx VISUAL nano
    alias ll "ls -alh"
    alias update "sudo pacman -Syu"

    function fish_prompt
        set_color brred
        echo -n "R "
        set_color brwhite
        echo -n (prompt_pwd)
        set_color bryellow
        echo -n " > "
        set_color normal
    end

    if not set -q RAVEN_FETCH_SHOWN
        set -gx RAVEN_FETCH_SHOWN 1
        if command -v fastfetch >/dev/null 2>&1
            fastfetch
        end
    end
end
