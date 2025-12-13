set working-directory := 'bin'

build-all:
    find .. -name '*.odin' -not -path '../utils/*' -exec odin build {} -file \;

build file:
    odin build ../src/{{file}}.odin -file

run file:
    odin run ../src/{{file}}.odin -file