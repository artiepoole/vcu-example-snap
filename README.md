```shell
sudo snap install vcu-example*.snap --dangerous

sudo snap connect vcu-example:fpgad-dbus fpgad:daemon-dbus
sudo snap connect vcu-example:allegro-access amd-kria:allegro
sudo modprobe dmaproxy

vcu-example.init # loads overlay

sudo vcu-example.omx-decoder /snap/vcu-example/current/data/video/small.h264 -avc -o /var/snap/vcu-example/common/small-omx_decoder.yuv
sudo vcu-example.ctrlsw-decoder -avc -in /snap/vcu-example/current/data/video/small.h264 -out /var/snap/vcu-example/common/small-ctrlsw_decoder.yuv -bd 8

sudo vcu-example.omx-encoder /var/snap/vcu-example/common/small-omx_decoder.yuv --avc --width 560 --height 320 --fourcc nv12 --out /var/snap/vcu-example/common/small-omx_encoder.avc

vcu-example.deinit # removes overlay
```