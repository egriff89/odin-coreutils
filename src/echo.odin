package coreutils

import "core:flags"
import "core:fmt"
import "core:os"
import "core:strings"
import st "../utils/string"

main :: proc() {
	Options :: struct {
		overflow:   [dynamic]string `usage:"String to write to standard output"`,
		no_newline: bool `args:"name=n" usage:"do not output the trailing newline"`,
		interp:     bool `args:"name=e" usage:"enable interpretation of backslash escapes"`,
		nointerp:   bool `args:"name=E" usage:"disable interpretation of backslash escapes (default)"`,
	}

	opt: Options
	opt.nointerp = true

	style: flags.Parsing_Style = .Odin
	flags.parse_or_exit(&opt, os.args, style)

	str := strings.join(opt.overflow[:], " ")

	// -n passed, do not parse newlines
	if opt.no_newline {
		if opt.interp {
			// -e also passed, parse all escapes (including newlines)
			st.write_escaped_string(&os.stdout, str)
		} else {
			// Only remove newlines
			fmt.print(strings.replace(str, "\n", "", -1))
		}
	} else if opt.interp {
		st.write_escaped_string(&os.stdout, str)
		fmt.print("\n")
	} else {
		// No flags passed, same as -E
		fmt.println(str)
	}
}
