set working-directory := 'bin'

build-all:
    find .. -name '*.odin' -not -path '../utils/*' -exec odin build {} -file \;

build file:
    @echo 'Building src/{{file}}.odin'
    odin build ../src/{{file}}.odin -file