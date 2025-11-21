package coreutils

import "core:fmt"
import "core:os"

main :: proc() {
	fmt.println(os.get_env("USER"))
}


