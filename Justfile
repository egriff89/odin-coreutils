# Build all source files, excluding the utils directory
[working-directory: 'bin']
build-all:
    find ../src -name '*.odin' -exec odin build {} -file \;

# Build a specific file from the src directory
build file:
    odin build ./src/{{file}}.odin -file -out:bin/{{file}}

# Build and run a specific file
build-run file:
    odin build ./src/{{file}}.odin -file -out:bin/{{file}}
    ./bin/{{file}}

# Run a specific file without building
run file:
    odin run ./src/{{file}}.odin -file