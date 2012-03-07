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
