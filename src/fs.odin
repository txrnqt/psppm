package src

import "core:os"
import "core:fmt"
import "core:strings"

read_dir :: proc(cwd: string) -> []os.File_Info {
    f, open_err := os.open(cwd)
    if open_err != nil {
        fmt.eprintfln("could not open dir for reasding: %v", open_err)
        os.exit(1)
    }
    defer os.close(f)

    fis: []os.File_Info
    read_err: os.Error
    fis, read_err = os.read_dir(f, -1, context.allocator)
    if read_err != nil {
        fmt.eprintfln("Could not read directory: %v", read_err)
        os.exit(2)
    }

    return fis
}

get_cwd :: proc() -> string {
    cwd, wd_err := os.get_working_directory(context.allocator)
    if wd_err != nil {
        fmt.eprintfln("no wd : %v", wd_err)
        os.exit(1)
    }
    return cwd
}

package_ :: proc(selected_albums: []string, selected_songs: []string, playlist_name: string) -> bool {
    cwd_ := get_cwd()
    fis := read_dir(cwd_)

    fis_pspp := make([dynamic]string, 0)
    defer delete(fis_pspp)

    // Top-level songs: only the ones the user checked.
    for fi in fis {
        if fi.type == .Directory do continue
        for song in selected_songs {
            if fi.name == song {
                path_ := fmt.tprintf("PSP\\MUSIC\\%s.mp3", fi.name)
                append(&fis_pspp, path_)
                break
            }
        }
    }

    for fi in fis {
        if fi.type != .Directory do continue

        is_selected := false
        for album in selected_albums {
            if fi.name == album {
                is_selected = true
                break
            }
        }
        if !is_selected do continue

        dir_fis := read_dir(fi.fullpath)
        defer os.file_info_slice_delete(dir_fis, context.allocator)
        for track in dir_fis {
            if track.type == .Directory do continue
            path_ := fmt.tprintf("PSP\\MUSIC\\%s\\%s.mp3", fi.name, track.name)
            append(&fis_pspp, path_)
        }
    }

    builder := strings.builder_make()
    defer strings.builder_destroy(&builder)
    for path in fis_pspp {
        strings.write_string(&builder, path)
        strings.write_byte(&builder, '\n')
    }

    playlist := strings.to_string(builder)
    name := fmt.tprintf("%s.m3u", playlist_name)
    write_err := os.write_entire_file(
        name,
        transmute([]byte)playlist,
    )

    if write_err != nil {
        fmt.eprintln("Failed to write playlist")
        return false
    }

    fmt.printfln("%s has been packaged", playlist_name)
    fmt.println("assume all songs and albums are in MUSIC folder on psp")
    return true
}