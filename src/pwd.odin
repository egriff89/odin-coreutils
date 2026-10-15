package coreutils

import "core:fmt"
import "core:os"

main :: proc() {
	dir, err := os.get_working_directory(context.temp_allocator)
	if err != nil {
		fmt.printfln("pwd: %s", os.error_string(err))
		os.exit(1)
	}

	fmt.println(dir)
}
