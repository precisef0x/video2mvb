# video2mvb: Video to MVB Converter
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/git/git-scm.com/blob/main/MIT-LICENSE.txt)

## Overview

`video2mvb` is a command-line tool that converts standard video files into the custom MVB (Micro Video Binary) format. The simplicity of this format makes it suitable for performance-constrained systems such as microcontrollers, like the ESP32. The tool relies on AVFoundation for video reading and prioritizes both performance and ease-of-use.

## Features

- Support for multiple video file formats through FFmpeg
- Customization of chunk dimensions, frame size, and FPS settings
- Option to skip frames for space-saving purposes
- Outputs a compressed binary file ready for decoding across various platforms

## Prerequisites

- macOS
- Swift 5.x
- FFmpeg v4.0+ (Verify by running `ffmpeg -version` in the terminal)

## Installation

```bash
git clone https://github.com/precisef0x/video2mvb.git
```

Navigate to the project directory and build:

```bash
cd video2mvb
swift build -c release
```

## Usage

This project uses the Swift ArgumentParser library to parse command-line options. The syntax is quite intuitive. Below are some examples. Run the following command for basic conversion:

```bash
video2mvb --input /path/to/input.mp4 --output /path/to/output.mvb
```

### Options
|  Option    | Description                                    | Default      |
|  --------  | ---------------------------------------------- | ------------ |
| `--input`  | Path to the input video file                   |              |
| `--output` | Path to the output MVB file                    |              |
| `--cs`     | Chunk size (dimension of a square chunk)       |  40 pixels   |
| `--width`  | Target frame width                             |  160 pixels  |
| `--height` | Target frame height                            |  80 pixels   |
| `--fps`    | Target frames per second                       |  15          |
| `--skip`   | Skip every (1 + skip)-th frame                 |  0           |

### Examples

To convert a video with default settings:

```bash
video2mvb --input example.mp4 --output example.mvb
```

To convert a video with custom parameters:

```bash
video2mvb -i example.mp4 -o example.mvb --cs 32 --width 128 --height 128 --fps 20
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with :heart: by  [precisef0x](https://github.com/precisef0x)
