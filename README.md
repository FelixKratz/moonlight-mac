# moonlight-mac
Moonlight Client for macOS 10.13+ w/ HEVC support

Moonlight-mac is an open source implementation of the NVIDIA Streaming Protocol for macOS and is based on [moonlight-ios](https://github.com/moonlight-stream/moonlight-ios). 

A modified version of this project has been merged into moonlight-ios.
Since I can modify this version without taking care of the ios version, this repository will see more changes and will be maintained more actively. I will also provide the latest realeases here.

macOS supports native HEVC playback as of version 10.13, since the moonlight-chrome client lacks this feature I implemented it in a standalone, native macOS-Client. In addition to the HEVC support I hope to archive performance and latency improvements.

Status: early development, but already working

## Requirements
* At least a Kepler series GPU for the host PC.
* Fast wireless or wired connection.
* Streaming remotely requires the ports: TCP: 47984, 47989, 48010 ;UDP: 47998, 47999, 48000, 48002, 48010 to be forwarded to the host pc.

## Usage
Configure the host pc, connect, done.

The stream statistics overlay can be toggled with the key combo (CMD + I).

The stream can be quit with (ALT + ESC) to get back to the configuration or with (CMD + Q) to quit the application.

Have fun & report your issues.
