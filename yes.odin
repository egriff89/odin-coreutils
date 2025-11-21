package yes

import "core:flags"
import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	Options :: struct {
		overflow: [dynamic]string `usage:"String to repeatedly print out until killed. Defaults to 'y'"`,
	}

	opt: Options
	style: flags.Parsing_Style = .Unix
	flags.parse_or_exit(&opt, os.args, style)

	str: string
	if len(os.args) > 1 {
		str = strings.join(opt.overflow[:], " ")
	} else {
		str = "y"
	}

	for {
		fmt.println(str)
	}
}

