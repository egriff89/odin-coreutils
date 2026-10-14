package coreutils

import "core:flags"
import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	Options :: struct {
		overflow:  [dynamic]string `usage:"files or directories to remove"`,
		force:     bool `args:"name=f" usage:"ignore nonexistent files and arguments, never prompt"`,
		recursive: bool `args:"name=r" usage:"remove directories and their contents recursively"`,
		verbose:   bool `args:"name=v" usage:"explain what is being done"`,
	}

	opts: Options
	style: flags.Parsing_Style = .Odin
	flags.parse_or_exit(&opts, os.args, style)

	if len(opts.overflow) == 0 {
		if !opts.force {
			fmt.println("rm: missing operand")
			fmt.println("Try 'rm -help' for more information.")
		}
		os.exit(1)
	} else {
		if opts.recursive {
			for file in opts.overflow {
				recursive_remove(file, opts.verbose, opts.force)
			}
		} else {
			for file in opts.overflow {
				handle, err := os.stat(file, allocator = context.temp_allocator)
				if err != nil {
					if !opts.force {
						fmt.printfln(
							"rm: cannot access '%s': %s",
							handle.name,
							os.error_string(err),
						)
					}
					os.exit(1)
				}

				os.remove(file)
				if opts.verbose && !opts.force {
					fmt.printfln("removed: %s", file)
				}
			}
		}
	}
}

recursive_remove :: proc(path: string, verbose: bool, force := false) {
	allocator := context.temp_allocator
	file_info, err := os.stat(path, allocator)
	if err != nil {
		if !force {
			fmt.printfln("rm: cannot access '%s': %s", path, os.error_string(err))
		}
		os.exit(1)
	}

	if file_info.type == .Directory {
		// Open directory and read its contents
		handle, open_err := os.open(path)
		if open_err != nil {
			if !force {
				fmt.printfln("rm: '%s': %s", path, os.error_string(open_err))
			}
			os.exit(1)
		}
		defer os.close(handle)

		entries, read_err := os.read_dir(handle, -1, allocator)
		if read_err != nil {
			if !force {
				fmt.printfln("rm: '%s': %s", path, os.error_string(read_err))
			}
			os.exit(1)
		}
		defer os.file_info_slice_delete(entries, allocator)

		// Recursively delete contents
		for entry in entries {
			full_path := strings.concatenate([]string{path, "/", entry.name})
			defer delete(full_path)
			recursive_remove(full_path, verbose, force)
		}

		// Delete the now-empty directory
		if os.remove_all(path) == nil {
			if verbose && !force {
				fmt.printfln("removed directory: %s", path)
			}
		}
	} else {
		// Delete file
		if os.remove(path) == nil {
			if verbose && !force {
				fmt.printfln("removed: %s", path)
			}
		}
	}
}
