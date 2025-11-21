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
		i += 1
		if i >= len(s) {
			// Trailing backslash: treat as literal
			os.write_byte(writer^, '\\') or_return
			break
		}

		esc := s[i]
		switch esc {
		case 'a':
			// Bell/alert
			os.write_byte(writer^, '\a') or_return
		case 'b':
			// Backspace
			os.write_byte(writer^, '\b') or_return
		case 'f':
			// Form feed
			os.write_byte(writer^, '\f') or_return
		case 'n':
			// Newline
			os.write_byte(writer^, '\n') or_return
		case 'r':
			// Carriage return
			os.write_byte(writer^, '\r') or_return
		case 't':
			// Horizontal tab
			os.write_byte(writer^, '\t') or_return
		case 'v':
			// Vertical tab
			os.write_byte(writer^, '\v') or_return
		case '\\':
			// Literal backslash
			os.write_byte(writer^, '\\') or_return
		case '0' ..= '7':
			// Octal escape
			// Parse up to 3 octal digits
			value := u8(esc - '0')
			i += 1
			for count := 0; count < 2 && i < len(s); count += 1 {
				next := s[i]
				if next < '0' || next > '7' {break}
				value = value * 8 + u8(next - '0')
			}

			// i is already advanced past the last digit - loop will increment, so decrement it
			i -= 1
			os.write_byte(writer^, value)
		case 'x':
			// Hex escape
			i += 1
			if i >= len(s) {
				os.write_byte(writer^, '\\') or_return
				os.write_byte(writer^, 'x') or_return
				continue
			}

			// Parse first hex digit
			digit := s[i]
			if !is_hex_digit(digit) {
				os.write_byte(writer^, '\\') or_return
				os.write_byte(writer^, 'x') or_return
				os.write_byte(writer^, digit) or_return
				continue
			}
			value := hex_value(digit)

			i += 1
			if i < len(s) && is_hex_digit(s[i]) {
				value = value * 16 + hex_value(s[i])
				i += 1
			}

			// i is already past the last hex digit, decrement to counteract for-loop +1
			i -= 1
			os.write_byte(writer^, value) or_return
		case:
			// Unknown escape
			os.write_byte(writer^, '\\') or_return
			os.write_byte(writer^, esc) or_return
		}
		i += 1
	}
	return nil
}

is_hex_digit :: proc(c: byte) -> bool {
	return (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')
}

hex_value :: proc(c: byte) -> u8 {
	if c >= '0' && c <= '0' {return c - '0'}
	if c >= 'a' && c <= 'f' {return c - 'a' + 10}
	return c - 'A' + 10
}
