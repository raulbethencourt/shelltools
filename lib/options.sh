#!/bin/bash
# Options parsing utilities for shell toolbox

# Configuration

create_section_constants() {
	# Creates constants for section texts (usage, examples, requirements) from arguments.
	# Args: $1=arg to check, $2+=list of section names
	# Returns: 0 if section found and constant set, 1 otherwise
	local arg="$1"
	local sections=("{$@:2}")
	local section

	for section in "${sections[@]}"; do
		[[ "$arg" == --$section:* ]] && {
			local value="${arg#*:}"
			local var_name="TB_${section^^}_TXT" # Uppercase section (e.g., USAGE)
			declare -g "$var_name=$value"
			return 0
		}
	done
  
	return 1
}

# Print character n times

printcn() {
	# Prints a character n times to stdout.
	# Args: $1=character (default '?'), $2=count (default 1)
	local c=${1:-\?}
	local l=${2:-1}

	while [ "$l" -gt 0 ]; do
		printf "%s" "$c"
		l=$((l - 1))
	done
}

# Option Definition

def_options() {
	# Defines command-line options with their short/long forms, defaults, and patterns.
	# Parses option definitions and populates toolbox arrays with option metadata.
	# Args: $1=prefix for variable names, $2+=option definitions (format: --long:-s[=value|default=val]:description)
	# Supports special section args like --usage:TEXT, --examples:TEXT, --requirements:TEXT
	local sections=("usage" "examples" "requirements")
	toolbox_IDXDEF="${toolbox_IDXDEF:-0}"
	allready_parsed=1

	prefix=$1
	shift

	for arg in "$@"; do
		create_section_constants "$arg" "${sections[@]}" && continue

		currentIdx="$toolbox_IDXDEF"
		toolbox_IDXES=(${toolbox_IDXES[@]} $toolbox_IDXDEF)
		toolbox_IDXDEF=$((toolbox_IDXDEF + 1))
		thislg=${arg%%:*}

		for l in "${toolbox_LONGS[@]}"; do
			[ "$thislg" = "$l" ] && error_exit "Same long option defined more than once : $thislg" 2
		done
		toolbox_LONGS=("${toolbox_LONGS[@]}" "$thislg")

		second=${arg#*:}

		fullsh=-${second%:*}

		varName=$(echo "${prefix}${thislg:2}" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
		defaultValue=$(eval "echo \${$varName}")
		[ "$defaultValue" = "loginpath" ] && echo "$varName variable is $defaultValue !"
		valuePattern="NO_VALUE"

		is_array=0

		case "$fullsh" in
		*=*)
			echo "$fullsh" | grep '=\[\]' >/dev/null && is_array=1
			thissh=${fullsh%%=*}=
			valuedef=${fullsh#*=}
			valuePattern=${valuedef%|default=*}
			[ "$valuePattern" != "$valuedef" ] && defaultValue=${defaultValue:-${valuedef##*|default=}} && defaultValue=${defaultValue//_ABCBA_/ }
			[ -z "$valuedef" ] && valuePattern="*"
			;;
		*)
			thissh=$fullsh
			[ ${#defaultValue} -eq 0 ] && defaultValue=0
			;;
		esac

		for s in "${toolbox_SHORTS[@]}"; do
			{ [ "$s" = "-" ] || [ "$s" = "-=" ]; } && continue
			[ "$thissh" = "$s" ] && error_exit "Same short option defined more than once : $thissh" 2
		done

		toolbox_SHORTS=("${toolbox_SHORTS[@]}" "$thissh")
		toolbox_ISARRAY=("${toolbox_ISARRAY[@]}" "$is_array")
		thisd=${second##*:}
		toolbox_DESCRS=("${toolbox_DESCRS[@]}" "${thisd/_ABCBA_/ }")
		toolbox_PREFIXS=("${toolbox_PREFIXS[@]}" "$prefix")
		toolbox_PATTERN=("${toolbox_PATTERN[@]}" "$valuePattern")
		toolbox_DEFAULT=("${toolbox_DEFAULT[@]}" "$([ -z "$defaultValue" ] && echo "EMPTY_VALUE" || echo "${defaultValue}")")

		declare -g "${varName}_is_default"=1
		option_set_value "$currentIdx" "${defaultValue}" 0

	done
}

def_pos_arg() {
	# Defines a positional argument with its metadata.
	# Args: $1=name, $2=pattern, $3=description, $4=mandatory (1=yes, 0=no)
	toolbox_POSITIONAL_IDXES=("${toolbox_POSITIONAL_IDXES[@]}" "$toolbox_POSITIONAL_IDXDEF")
	toolbox_POSITIONAL_NAME=("${toolbox_POSITIONAL_NAME[@]}" "$1")
	toolbox_POSITIONAL_PATTERN=("${toolbox_POSITIONAL_PATTERN[@]}" "${2/_ABCBA_/ }")
	toolbox_POSITIONAL_DESCR=("${toolbox_POSITIONAL_DESCR[@]}" "$3")
	toolbox_POSITIONAL_MANDATORY=("${toolbox_POSITIONAL_MANDATORY[@]}" "$4")
	toolbox_POSITIONAL_IDXDEF=$((toolbox_POSITIONAL_IDXDEF + 1))
}

# Option Printing

print_pos_arg_values() {
	# Prints possible values for a positional argument.
	# Args: $1=base index, $2=forUsage flag (1=compact, 0=full)
	forUsage=$2
	idx=$((base - 1))
	print_values "" $forUsage "$(echo ${toolbox_POSITIONAL_PATTERN[$idx]} | sed 's/_ABCBA_/ /g')"
}

print_long_options() {
	# Prints all defined long option names.
	# Returns: list of long option names (one per line)
	for idx in "${toolbox_IDXES[@]}"; do
		echo "${toolbox_LONGS[$idx]}"
	done
}

print_all_options() {
	# Prints all defined options in bracketed format for usage display.
	# Returns: space-separated list of options (e.g., "[-h] [--help]")
	for idx in "${toolbox_IDXES[@]}"; do
		sh=${toolbox_SHORTS[$idx]#\-}
		sh=${sh%=}
		[ -n "$sh" ] && printf "[%s] " "${toolbox_SHORTS[$idx]}"
		[ -z "$sh" ] && printf "[%s] " "${toolbox_LONGS[$idx]}"
	done
}

print_all_positional() {
	# Prints all positional argument names.
	# Returns: space-separated list of positional argument names
	for idx in "${toolbox_POSITIONAL_IDXES[@]}"; do
		printf "%s " "${toolbox_POSITIONAL_NAME[$idx]}"
	done
}

print_values() {
	# Prints possible values based on a pattern specification.
	# Handles special patterns like file;, path;, exec;, databases;, branches;.
	# Args: $1=pattern prefix, $2=forUsage flag (1=compact, 0=full), $3+=patterns to evaluate
	forUsage="$2"
	shift 2

	for v in "$@"; do
		[ "${v:0:2}" = "[]" ] && v="${v:2}"

		if [ "${v:0:5}" = "file;" ]; then
			[ $forUsage -gt 0 ] && echo "file" && return 0
			echo "compopt_-o_nospace_-o_plusdirs"
			compgen -G "${pattern}${v:5}"
		elif [ "${v:0:5}" = "path;" ]; then
			[ $forUsage -gt 0 ] && echo "path" && return 0
			echo "compopt_-o_nospace_-o_plusdirs"
			compgen -G "${pattern}"
		elif [ "${v:0:5}" = "exec;" ]; then
			cmd=${v:5}
			cmd="${cmd//_ABCBA_/ }"
			output=$(eval "$cmd")
			[ $forUsage -eq 0 ] && echo "$output"
			[ $forUsage -gt 0 ] && echo "$output" | tr '\n' ' '
		elif [ "${v:0:10}" = "databases;" ]; then
			loginPathVar=${v:10}
			[ "${loginPathVar:0:1}" = "$" ] && loginPathVar=$(eval "eval echo ${v:10}")
			[ $forUsage -eq 0 ] && mysql --login-path="$loginPathVar" -e 'show databases;' 2>/dev/null | grep -v "+" | grep -iv "database" | tr ' ' '\n'
			[ $forUsage -gt 0 ] && mysql --login-path="$loginPathVar" -e 'show databases;' 2>/dev/null | grep -v "+" | grep -iv "database"
		elif [ "${v:0:9}" = "branches;" ]; then
			git branch --all | sed -e "s/*//" -e "s/^ *//" -e "s%remotes/origin/%%"
		else
			[ $forUsage -eq 0 ] && for vun in ${v//_ABCBA_/ }; do echo "$vun"; done
			[ $forUsage -gt 0 ] && echo "${v//_ABCBA_/ }"
		fi
	done
}

print_option_values() {
	# Prints possible values for a specific option.
	# Args: $1=option name, $2=match prefix, $3=outputForUsage (default 0)
	# Returns: 247 if option takes no value
	for idx in "${toolbox_IDXES[@]}"; do
		if [ "${toolbox_LONGS[$idx]}" = "$optionName" ] || [ "-${toolbox_SHORTS[$idx]:1:1}" = "$optionName" ]; then
			[ "${toolbox_PATTERN[$idx]}" = "NO_VALUE" ] && return 247
			print_values "$match" "$outputForUsage" "${toolbox_PATTERN[$idx]}"
		fi
	done
}

option_print_argument() {
	# Prints the option as a command-line argument with its value.
	# Handles both flag options (printed multiple times) and value options (key=value).
	# Args: $1=option index or name
	if [ "$(option_print_value "$1")" != "" ] && [ "$(option_print_value "$1")" != "0" ]; then
		if option_needs_value "$1"; then
			if option_is_array "$1"; then
				echo "PRINTING ARRAY ARGUMENTS IS NOT IMPLEMENT YET !" >&2 && EXIT 7
			else
				echo "$(option_print_long "$1")=$(option_print_value "$1")"
			fi
		else
			count=0
			while [ "$count" -lt "$(option_print_value "$1")" ]; do
				printf "%s " "$(option_print_long "$1")"
				count=$((count + 1))
			done

			printf "\n"
		fi
	fi
}

# Option Parsing

parse_partial_options() {
	# Parses options without post-processing (allows unknown options).
	# Delegates to _parse_options_impl with allowUnknown=0.
	# Args: $@=command-line arguments to parse
	_parse_options_impl 0 "$@"
}

parse_options() {
	# Parses options with full validation (unknown options cause error).
	# Delegates to _parse_options_impl with allowUnknown=1.
	# Args: $@=command-line arguments to parse
	_parse_options_impl 1 "$@"
}

_parse_options_impl() {
	# Internal implementation for option parsing.
	# Args: $1=doPostProcess (1=validate, 0=allow unknown), $2=allowUnknown flag, $3=prefix, $4+=arguments to parse
	# Exits: 0 on success, 3 for unknown option, 4 for missing value, 5 for missing positional, 6 for wrong order, 17 for invalid input
	doPostProcess=$1
	shift

	TBOPTIND=0
	# replace spaces in parameters so we're sure options won't end up truncated at some point
	for arg in "$@"; do
		shift
		set -- "$@" "$(printf "%s" "$arg" | sed -r 's/ /_ABCBA_/g')"
	done

	# explode multi short options (-abcd becomes -a -b -c -d)
	c="$@"
	d="$(echo "$c" | sed -r 's/ -([^-])([^ =])/ -\1 -\2/g')"
	while [ "$c" != "$d" ]; do
		trt="$d"
		c="$d"
		d="$(echo "$trt" | sed -r 's/ -([^-])([^ =])/ -\1 -\2/g')"
		TBOPTIND=$((TBOPTIND - 1))
	done
	set -- $d

	# read parameters
	printUsage=0
	allowUnknown=$1
	shift
	prefix=$1
	shift

	# custom internal behaviours
	INT_print_env=0
	INT_print_complete_long_options_list=0
	INT_print_option_values=0
	INT_print_option_name=""
	INT_print_option_value_prefix=""
	INT_print_pos_arg_index=""

	UNHANDLED_OPTIONS=()
	defPart=1
	expectsValue=""
	currentPosArgIndex=1
	for arg in "$@"; do
		shift
		if [ "${arg:0:19}" = "--toolbox-print-env" ]; then
			INT_print_env=1
			[ "${arg:19:4}" = "-ext" ] && INT_print_env=2

		elif [ "$arg" = "--toolbox-long-options" ]; then
			INT_print_complete_long_options_list=1

		elif [ "$arg" = "--toolbox-option-values" ]; then
			INT_print_option_values=1
		elif [ $INT_print_option_values -eq 1 ]; then
			INT_print_option_values=2
			INT_print_option_name=$arg
		elif [ $INT_print_option_values -eq 2 ]; then
			INT_print_option_values=3
			INT_print_option_value_prefix=$arg

		elif [ "$arg" = "--toolbox-pos-arg-values" ]; then
			INT_print_pos_arg_index=$currentPosArgIndex

		elif [ -n "$expectsValue" ]; then
			TBOPTIND=$((TBOPTIND + 1))
			option_set_value "${expectsValue}" "$arg"
			expectsValue=""

		elif [ $defPart -eq 1 ]; then
			if [ "$arg" = "--" ]; then
				defPart=0
			elif [ "${arg:0:2}" = "--" ]; then
				def_options "$prefix" "$arg"
			else
				echo "Invalid input ($arg)" >&2
				exit 17
			fi
		elif [ "$arg" = '-h' ] || [ "$arg" = '--help' ]; then
			printUsage=$((printUsage + 2))
		else
			found=0

			for idx in "${toolbox_IDXES[@]}"; do
				short=${toolbox_SHORTS[$idx]}
				val=0
				argName="$arg"
				argValue=""
				if option_needs_value "$idx"; then
					val=1
					short=${short:0:-1}
					argName="${arg%%=*}"
					argValue="${arg#*=}"
					# if no '=' sign is used, value should be in next argument
					[ "$argValue" = "$arg" ] && argValue=""
				fi

				if [ "$argName" = "${toolbox_LONGS[$idx]}" ] || [ "$argName" = "${toolbox_SHORTS[$idx]}" ] || [ "$argName" = "${short}" ]; then
					if [ $val -eq 1 ]; then
						if [ -z "$argValue" ]; then
							expectsValue=${toolbox_LONGS[$idx]}
						else
							option_set_value $idx "$argValue"
						fi
					else
						option_increment_value "$argName"
					fi

					found=1

					if ! [ -z "${UNHANDLED_OPTIONS}" ]; then
						echo "Toolbox parameters must be before any other parameters" >&2
						toolbox_print_usage 2 1 "" >&2
						exit 6
					fi

					TBOPTIND=$((TBOPTIND + 1))

					break
				fi
			done

			if [ $found -eq 0 ]; then
				if [ $allowUnknown -eq 0 ] && [ "${arg:0:1}" = "-" ]; then
					echo "Unknown option : $arg" >&2
					toolbox_print_usage 2 1 >&2
					exit 3
				else
					UNHANDLED_OPTIONS=("${UNHANDLED_OPTIONS[@]}" "$arg")
					posVarName=$(positional_print_varname $((currentPosArgIndex - 1)))
					[ -n "$posVarName" ] && declare -g "$posVarName"="$arg"
					currentPosArgIndex=$((currentPosArgIndex + 1))
				fi
			fi

			if [ $found -eq 0 ]; then
				set -- "$@" "$arg"
			fi
		fi
	done

	[ $INT_print_complete_long_options_list -eq 1 ] && print_long_options
	[ $INT_print_complete_long_options_list -eq 1 ] && exit 0

	[ -n "$INT_print_option_name" ] && print_option_values "$INT_print_option_name" "$INT_print_option_value_prefix" 0
	[ -n "$INT_print_option_name" ] && exit 0

	[ -n "$INT_print_pos_arg_index" ] && print_pos_arg_values ${INT_print_pos_arg_index} 0
	[ -n "$INT_print_pos_arg_index" ] && exit 0

	if [ $printUsage -gt 0 ]; then
		toolbox_print_usage "$printUsage" 0 ""
		exit 0
	fi

	if [ -n "$expectsValue" ]; then
		echo $printUsage >&2
		echo "${expectsValue} flag expects a value !" >&2
		exit 4
	fi

	for idx in "${toolbox_POSITIONAL_IDXES[@]}"; do
		if [ "${toolbox_POSITIONAL_MANDATORY[$idx]}" -eq 1 ]; then
			varname=$(positional_print_varname $idx)
			value=$(eval "echo \${$varname}")
			[ -z "$value" ] && toolbox_print_usage 2 1 "Positional argument ${toolbox_POSITIONAL_NAME[$idx]} value is missing" >&2 && exit 5
		fi
	done
}

# Option Accessors

option_get_uniqueidx() {
	# Gets the unique index for an option by its name.
	# Args: $1=option name (long, short, or index)
	# Returns: the index value, exits with error code if not found
	name=$1
	[ "${name:0:1}" != "-" ] && echo "$1" && return "$1"

	[ -z "$name" ] && echo "get_option_uniqueidx() needs option name as parameter" >&2 && return 1

	for idx in "${toolbox_IDXES[@]}"; do
		if [ "${toolbox_LONGS[$idx]}" = "$name" ] || [ "${toolbox_SHORTS[$idx]}" = "$name" ]; then
			echo "$idx"
			return $idx
		fi
	done

	echo "option $name not found" >&2 && return 254
}

positional_print_varname() {
	# Prints the environment variable name for a positional argument.
	# Args: $1=positional argument index
	# Returns: uppercase variable name (e.g., "FILE_NAME")
	idx=$1
	echo "${toolbox_POSITIONAL_NAME[$idx]}" | tr '[:lower:]' '[:upper:]' | tr '-' '_'
}

option_needs_value() {
	# Checks if an option requires a value.
	# Args: $1=option index or name
	# Returns: 0 if requires value, 1 otherwise
	idx=$(option_get_uniqueidx $1)
	[ "${toolbox_SHORTS[$idx]:1:1}" = "=" ] && return 0
	[ "${toolbox_SHORTS[$idx]:2:1}" = "=" ] && return 0 || return 1
}

option_is_array() {
	# Checks if an option is defined as an array type.
	# Args: $1=option index or name
	# Returns: 0 if array type, 1 otherwise
	idx=$(option_get_uniqueidx $1)
	option_needs_value "$1" && [ "${toolbox_ISARRAY[$idx]}" -eq 1 ] && return 0
	return 1
}

option_print_varname() {
	# Prints the environment variable name for an option.
	# Args: $1=option index or name
	# Returns: uppercase variable name with prefix (e.g., "PREFIX_OPTION_NAME")
	idx=$(option_get_uniqueidx $1)
	echo "${toolbox_PREFIXS[$idx]}${toolbox_LONGS[$idx]:2}" | tr '[:lower:]' '[:upper:]' | tr '-' '_'
}

option_print_long() {
	# Prints the long option name for an option.
	# Args: $1=option index or name
	# Returns: long option name (e.g., "--option-name")
	idx=$(option_get_uniqueidx $1)
	echo "${toolbox_LONGS[$idx]}"
}

option_print_short() {
	# Prints the short option string repeated for the option's value count.
	# Args: $1=option index or name
	# Returns: short option repeated (e.g., "-vvv" for count 3)
	idx=$(option_get_uniqueidx $1)
	flag="${toolbox_SHORTS[$idx]:1:1}"
	count=$(option_print_value $1)
	[ $count -gt 0 ] && echo "-$(printcn "$flag" "$count")"
}

option_print_value() {
	# Prints the current value of an option.
	# Args: $1=option index or name
	# Returns: option value (array values as space-separated list)
	idx=$(option_get_uniqueidx $1)
	varname=$(option_print_varname $idx)
	if option_is_array $1; then
		value=$(eval "echo \"\$\{${varname}\[\@\]\}\"")
		echo "${value[@]}"
	else
		value=$(eval "echo \"\${$varname}\"")
		echo "$value"
	fi
}

option_set_value() {
	# Sets the value of an option, handling both scalar and array types.
	# Args: $1=option index or name, $2=value, $3=set_default_flag (0=keep default flag)
	idx="$(option_get_uniqueidx "$1")"
	value="${2//_ABCBA_/ }"

	if option_is_array "$1"; then
		declare -ga varname="$(option_print_varname $idx)"
		declare -n varnamename="$(option_print_varname $idx)"
		tmp=()
		if [ "$(eval "echo \$${varname}_is_default")" -eq 0 ]; then
			for v in "${varnamename[@]}"; do
				[ -z "$v" ] && continue
				tmp+=("$v")
			done
		fi
		[ -n "$value" ] && tmp+=("$value")
		for idx in "${!tmp[@]}"; do
			declare -ga ${varname}[$idx]="${tmp[$idx]}"
		done
	else
		varname="$(option_print_varname $idx)"
		declare -g "$varname"="$value"
	fi

	[ "$3" != "0" ] && declare -g "${varname}_is_default"=0
}

option_increment_value() {
	# Increments the numeric value of an option (typically for flag counts).
	# Args: $1=option index or name
	idx=$(option_get_uniqueidx $1)
	value=$(option_print_value $idx)
	value=$((value + 1))
	option_set_value "$idx" "$value"
}
