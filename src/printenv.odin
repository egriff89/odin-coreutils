package coreutils

import "core:strings"
import "core:flags"
import "core:fmt"
import "core:os"
import "core:sys/posix"

main :: proc() {
    Options :: struct {
        overflow: [dynamic]string `usage:"Print the value of the provided environment variable"`,
        null:bool `args:"name=0" usage:"end each output line with NUL, not newline"`,
        null_long:bool `args:"name=null" usage:"end each output line with NUL, not newline"`,
    }

    opt: Options
    style: flags.Parsing_Style = .Odin
    flags.parse_or_exit(&opt, os.args, style)
    str := strings.join(opt.overflow[:], " ")

    // Print the value of an environment variable if provided
    // For example: `printenv HOME`
    if len(str) > 0 {
        value := os.get_env(str)
        if opt.null || opt.null_long {
            fmt.print(value)
            os.write_byte(os.stdout, 0)
        } else {
            fmt.println(value)
        }
        return
    }

    // Print all environment variables on the system
    for i, entry := 0, posix.environ[0]; entry != nil; i, entry = i+1, posix.environ[i] {
        if opt.null || opt.null_long {
            fmt.print(entry)
            os.write_byte(os.stdout, 0)
            continue
        }
        fmt.println(entry)
    }
}