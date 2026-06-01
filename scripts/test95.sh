#!/bin/bash


usage() {
    echo "Usage: $0 [options]                                                     "
    echo "                                                                        "
    echo "Test and demo script for i.MX95 camera development.                     "
    echo "                                                                        "
    echo "Supported actions:                                                      "
    echo " run <w> <h> <f> <n>      Starts an image stream                        "
    echo "                                                                        "
    echo "Supported action parameters:                                            "
    echo "  <w> <h>                 Image width and height                        "
    echo "  <f>                     Pixelformat [GREY, Y10, Y12, Y14,             "
    echo "                          RGGB, RG10, RG12, GBRG, GB10, GB12]           "
    echo "  <n>                     Number of images to capture                   "
    echo "                                                                        "
    echo "Supported options:                                                      "
    echo " -bl,     --black_level     Sets black level in m%           [0-100000] "
    echo " -c,      --camera          Set devices by auto detection         [0-1] "
    echo " -dbgcam, --debug-cam       Enables csi debug massages            [0-6] "
    echo " -e,      --exposure        Sets camera exposure time in us [0-1000000] "
    echo " -fr,     --frame-rate      Sets camera frame rate in mHz   [0-1000000] "
    echo " -g,      --gain            Sets camera gain in mdB          [0-100000] "
    echo "          --help            Show this help text                         "
    echo " -h       --host            Sets hostname or address to send images to  "
    echo " -i,      --io-mode         Sets camera io mode                   [0-5] "
    echo " -l,      --lanes           Sets number of lanes     [0:1L, 1:2L, 2:4L] "
    echo " -p,      --port            Sets host port number        [default 9000] "
    echo " -st,     --single-trigger  Sets camera single trigger                  "
    echo "          --shift           Sets bitshift of each pixel value     [0-8] "
    echo " -t,      --trigger         Sets camera trigger mode              [0-7] "
}

media0=/dev/media0
camera=0
device=
csidev=
camdev=
host=
port=9000
bitshift=0

#------------------------------------------------------------------------------
# Helper functions

v4l2_test() {
    if [[ -n ${host} ]]; then
        v4l2-test -d ${device} -sd ${camdev} client -p 1 --ip ${host} --port ${port} --shift ${bitshift} -n ${1}
    else
        v4l2-test -d ${device} -sd ${camdev} stream -p 1 --shift ${bitshift} -n ${1}
    fi
}

check_arguments_count() {
    if [[ ${1} != ${2} ]]; then
        echo "Please give ${2} argument(s) ${3}. (Use --help for more details)"
        exit 1
    fi
}

check_devices() {
    if [[ -z ${device} || -z ${csidev} || -z ${camdev} ]]; then
        set_camera 0
    fi
}

fcc_from_pixelformat() {
    local fcc=
    case ${1} in
    'GREY') fcc=Y8_1X8 ;;
    'Y10 ') fcc=Y10_1X10 ;;
    'Y12 ') fcc=Y12_1X12 ;;
    'Y14 ') fcc=Y14_1X14 ;;
    'RGGB') fcc=SRGGB8_1X8 ;;
    'RG10') fcc=SRGGB10_1X10 ;;
    'RG12') fcc=SRGGB12_1X12 ;;
    'GBRG') fcc=SGBRG8_1X8 ;;
    'GB10') fcc=SGBRG10_1X10 ;;
    'GB12') fcc=SGBRG12_1X12 ;;
    *) echo "Pixelformat not supported!"; exit 1
    esac
    echo ${fcc}
}

setup_pipeline() {
    local fcc=$(fcc_from_pixelformat "${3}")
    local fmt="${fcc}/${1}x${2}"

    # Routes stream 0 from pad 2 (CAM0) to pad 5 and pad 3 (CAM1) to pad 6 
    # of the crossbar.
    media-ctl -d ${media0} -R '"crossbar"[2/0 -> 5/0 [1], 3/0 -> 6/0 [1]]'

    if [[ ${camera} -eq 0 ]]; then
        # Links pad 0 (CAM0) of the sensor to pad 0 of the CSI0 device.
        media-ctl -d ${media0} -l "'vc-mipi-cam 2-001a':0 -> 'csidev-4ad30000.csi':0 [1]"
        # Configures V4L2 format for CAM0 pipeline
        media-ctl -d ${media0} --set-v4l2 "'csidev-4ad30000.csi':0 [fmt:${fmt} field:none]"
        media-ctl -d ${media0} --set-v4l2 "'csidev-4ad30000.csi':1 [fmt:${fmt} field:none]"
        media-ctl -d ${media0} --set-v4l2 "'4ac10000.syscon:formatter@20':0 [fmt:${fmt} field:none]"
        media-ctl -d ${media0} --set-v4l2 "'4ac10000.syscon:formatter@20':1 [fmt:${fmt} field:none]"
        media-ctl -d ${media0} --set-v4l2 "'crossbar':2 [fmt:${fmt} field:none]"
        media-ctl -d ${media0} --set-v4l2 "'mxc_isi.0':0 [fmt:${fmt} field:none]"
        media-ctl -d ${media0} --set-v4l2 "'vc-mipi-cam 2-001a':0 [fmt:${fmt} field:none]"
    
    else
        # Links pad 0 (CAM1) of the sensor to pad 0 of the CSI1 device.
        media-ctl -d ${media0} -l "'vc-mipi-cam 7-001a':0 -> 'csidev-4ad40000.csi':0 [1]"
        # Configures V4L2 format for CAM1 pipeline
        media-ctl -d ${media0} --set-v4l2 "'csidev-4ad40000.csi':0 [fmt:${fmt} field:none]"
        media-ctl -d ${media0} --set-v4l2 "'csidev-4ad40000.csi':1 [fmt:${fmt} field:none]"
        media-ctl -d ${media0} --set-v4l2 "'4ac10000.syscon:formatter@120':0 [fmt:${fmt} field:none]"
        media-ctl -d ${media0} --set-v4l2 "'4ac10000.syscon:formatter@120':1 [fmt:${fmt} field:none]"
        media-ctl -d ${media0} --set-v4l2 "'crossbar':3 [fmt:${fmt} field:none]"
        media-ctl -d ${media0} --set-v4l2 "'mxc_isi.1':0 [fmt:${fmt} field:none]"
        media-ctl -d ${media0} --set-v4l2 "'vc-mipi-cam 7-001a':0 [fmt:${fmt} field:none]"
    fi

    v4l2-ctl -d ${device} --set-fmt-video=width=${1},height=${2},pixelformat="${3}"
}

#------------------------------------------------------------------------------
# Main functions

set_debug_cam() {
    check_arguments_count $# 1 "<debug_level>"
    dmesg -n 8
    echo ${1} > /sys/module/vc_mipi/parameters/debug
}

set_camera() {
    check_arguments_count $# 1 "<camera>"
    camera=${1}
    if [[ ${camera} -eq 0 ]]; then
        device=/dev/video0
        csidev=/dev/v4l-subdev10
        camdev=/dev/v4l-subdev11
    else
        device=/dev/video1
        csidev=/dev/v4l-subdev13
        camdev=/dev/v4l-subdev14
    fi
    echo "CAM${camera}: device=${device}, csidev=${csidev}, camdev=${camdev}"
}

set_host() {
    check_arguments_count $# 1 "<host_name> or <host_address>"
    host=${1}
}

set_port() {
    check_arguments_count $# 1 "<host_port>"
    port=${1}
}

set_bitshift() {
    check_arguments_count $# 1 "<num_bits>"
    bitshift=${1}
}

set_lanes() {
    check_arguments_count $# 1 "<num_lanes>"
    check_devices
    v4l2-ctl -d ${csidev} -c csi_lanes=${1}
    v4l2-ctl -d ${camdev} -c csi_lanes=${1}
}

set_cam_black_level() {
    check_arguments_count $# 1 "<black_level>"
    check_devices
    v4l2-ctl -d ${camdev} -c black_level=${1}
}

set_cam_exposure() {
    check_arguments_count $# 1 "<exposure> us"
    check_devices
    v4l2-ctl -d ${camdev} -c exposure=${1}
}

set_cam_gain() {
    check_arguments_count $# 1 "<gain> mdB"
    check_devices
    v4l2-ctl -d ${camdev} -c gain=${1}
}

set_cam_trigger_mode() {
    check_arguments_count $# 1 "<trigger_mode>"
    check_devices
    v4l2-ctl -d ${camdev} -c trigger_mode=${1}
}

set_cam_io_mode() {
    check_arguments_count $# 1 "<io_mode>"
    check_devices
    v4l2-ctl -d ${camdev} -c io_mode=${1}
}

set_cam_frame_rate() {
    check_arguments_count $# 1 "<frame_rate>"
    check_devices
    v4l2-ctl -d ${camdev} -c frame_rate=${1}
}

set_cam_single_trigger() {
    check_arguments_count $# 0
    check_devices
    v4l2-ctl -d ${camdev} -c single_trigger=${1}
}

run() {
    check_arguments_count $# 4 "<w> <h> <f> <n>"
    check_devices
    setup_pipeline ${1} ${2} "${3}"
    v4l2_test ${4}
}

while [ $# != 0 ] ; do
    option=${1}
    shift

    case ${option} in
    -bl|--black_level)
        set_cam_black_level ${1}
        shift
        ;;
    -c|--camera)
        set_camera ${1}
        shift
        ;;
    -dbgcam|--debug-cam)
        set_debug_cam ${1}
        shift
        ;;
    -e|--exposure)
        set_cam_exposure ${1}
        shift
        ;;
    -fr|--frame-rate)
        set_cam_frame_rate ${1}
        shift
        ;;
    -g|--gain)
        set_cam_gain ${1}
        shift
        ;;
    --help)
        usage
        exit 0
        ;;
    -h|--host)
        set_host ${1}
        shift
        ;;
    -i|--io-mode)
        set_cam_io_mode ${1}
        shift
        ;;
    -l|--lanes)
        set_lanes ${1}
        shift
        ;;
    -p|--port)
        set_port ${1}
        shift
        ;;
    run)
        run ${1} ${2} "${3}" ${4}
        shift; shift; shift; shift
        ;;
    -st|--single-trigger)
        set_cam_single_trigger
        ;;
    --shift)
        set_bitshift ${1}
        shift
        ;;
    -t|--trigger)
        set_cam_trigger_mode ${1}
        shift
        ;;
    x)
        source test.cfg
        ;;
    *)
        echo "Unknown option: ${option}"
        exit 1
        ;;
    esac
done
