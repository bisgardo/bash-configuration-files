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

function editline() {
    local line
    local -a input

    # Detect if stdin is redirected
    if [ ! -t 0 ]; then
	# if so, read all standard input into variable
	while read line; do
	    input[${#input[@]}]="$line"
	done
    fi

    # Add contents of each input file
    for file in "$@"; do
	if [ ! -f "$file" ]; then
	    echo "Error: editline: file '$file' not found" >&2
	    exit 1
	fi

	while read line; do
	    input[${#input[@]}]="$line"
	done < "$file"
    done

    # Concat all input lines into a single one
    line=${input[*]}

    # Edit the line in terminal. By not quoting the input,
    # we collapse all contiguous whitespace into the first
    # character in IFS, which by default is a single space
    read -ei "$line" line < /dev/tty
    echo "$line"
}
