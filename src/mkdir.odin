package coreutils

import "core:flags"
import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	Options :: struct {
		parents:  bool `args:"name=p" usage:"make parent directories as needed, no error if existing"`,
		overflow: [dynamic]string `usage:"directory or directories to create"`,
	}

	opts: Options
	style: flags.Parsing_Style = .Odin
	flags.parse_or_exit(&opts, os.args, style)
	dirs := strings.split(strings.join(opts.overflow[:], " "), " ")

	if len(dirs) < 1 {
		fmt.println("Try 'mkdir -help' for more information.")
		os.exit(0)
	}

	for dir in dirs {
		allocator := context.temp_allocator
		if strings.contains(dir, "/") {
			if opts.parents {
				os.make_directory_all(dir)
			} else {
				nested := strings.split(dir, "/", allocator)
				for sub in nested {
					if _, err := os.stat(sub, allocator); err != nil {
						fmt.printf(
							"mkdir: cannot create directory '%s': No such file or directory",
							dir,
						)
						os.exit(1)
					}
				}
				os.make_directory_all(dir)
			}
		} else {
			os.make_directory(dir)
		}
	}
}
