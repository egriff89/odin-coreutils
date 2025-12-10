package coreutils

import "core:fmt"
import "core:sys/posix"

main :: proc() {
    uid := posix.getuid()
    user := posix.getpwuid(uid)
    if user != nil {
        fmt.println(user.pw_name)
    }
}