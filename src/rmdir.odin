package coreutils

import "core:flags"
import "core:fmt"
import "core:os"

main :: proc() {
	Options :: struct {
		overflow: [dynamic]string `usage:"files or directories to remove"`,
		verbose:  bool `args:"name=v" usage:"explain what is being done`,
	}

	opts: Options
	style: flags.Parsing_Style = .Odin
	flags.parse_or_exit(&opts, os.args, style)

	if len(opts.overflow) > 0 {
		for file in opts.overflow {
			if err := os.remove(file); err == nil {
				if opts.verbose {
					fmt.printfln("rmdir: removing directory, '%s'", file)
				}
			} else {
				fmt.printfln("rmdir: failed to remove '%s': %s", file, os.error_string(err))
				os.exit(1)
			}
		}
	}
}
