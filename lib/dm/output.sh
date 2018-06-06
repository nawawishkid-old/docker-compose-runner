t_bold=$(tput bold)
t_normal="$(tput sgr0)\033[0m"
t_error="\033[1;31m"
t_warn="\033[1;33m"
t_success="\033[1;32m"

o_bold()
{
    printf "${t_bold}$1${t_normal}"
}

o_error()
{
    printf "${t_error}$1${t_normal}"
}

o_warn()
{
    printf "${t_warn}$1${t_normal}"
}

o_success()
{
    printf "${t_success}$1${t_normal}"
}

# Echo formatted text
# Usage: out_pair KEY VALUE TYPE
out_pair()
{
    local KEY="$1"
    local VALUE="$2"
    local TYPE="$3"

    case "$TYPE" in
        bold)
            echo -e "$(o_bold "$KEY"): "$VALUE""
            ;;
        success)
            echo -e "$(o_success "$KEY"): "$VALUE""
            ;;
        error)
            echo -e "$(o_error "$KEY"): "$VALUE""
            ;;
        warning)
            echo -e "$(o_warning "$KEY"): "$VALUE""
            ;;
    esac
}