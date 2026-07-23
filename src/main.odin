package src

import "core:fmt"
import "core:os"

main :: proc() {
    playlist_name := get_playlist_name()
    defer delete(playlist_name)

    terminal: Raw_Terminal
    if !enable_raw_mode(&terminal) {
        fmt.eprintln("Could not enable raw terminal mode")
        return
    }
    defer disable_raw_mode(&terminal)

    cwd_ := get_cwd()
    defer delete(cwd_)
    
    selected := 0
    finished := false

    fis := read_dir(cwd_)
    defer os.file_info_slice_delete(fis, context.allocator)
    
    checked := make([]bool, len(fis))
    defer delete(checked)
    
    selected_albums: [dynamic]string
    defer delete(selected_albums)

    selected_songs: [dynamic]string
    defer delete(selected_songs)

    for {
        draw(fis, selected, checked, playlist_name, finished)

        switch read_key() {
            case.Up:
                if selected > 0 {
                    selected -=1
                }
            case .Down:
                if selected < len (fis)-1 {
                    selected += 1
                }
            case .Quit:
                return
            case .None: break
            case .Left: break
            case .Right: break
            case .Enter: break
            case .Space: 
                if len (fis) > 0 {
                    checked[selected] = !checked[selected]
                }
            case .Open: 
                finished = true

                for fi, i in fis {
                    if !checked[i] do continue
                    if fi.type == .Directory {
                        append(&selected_albums, fi.name)
                    } else {
                        append(&selected_songs, fi.name)
                    }
                }

                fmt.print("\e[2J\e[H")
                fmt.printfln("Packaging playlist :%s...", playlist_name)
                package_(selected_albums[:], selected_songs[:], playlist_name)
                return
        }
    }
}