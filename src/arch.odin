package coreutils

import "core:fmt"
import "core:sys/posix"

main :: proc() {
    // The same as `uname -m`
    uname: posix.utsname
    posix.uname(&uname)
    fmt.printfln("%s", uname.machine)
}