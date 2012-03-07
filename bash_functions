# function for setting variable using editor
function editvar() {
    local USAGE="Usage: editvar [-e editor] VAR"
    local EDITOR=nano

    EDITOR=${FCEDIT:-$EDITOR}

    # Parse arguments
    OPTIND=1
    while getopts ':e:' arg; do
        case $arg in
            e)
                EDITOR=$OPTARG
                ;;
            :)
                echo "Must supply arguments to -$OPTARG." >&2
                echo "$USAGE" >&2
                return 1
                ;;
            \?)
                echo "Invalid option: '-$OPTARG'." >&2
                echo "$USAGE" >&2
                return 1
        esac
    done
    
    # Get variable
    shift $((OPTIND-1))
    if [ $# -ne 1 ]; then
        echo "$USAGE" >&2
        return 1
    fi

    local var=$1
    local file="$(mktemp)"

    # set variable using temporary file
    echo -n ${!var} > "$file"
    $EDITOR "$file"
    eval $var=\"$(cat "$file")\"

    # clean up temporary file
    rm -f $file
}
