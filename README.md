
# video2mvb: Video to MVB Converter
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/precisef0x/video2mvb/blob/main/LICENSE)

## Overview

`video2mvb` is a command-line tool that converts standard video files into the custom MVB (Micro Video Binary) format. The simplicity of this format makes it suitable for performance-constrained systems such as microcontrollers, like the ESP32. The tool relies on AVFoundation for video reading and prioritizes both performance and ease-of-use.

## Features

- Support for multiple video file formats through FFmpeg
- Customization of chunk dimensions, frame size, and FPS settings
- Option to skip frames for space-saving purposes
- Outputs a compressed binary file ready for decoding across various platforms

## MVB Format Description

### File Structure

The MVB (Micro Video Binary) file is a custom format designed for video storage and playback. This section explains the structure and specifications of the MVB file format.

The key idea behind the encoding process is to divide each frame into square chunks. Each chunk from the current frame is then compared to its counterpart in the previous frame, and only the chunks that have changed are saved.

---

### Header Structure

The binary file starts with a 16-byte header, organized as follows:

- **[4 bytes] - Magic Number**: A unique signature, `0x2e4d5642`, is used to validate that the correct file type is being decoded.
- **[2 bytes] - Frames Count**: This UInt16 little-endian value indicates the total number of frames present in the video.
- **[2 bytes] - Chunk Dimension**: Specifies the dimension of each square chunk as a UInt16 little-endian value.
- **[2 bytes] - Frame Width**: Specifies the width of each frame as a UInt16 little-endian value.
- **[2 bytes] - Frame Height**: Specifies the height of each frame as a UInt16 little-endian value.
- **[2 bytes] - Target FPS**: A UInt16 little-endian value representing the target frames-per-second rate.
- **[2 bytes] - Skip Frames**: A UInt16 little-endian value indicating the number of frames to skip during encoding.

### Frame Chunks

Right after the header, the file contains a sequence of frame chunks. Each frame chunk starts with:

- **[2 bytes] - Chunk Data Size**: A UInt16 little-endian value indicating the size of the compressed data for that frame's chunks. This data immediately follows the size value. Zlib is used in a "no header" mode to compress the frame data. If no chunks have changed relative to the previous frame, this entire frame chunk comprises just a 2-byte value set to zero.

### Chunk Data

Each chunk within the frame data sequence includes:

- **[1 byte] - X Position**: A UInt8 value indicating the x-coordinate of the chunk.
- **[1 byte] - Y Position**: A UInt8 value indicating the y-coordinate of the chunk.
- **[chunkSize * chunkSize * 2 bytes] - Pixels Data**: This is a sequence of 2-byte RGB565 values, each representing a pixel in the chunk. The pixel data is organized in row-major order.

## Prerequisites

- macOS 11.0+
- Swift 5.x
- FFmpeg v4.0+ installed (e.g., available through Homebrew)

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
| `--skip`   | Skip every (1 + N)-th frame                    |  0           |

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

This project is licensed under the MIT License - see the [`LICENSE`](https://github.com/precisef0x/video2mvb/blob/main/LICENSE) file for details.

---

Made with :heart: by  [precisef0x](https://github.com/precisef0x)
