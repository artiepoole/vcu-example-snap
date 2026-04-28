# vcu-example

A snap demonstrating Video Codec Unit (VCU) functionality on Xilinx ZynqMP KV260 platforms. It packages the Xilinx VCU userspace libraries alongside OMX and ctrlsw encoder/decoder utilities, and manages FPGA overlay loading via [fpgad](https://github.com/canonical/fpgad).

## Requirements

- AMD Kria KV260 (or compatible ZynqMP k26 platform)
- Ubuntu UC24 image (Noble) with the customised vcu component version of the `xilinx-kernel`
- The `fpgad` snap installed and running
- The `amd-kria` snap installed (modified to provided the `allegro` custom device interface)

## Installation

Install the snap locally (it is not yet published to the Snap Store):

```shell
sudo snap install vcu-example*.snap --dangerous
```

### Connect interfaces

The snap requires two interface connections:

- **fpgad-dbus** — allows the snap to communicate with `fpgad` over D-Bus to load/unload the FPGA bitstream overlay
- **allegro-access** — grants access to the Allegro IP custom device nodes needed by the VCU encoder/decoder

```shell
sudo snap connect vcu-example:fpgad-dbus fpgad:daemon-dbus
sudo snap connect vcu-example:allegro-access amd-kria:allegro
```

## Usage

### 1. Load the kernel module

The `dmaproxy` module must be loaded before using the VCU:

```shell
sudo modprobe dmaproxy
```

### 2. Load the FPGA bitstream overlay

```shell
vcu-example.init
```

This applies the `kv260-smartcam` device tree overlay via `fpgad`, making the VCU hardware available. If an overlay is already loaded, the command will report it and exit cleanly.

### 3. Run the decoder/encoder

**Decode H.264 with the ctrlsw decoder:**

```shell
sudo vcu-example.ctrlsw-decoder \
  -avc \
  -in /snap/vcu-example/current/data/video/small.h264 \
  -out /var/snap/vcu-example/common/small-ctrlsw_decoder.yuv \
  -bd 8
```

**Decode H.264 with the OMX decoder:**

```shell
sudo vcu-example.omx-decoder \
  /snap/vcu-example/current/data/video/small.h264 \
  -avc \
  -o /var/snap/vcu-example/common/small-omx_decoder.yuv
```

**Encode YUV back to H.264 with the OMX encoder:**

```shell
sudo vcu-example.omx-encoder \
  /var/snap/vcu-example/common/small-omx_decoder.yuv \
  --avc \
  --width 560 \
  --height 320 \
  --fourcc nv12 \
  --out /var/snap/vcu-example/common/small-omx_encoder.avc
```

### 4. Unload the FPGA bitstream overlay

When finished, remove the overlay to release the hardware:

```shell
vcu-example.deinit
```

## License

This project is licensed under the GNU General Public License v3.0. 
See `LICENSE` for the full text.
The source files contained within the snap have their own licenses. 
These are not explicitly defined here. 
See those source repositories for further details.
