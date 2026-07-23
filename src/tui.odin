package src

import "core:strings"
import "core:os"
import "core:fmt"

draw :: proc (
        fis: []os.File_Info, 
        selected: int, checked: 
        []bool, 
        playlist_name: string,
        finished: bool,
    ) {
    fmt.print("\e[2J\e[H")
    fmt.printfln("Playlist: %s", playlist_name)
    fmt.println("Space: select • Enter: capture • q: quit")
    fmt.println("-----------------------------")
    if finished {
        return
    } 
    for fi, i in fis {
        marker := " "
        if i == selected {
            marker = ">"
        }

        check := " "
        if checked[i] {
            check = "x"
        }

        if fi.type == .Directory {
            fmt.printfln("%s [%s] %s/", marker, check, fi.name)
        } else {
            fmt.printfln("%s [%s] %s (%M)", marker, check, fi.name, fi.size)
        }
    }
}   


Key :: enum {
    None,
    Up,
    Down,
    Left,
    Right,
    Quit,
    Enter,
    Space,
    Open,
}

read_byte :: proc() -> u8 {
    buffer: [1]u8
    n, err := os.read(os.stdin, buffer[:])
    
    if err != nil || n != 1 {
        return 0
    }

    return buffer[0]
}

read_key :: proc() -> Key {
    first := read_byte()
    
    switch first {
        case 'q': return .Quit
        case 'e': return .Enter
        case ' ': return .Space
        case '\r', '\n': return .Open
    }

    if first != 0x1b {return .None}
    if read_byte() != '[' {return .None}

    switch  read_byte() {
        case 'A': return .Up
        case 'B': return .Down
        case 'C': return .Right
        case 'D': return .Left   
    }
    
    return .None
}



get_playlist_name :: proc() -> string {
    fmt.print("Playlist name: ")

    buffer: [256]u8
    n, err := os.read(os.stdin, buffer[:])

    if err != nil || n == 0 {
        return strings.clone("Untitled Playlist")
    }

    line := string(buffer[:n])

    // Remove Enter's newline characters.
    for len(line) > 0 && (line[len(line)-1] == '\n' || line[len(line)-1] == '\r') {
        line = line[:len(line)-1]
    }

    if len(line) == 0 {
        line = "Untitled Playlist"
    }

    name, clone_err := strings.clone(line)
    if clone_err != nil {
        return "Untitled Playlist"
    }

    return name
}