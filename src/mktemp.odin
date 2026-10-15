package coreutils

import "core:flags"
import "core:fmt"
import "core:os"

main :: proc() {
	Options :: struct {
		dir:          bool `args:"name=d" usage:"create a directory, not a file"`,
		quiet:        bool `args:"name=q" usage:"suppress diagnostics about file/directory creation failure"`,
		template:     string `args:"t" usage:"interpret TEMPLATE as a single file name component, relative to a directory"`,
		template_dir: string `args:"name=p" usage:"interpret TEMPLATE relative to directory (Default: /tmp)"`,
	}

	opts: Options
	opts.template = "tmp.*"
	style: flags.Parsing_Style = .Odin
	flags.parse_or_exit(&opts, os.args, style)

	if opts.dir {
		allocator := context.temp_allocator
		temp_path, err := os.make_directory_temp(opts.template_dir, opts.template, allocator)
		if err != nil {
			if !opts.quiet {
				fmt.printfln(
					"mktemp: failed to create directory via template '%s/%s': %s",
					opts.template_dir,
					opts.template,
					os.error_string(err),
				)
			}
			os.exit(1)
		} else {
			if !opts.quiet {
				fmt.printfln(temp_path)
			}
		}
	} else {
		file, err := os.create_temp_file(opts.template_dir, opts.template)
		if err != nil {
			if !opts.quiet {
				fmt.printfln(
					"mktemp: failed to create file via template '%s/%s': %s",
					opts.template_dir,
					opts.template,
					os.error_string(err),
				)
			}
			os.exit(1)
		}
		defer os.close(file)

		if !opts.quiet {
			fmt.println(os.name(file))
		}
	}
}
