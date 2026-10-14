package coreutils

import "core:flags"
import "core:fmt"
import "core:os"

main :: proc() {
	Options :: struct {
		parents:  bool `args:"name=p" usage:"make parent directories as needed, no error if existing"`,
		overflow: [dynamic]string `usage:"directory or directories to create"`,
	}

	opts: Options
	style: flags.Parsing_Style = .Odin
	flags.parse_or_exit(&opts, os.args, style)

	if len(opts.overflow) < 1 {
		fmt.println("Try 'mkdir -help' for more information.")
		os.exit(0)
	}

	create := os.make_directory_all if opts.parents else os.make_directory
	for dir in opts.overflow {
		if dir == "" do continue
		if err := create(dir); err != nil {
			fmt.eprintfln("mkdir: cannot create directory '%s': %s", dir, os.error_string(err))
			os.exit(1)
		}
	}
}
