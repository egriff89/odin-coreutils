package coreutils

import "core:flags"
import "core:fmt"
import "core:os"

Options :: struct {
	physical:      bool `args:"name=P" usage:"Output the physical working directory, with symlinks resolved."`,
	physical_long: bool `args:"name=physical" usage:"Output the physical working directory, with symlinks resolved."`,
	logical:       bool `args:"name=L" usage:"Output the logical working directory, without resolving symlinks (default behavior)."`,
	logical_long:  bool `args:"name=logical" usage:"Output the logical working directory, without resolving symlinks (default behavior)."`,
}

main :: proc() {
	opts: Options
	style: flags.Parsing_Style = .Odin
	flags.parse_or_exit(&opts, os.args, style)

	// pwd -L prints $PWD when it is an absolute path of this directory with
	// no "." or ".." components. Otherwise it behaves as pwd -P.
	if opts.logical || opts.logical_long {
		dir := os.get_env("PWD", context.temp_allocator)
		if logical_pwd_ok(dir) {
			fmt.printfln("%s", dir)
			return
		}
	}

	if dir, err := os.get_working_directory(context.temp_allocator); err != nil {
		fmt.printfln("pwd: %s", os.error_string(err))
		os.exit(1)
	} else {
		fmt.printfln("%s", dir)
	}
}

logical_pwd_ok :: proc(dir: string) -> bool {
	if !os.is_absolute_path(dir) || has_dot_component(dir) {
		return false
	}

	pwd_info, pwd_err := os.stat(dir, context.temp_allocator)
	cwd_info, cwd_err := os.stat(".", context.temp_allocator)
	if pwd_err != nil || cwd_err != nil {
		return false
	}
	return(
		pwd_info.inode != 0 &&
		pwd_info.inode == cwd_info.inode &&
		pwd_info.device == cwd_info.device \
	)
}

has_dot_component :: proc(path: string) -> bool {
	start := 0
	for i := 0; i <= len(path); i += 1 {
		if i == len(path) || path[i] == '/' {
			comp := path[start:i]
			if comp == "." || comp == ".." {
				return true
			}
			start = i + 1
		}
	}
	return false
}
