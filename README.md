# psppm

A terminal UI tool for building `.m3u` playlists for the PSP's `MUSIC` folder. Point it at a directory of songs and albums, select what you want with the keyboard, and it packages a playlist file referencing them under `PSP\MUSIC\`.

Written in [Odin](https://odin-lang.org/).

## Features

- Select individual songs and whole album folders with checkboxes
- Packages selections into a `.m3u` playlist formatted for the PSP's music folder
- No external dependencies beyond the Odin `core` library

## Requirements

- [Odin compiler](https://odin-lang.org/docs/install/) installed and on your `PATH`

## Building

```sh
odin build src -out:psppm
```

## Usage

Run it from the directory containing your songs and album folders:

```sh
./psppm
```

You'll first be prompted for a playlist name, then dropped into the file browser.

### Controls

| Key            | Action                          |
| -------------- | -------------------------------- |
| `↑` / `↓`      | Move selection up / down         |
| `Space`        | Check / uncheck the current item |
| `Enter`        | Package the playlist and exit    |
| `q`            | Quit without packaging           |

Checked items can be either individual song files or album directories. Checking an album includes every track inside it.

## How it works

1. Reads the current working directory and lists files and subdirectories.
2. Tracks which entries you've checked.
3. On packaging, splits your selection into standalone songs and albums:
   - Standalone songs are added directly as `PSP\MUSIC\<song>`.
   - For checked albums, every track inside the folder is added as `PSP\MUSIC\<album>\<track>`.
4. Writes the result to `<playlist_name>.m3u` in the current directory.

> Playlists assume your songs and albums already live under the PSP's `MUSIC` folder with the same names/structure used here.


## License

Add a license here (e.g. MIT) if you plan to share or open-source this project.
