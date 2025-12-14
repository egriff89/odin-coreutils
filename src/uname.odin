package coreutils

import "core:flags"
import "core:fmt"
import "core:os"
import "core:sys/posix"

main :: proc() {
    Option :: struct {
        all: bool `args:"name=a" usage:"print all system information"`,
        all_long: bool `args:"name=all" usage:"print all system information"`,
        kernel: bool `args:"name=s" usage:"print the kernel name"`,
        kernel_long: bool `args:"name=kernel-name" usage:"print the kernel name"`,
        nodename: bool `args:"name=n" usage:"print the network node hostname"`,
        nodename_long: bool `args:"name=nodename" usage:"print the network node hostname"`,
        release: bool `args:"name=r" usage:"print the kernel release"`,
        release_long: bool `args:"name=kernel-release" usage:"print the kernel release"`,
        version: bool `args:"name=v" usage:"print the kernel version"`,
        version_long: bool `args:"name=kernel-version" usage:"print the kernel version"`,
        machine: bool `args:"name=m" usage:"print the machine hardware name"`,
        machine_long: bool `args:"name=machine" usage:"print the machine hardware name"`,
        os: bool `args:"name=o" usage:"print the name of the operating system"`,
        os_long: bool `args:"name=operating-system" usage:"print the name of the operating system"`,
    }

    opt: Option
    style: flags.Parsing_Style = .Unix
    flags.parse_or_exit(&opt, os.args, style)

    uname: posix.utsname
    posix.uname(&uname)

    if opt.all || opt.all_long {
        fmt.printfln("%s %s %s %s %s %s",
            ODIN_OS_STRING,
            uname.nodename,
            uname.release,
            uname.version,
            uname.machine,
            get_os())
    } else if opt.kernel || opt.kernel_long {
        fmt.printfln("%s", ODIN_OS_STRING)
    } else if opt.nodename || opt.nodename_long {
        fmt.printfln("%s", uname.nodename)
    } else if opt.release || opt.release_long {
        fmt.printfln("%s", uname.release)
    } else if opt.version || opt.version_long {
        fmt.printfln("%s", uname.version)
    } else if opt.machine || opt.machine_long {
        fmt.printfln("%s", uname.machine)
    } else if opt.os || opt.os_long {
        fmt.println("%s", get_os())
    } else {
        // Default behavior: print the kernel name
        fmt.println(ODIN_OS_STRING)
    }

    os.exit(0)
}

get_os :: proc() -> string {
    when ODIN_OS == .Linux {
        return "GNU/Linux"
    } else when ODIN_OS == .Darwin {
        return "Darwin"
    } else when ODIN_OS == .Windows {
        return "Windows"
    } else {
        return "Unknown"
    }
}