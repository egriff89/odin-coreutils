package echo

import "core:flags"
import "core:fmt"
import "core:os"
import "core:strings"
import "utils"

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

	if opt.no_newline {
		opt.nointerp = false
		fmt.print(str)
	} else if opt.interp {
		opt.nointerp = false
		utils.write_escaped_string(&os.stdout, str)
	} else {
		fmt.println(str)
	}
}

