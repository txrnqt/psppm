package src

import psx "core:sys/posix"

Raw_Terminal :: struct {
    original: psx.termios,
}

enable_raw_mode :: proc(terminal: ^Raw_Terminal) -> bool {
    if psx.tcgetattr(psx.STDIN_FILENO, &terminal.original) != .OK {
        return false
    }

    raw := terminal.original
    raw.c_lflag -= {.ECHO, .ICANON}

    return psx.tcsetattr(psx.STDIN_FILENO, .TCSANOW, &raw) == .OK
}

disable_raw_mode :: proc(terminal: ^Raw_Terminal) {
    _ = psx.tcsetattr(psx.STDIN_FILENO, .TCSANOW, &terminal.original)
}