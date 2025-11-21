#+feature dynamic-literals
package utils

import "core:os"

// Interprets C-style escapes in a string and writes to a writer
write_escaped_string :: proc(writer: ^os.Handle, s: string) -> os.Errno {
	i := 0
	for i < len(s) {
		if s[i] != '\\' {
			// Write non-escaped byte
			os.write_byte(writer^, s[i]) or_return
			i += 1
			continue
		}

		// Skip backslash and parse the escape
		new_i, err := handle_escapes(writer, s, i + 1)
		if err != nil {
			return err
		}
		i = new_i
	}
	return nil
}

handle_escapes :: proc(writer: ^os.Handle, s: string, start: int) -> (idx: int, err: os.Errno) {
	if start >= len(s) {
		// Trailing backslash - treat as literal
		os.write_byte(writer^, '\\') or_return
		return start, nil
	}

	esc := s[start]
	switch esc {
	case 'a', 'b', 'f', 'n', 'r', 't', 'v', '\\':
		simple_escapes := map[rune]byte {
			'a'  = '\a',
			'b'  = '\b',
			'f'  = '\f',
			'n'  = '\n',
			'r'  = '\r',
			't'  = '\t',
			'v'  = '\v',
			'\\' = '\\',
		}
		os.write_byte(writer^, simple_escapes[rune(esc)]) or_return
		return start + 1, nil
	case '0' ..= '7':
		// Octal escape
		// Parse up to 3 octal digits
		value := u8(esc - '0')
		i := start + 1
		for count := 0; count < 2 && i < len(s); count += 1 {
			next := s[i]
			if next < '0' || next > '7' {break}
			value = value * 8 + u8(next - '0')
			i += 1
		}

		os.write_byte(writer^, value) or_return
		return i, nil
	case 'x':
		// Hex escape
		i := start + 1
		if i >= len(s) {
			// No digits - write literal \x
			os.write_byte(writer^, '\\') or_return
			os.write_byte(writer^, 'x') or_return
			return i, nil
		}

		// Parse first hex digit
		digit := s[i]
		if !is_hex_digit(digit) {
			os.write_byte(writer^, '\\') or_return
			os.write_byte(writer^, 'x') or_return
			os.write_byte(writer^, digit) or_return
			return i + 1, nil
		}
		value := hex_value(digit)
		i += 1 // Past first digit

		if i < len(s) && is_hex_digit(s[i]) {
			value = value * 16 + hex_value(s[i])
			i += 1 // Past second digit
		}

		os.write_byte(writer^, value) or_return
		return i, nil
	case:
		// Unknown escape - write \ + esc
		os.write_byte(writer^, '\\') or_return
		os.write_byte(writer^, esc) or_return
		return start + 1, nil
	}
}

is_hex_digit :: proc(c: byte) -> bool {
	return (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')
}

hex_value :: proc(c: byte) -> u8 {
	if c >= '0' && c <= '9' {return c - '0'}
	if c >= 'a' && c <= 'f' {return c - 'a' + 10}
	return c - 'A' + 10
}
