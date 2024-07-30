#!/bin/bash

docker run --rm -it -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus -v /dev:/dev -v /sys:/sys \
    --network host \
    --device /dev/video0 --device /dev/video1 --device /dev/video2 \
    --device-cgroup-rule='c 226:* rmw' --device-cgroup-rule='c 199:* rmw' \
    pmliquify/torizon-v4l2-test