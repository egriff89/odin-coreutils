set working-directory := 'bin'

@build:
    find .. -name '*.odin' -not -path '../utils/*' -exec odin build {} -file \;