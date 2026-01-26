package coreutils

import "core:strings"
import "core:flags"
import "core:fmt"
import "core:os"

main :: proc() {
    Options :: struct {
        overflow: [dynamic]string `usage:"files or directories to remove"`,
        verbose: bool `args:"name=v" usage:"explain what is being done`,
        verbose_long: bool `args:"name=verbose" usage:"explain what is being done`
    }

    opts: Options
    style: flags.Parsing_Style = .Unix
    flags.parse_or_exit(&opts, os.args, style)
    files := strings.split(strings.join(opts.overflow[:], " "), " ")

    if len(files) > 0 {
        for file in files {
            if os.remove_directory(file) == nil {
                if opts.verbose || opts.verbose_long {
                    fmt.printfln("rmdir: removing directory, '%s'", file)
                }
            } else {
                fmt.printfln("rmdir: failed to remove '%s': Directory not empty", file)
                return
            }
        }
    }
}