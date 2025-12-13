# Build all source files, excluding the utils directory
[working-directory: 'bin']
build-all:
    find .. -name '*.odin' -not -path '../utils/*' -exec odin build {} -file \;

# Build a specific file from the src directory
[working-directory: 'bin']
build file:
    odin build ../src/{{file}}.odin -file

# Build and run a specific file
[working-directory: 'bin']
build-run file:
    odin build ../src/{{file}}.odin -file
    ./{{file}}

# Run a specific file without building
run file:
    odin run ./src/{{file}}.odin -file