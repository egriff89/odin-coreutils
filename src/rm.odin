package coreutils

import "core:strings"
import "core:flags"
import "core:fmt"
import "core:os"

main :: proc() {
    Options :: struct {
        overflow: [dynamic]string `usage:"files or directories to remove"`,
        recursive_lower: bool `args:"name=r" usage:"remove directories and their contents recursively"`,
        recursive_upper: bool `args:"name=R" usage:"remove directories and their contents recursively"`,
        recursive_long: bool `args:"name=recursive" usage:"remove directories and their contents recursively"`,
        verbose: bool `args:"name=v" usage:"explain what is being done"`,
        verbose_long: bool `args:"name=verbose" usage:"explain what is being done"`,
    }

    opts: Options
    style: flags.Parsing_Style = .Unix
    flags.parse_or_exit(&opts, os.args, style)
    files := strings.split(strings.join(opts.overflow[:], " "), " ")

    if len(files) == 0 {
        fmt.println("rm: missing operand")
        return
    } else {
        if opts.recursive_lower || opts.recursive_upper || opts.recursive_long {
            for file in files {
                recursive_remove(file, opts.verbose || opts.verbose_long)
            }
        } else {
            for file in files {
                if opts.verbose || opts.verbose_long {
                    fmt.println("removed: ", file)
                }
                os.remove(file)
            }
        }
    }
}

recursive_remove :: proc(path: string, verbose: bool) {
    file_info, err := os.stat(path)
    if err != nil {
        fmt.println("rm: cannot access '", path, "': No such file or directory")
        return
    }

    if file_info.is_dir {
        // Open directory and read its contents
        handle, open_err := os.open(path)
        if open_err != nil {
            fmt.println("rm: cannot open '", path, "'")
            return
        }
        defer os.close(handle)

        entries, read_err := os.read_dir(handle, -1)
        if read_err != nil {
            fmt.println("rm: cannot read '", path, "'")
            return
        }
        defer os.file_info_slice_delete(entries)

        // Recursively delete contents
        for entry in entries {
            full_path := strings.concatenate([]string{path, "/", entry.name})
            defer delete(full_path)
            recursive_remove(full_path, verbose)
        }

        // Delete the now-empty directory
        if os.remove_directory(path) == nil {
            if verbose {
                fmt.println("removed directory: ", path)
            }
        }
    } else {
        // Delete file
        if os.remove(path) == nil {
            if verbose {
                fmt.println("removed: ", path)
            }
        }
    }
}