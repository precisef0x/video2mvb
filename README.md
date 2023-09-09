
# video2mvb: Video to MVB Converter
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/precisef0x/video2mvb/blob/main/LICENSE)

## Overview

`video2mvb` is a command-line tool that converts standard video files into the custom MVB (Micro Video Binary) format. The simplicity of this format makes it suitable for performance-constrained systems such as microcontrollers, like the ESP32. The tool relies on AVFoundation for video reading and prioritizes both performance and ease-of-use.

## Features

- Support for multiple video file formats through FFmpeg
- Customization of chunk dimensions, frame size, and FPS settings
- Option to skip frames for space-saving purposes
- Outputs a compressed binary file ready for decoding across various platforms

## Prerequisites

- macOS 11.0+
- Swift 5.x
- FFmpeg 4.0+ installed (e.g., available through Homebrew)

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
| `--input`  | Path to the input video file                   |  -           |
| `--output` | Path to the output MVB file                    |  -           |
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

# MVB Format Structure

The MVB (Micro Video Binary) file is a custom format designed for video storage and playback. This section explains the structure and specifications of the MVB file format.

The key idea behind the encoding process is to divide each frame into square chunks. Each chunk from the current frame is then compared to its counterpart in the previous frame, and only the chunks that have changed are saved.

## Header section

The MVB file starts with a header that's 16 bytes long. All these parameters are stored as little-endian values.

| Field          | Size (bytes) |  Type  | Description                                                     |
|----------------|--------------|--------|-----------------------------------------------------------------|
| Magic Number   |  4           | UInt32 | Unique signature: `0x2e4d5642`, used to validate the file type. |
| Frames Count   |  2           | UInt16 | Total number of frames in the video.                            |
| Chunk Dimension|  2           | UInt16 | Dimension of each square chunk.                                 |
| Frame Width    |  2           | UInt16 | Width of a video frame.                                         |
| Frame Height   |  2           | UInt16 | Height of a video frame.                                        |
| Target FPS     |  2           | UInt16 | Target frames per second rate.                                  |
| Skip Frames    |  2           | UInt16 | Number of frames to skip during encoding.                       |


## Data Section

Right after the header comes the Data Section. This section is composed of a sequence of Frame Containers, each containing information for a single frame, laid out one after another. Below is a detailed description of its structure and components:

### Frame Container

A Frame Container starts with a 2-byte UInt16 little-endian value representing the size in bytes of the compressed data that follows.

| Field                | Size (bytes)               | Type   | Description                                                                         |
|----------------------|----------------------------|--------|-------------------------------------------------------------------------------------|
| Frame Data Size      | 2                          | UInt16 | Size in bytes of the compressed data for that frame container. Stored as little-endian. |
| Compressed Frame Data| Variable (Defined by Size) | Bytes  | Zlib-compressed data containing individual Chunks.                                  |

**Note:**  
- If no chunks have changed relative to the previous frame, the Frame Data Size value is zero, and the total length of the Frame Container is just 2 bytes.
- Zlib is used in "no header" mode with `wbits` set to -15 for compression.

### Chunk

After decompressing the Frame Data, it consists of a sequence of Chunks:

| Field           | Size (bytes)                  | Type  | Description                     |
|-----------------|-------------------------------|-------|---------------------------------|
| X Position      | 1                             | UInt8 | X-coordinate of the chunk.      |
| Y Position      | 1                             | UInt8 | Y-coordinate of the chunk.      |
| Pixels Data     | Pixels count * Color depth    | Bytes | Fixed-size pixels data.         |

**Note:**
- The size of each Pixels Data region is equal to  `chunkSize * chunkSize * 2` for RGB565.
- Pixel data within each Chunk is organized in row-major order.

## The Actual Encoding Process

This section describes how video frames get converted and stored in the MVB format.

### Steps
| # |     Step      |      Description     |
|---|---------------|----------------------|
| 1 | Initialization | Video properties like frame dimensions, chunk dimensions, FPS, etc., should be predetermined and will be stored in the header. |
| 2 | Frame Preparation | The video frames are divided into square chunks based on predetermined chunk dimensions. |
| 3 | Frame Comparison | For each frame, its chunks are compared with those of the previous frame. Only chunks that have changed are processed further. |
| 4 | Data Compression | Changed chunks are then compressed using Zlib in "no header" mode with wbits set to -15. |
| 5 | Frame Container Creation | A Frame Container is created for each frame. It starts with a Frame Data Size field that describes the size of the compressed data. The compressed data for the chunks that have changed are then stored in the Frame Container under Compressed Frame Data. |
| 6 | Appending to Data Section | Each Frame Container is then sequentially added to the Data Section of the MVB file. |
| 7 | Finalization | Once all frames have been processed, the header is updated with the final count of frames and prepended at the start of the MVB file. |

## License

This project is licensed under the MIT License - see the [`LICENSE`](https://github.com/precisef0x/video2mvb/blob/main/LICENSE) file for details.

---

Made with :heart: by  [precisef0x](https://github.com/precisef0x)
