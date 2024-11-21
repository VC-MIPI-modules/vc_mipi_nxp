#!/bin/bash

usage() {
    echo "Usage: $0 [options]                                                     "
    echo "                                                                        "
    echo "Test and demo script for i.MX8M Plus camera development.                "
    echo "                                                                        "
    echo "Supported actions:                                                      "
    echo " fps                      Runs v4l2-ctl --stream-mmap to measure fps    "
    echo " init                     Creates new ISP tuning files and restarts     "
    echo " isi                      Restarts target to activate ISI pipeline      "
    echo " isp                      Restarts target to activate ISP pipeline      "
    echo " jpg <w> <h> <r> <n>      Saves a jpg image                             "
    echo " media                    Creates svg files from media0 and media1      "
    echo " raw <w> <h> <f>          Saves a raw image                             "
    echo " restart                  Restarts imx8-isp service                     "
    echo " rtp <w> <h> <r> <n>      Starts an image stream via RTP                "
    echo " run <w> <h> <f> <n>      Starts an image stream                        "
    echo " setup <w> <h>            Creates new ISP tuning files and restarts     "
    echo "                                                                        "
    echo " test-hmax <min> <max> <w> <h> <n>                                      "
    echo "                          Captures <n> images with hmax values from     "
    echo "                          <min> to <max> and the given size             "
    echo " test-hs-settle <min> <max> <w> <h> <n>                                 "
    echo "                          Captures <n> images with csis-hs-settle from  "
    echo "                          <min> to <max> and the given size             "
    echo " test-cam-width <min> <max> <step> <h> <n>                              "
    echo "                          Sets output image size to <max> width and     "
    echo "                          captures <n> images with camera width from    "
    echo "                          <min> to <max>                                "
    echo " test-isi-width <min> <max> <step> <h> <n>                              "
    echo "                          Captures <n> images with output and camera    "
    echo "                          image width from <min> to <max>               "
    echo " test-isp-width <min> <max> <step> <h> <n>                              "
    echo "                          Captures <n> images with output and camera    "
    echo "                          image width from <min> to <max>               "
    echo "                          For each width the isp tuning file is         "
    echo "                          changed and the imx8-isp service restared     "
    echo " test-live-roi <b1> <l1> <t1> <b2> <l2> <t2>                            "
    echo "                          Switches between two roi states               "
    echo "                                                                        "
    echo "Supported action parameters:                                            "
    echo "  <w> <h>                 Image width and height                        "
    echo "  <f>                     Pixelformat [GREY, Y10, Y12, Y14,             "
    echo "                          RGGB, RG10, RG12, GBRG, GB10, GB12]           "
    echo "  <r>                     Rotation: 0:0°, 1:90°, 2:180°, 3:270°         "
    echo "  <n>                     Number of images to capture                   "
    echo "  <min> <max> <step>      Test run from min to max with stepsize        "
    echo "                                                                        "
    echo "Supported options:                                                      "
    echo " -b,      --binning         Sets binning mode                     [0-5] "
    echo " -bl,     --black_level     Sets black level in m%           [0-100000] "
    echo " -c,      --camera          Set devices by auto detection         [0-1] "
    echo " -cs,     --clk-settle      Sets csis-clk-settle                  [0-3] "
    echo " -d,      --device          Sets output video device    [/dev/video<x>] "
    echo " -dcsi,   --device-csi      Sets csi subdevice     [/dev/v4l-subdev<x>] "
    echo " -dcam,   --device-cam      Sets cam subdevice     [/dev/v4l-subdev<x>] "
    echo " -dbgcam, --debug-cam       Enables csi debug massages            [0-6] "
    echo " -dbgcsi, --debug-csi       Enables csi debug massages            [0-3] "
    echo " -dbgisi, --debug-isi       Enables isi debug massages            [0-3] "
    echo " -dbgisp, --debug-isp       Enables isp debug massages            [0-3] "
    echo " -dbggst, --debug-gst       Enables GStreamer debug massages      [0-9] "
    echo " -e,      --exposure        Sets camera exposure time in us [0-1000000] "
    echo " -f,      --format          Sets output pixelformat                     "
    echo " -fc,     --format-cam      Sets camera pixelformat                     "
    echo " -fr,     --frame-rate      Sets camera frame rate in mHz   [0-1000000] "
    echo " -g,      --gain            Sets camera gain in mdB          [0-100000] "
    echo "          --help            Show this help text                         "
    echo " -h       --host            Sets hostname or address to send images to  "
    echo " -ho      --height-offset   Sets height offset                          "
    echo " -hs,     --hs-settle       Sets csis-hs-settle                  [1-40] "
    echo " -i,      --io-mode         Sets camera io mode                   [0-5] "
    echo " -l,      --lanes           Sets number of lanes     [0:1L, 1:2L, 2:4L] "
    echo " -p,      --port            Sets host port number        [default 9000] "
    echo " -r,      --roi             Sets output image roi     [<l> <t> <w> <h>] "
    echo " -rc,     --roi-cam         Sets camera image roi     [<l> <t> <w> <h>] "
    echo " -s,      --size            Sets output image size            [<w> <h>] "
    echo " -sc,     --size-cam        Sets camera image size            [<w> <h>] "
    echo " -st,     --single-trigger  Sets camera single trigger                  "
    echo "          --shift           Sets bitshift of each pixel value     [0-8] "
    echo " -t,      --trigger         Sets camera trigger mode              [0-7] "
}

media0=/dev/media0
media1=/dev/media1
camera=
device=
csidev=
camdev=
host=
port=9000
bitshift=0
wait_for_service=4

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

get_entity_name() {
    local entities=$(media-ctl -d ${media0} -p | grep -oP "(?<=[0-9]: )vc-mipi-cam [0-9]{1,2}-001a")
    echo "${entities}" | while read -r entity; do
        local subdev=$(media-ctl -d ${media0} -e "${entity}")
        if [[ ${subdev} == ${1} ]]; then
            echo ${entity}
        fi
    done
}

get_entity_fcc() {
    local fcc=$(media-ctl -d ${media0} --get-v4l2 "\"${1}\":0" | grep -oE "fmt:.*/")
    echo ${fcc:4:-1}
}

get_entity_size() {
    local fcc=$(media-ctl -d ${media0} --get-v4l2 "\"${1}\":0" | grep -oE "fmt:.*/[0-9]*x[0-9]*" | \
        grep -oP "(?<=/).*")
    echo ${fcc}
}

#------------------------------------------------------------------------------
# Main functions

set_debug_cam() {
    check_arguments_count $# 1 "<debug_level>"
    dmesg -n 8
    echo ${1} > /sys/module/vc_mipi_vvcam/parameters/debug
}

set_debug_csi() {
    check_arguments_count $# 1 "<debug_level>"
    dmesg -n 8
    echo ${1} > /sys/module/imx8_mipi_csi2_sam/parameters/debug
}

set_debug_isi() {
    check_arguments_count $# 1 "<debug_level>"
    echo ${1} > /sys/module/imx8_isi_capture/parameters/debug
    # echo ${1} > /sys/module/imx8_isi_hw/parameters/debug
}

set_debug_isp() {
    check_arguments_count $# 1 "<debug_level>"
    export ISP_LOG_LEVEL=${1} 
}

set_debug_gst() {
    check_arguments_count $# 1 "<debug_level>"
    # https://gstreamer.freedesktop.org/documentation/tutorials/basic/debugging-tools.html
    export GST_DEBUG=${1} 
}

set_camera() {
    check_arguments_count $# 1 "<camera>"
    camera=${1}
    device=$(media-ctl -d ${media0} -e mxc_isi.${camera}.capture)
    if [[ ! ${device} =~ "/dev/video" ]]; then
        device=$(media-ctl -d ${media1} -e viv_v4l2${camera})
    fi
    csidev=$(media-ctl -d ${media0} -e mxc-mipi-csi2.${camera})
    local entity=$(media-ctl -e mxc-mipi-csi2.${camera} -p | grep -oE "vc-mipi-cam [0-9]{1,2}-001a")
    camdev=$(media-ctl -e "${entity}")
    echo "CAM${camera}: device=${device}, csidev=${csidev}, camdev=${camdev}"
}

set_device() {
    check_arguments_count $# 1 "/dev/video<x>"
    device=/dev/video${1}
}

set_csidev() {
    check_arguments_count $# 1 "/dev/v4l-subdev<x>"
    csidev=/dev/v4l-subdev${1}
}

set_camdev() {
    check_arguments_count $# 1 "/dev/v4l-subdev<x>"
    camdev=/dev/v4l-subdev${1}
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

activate() {
    check_arguments_count $# 2 "isi isp | isp isi"
    sed "s/${1}/${2}/g" -i /boot/overlays.txt
    reboot
}

set_format() {
    check_arguments_count $# 1 "<f>"
    check_devices
    v4l2-ctl -d ${device} --set-fmt-video pixelformat="${1}"
}

set_lanes() {
    check_arguments_count $# 1 "<num_lanes>"
    check_devices
    v4l2-ctl -d ${csidev} -c csi_lanes=${1}
    v4l2-ctl -d ${camdev} -c csi_lanes=${1}
}

set_height_offset() {
    check_arguments_count $# 1 "<height_offset>"
    check_devices
    v4l2-ctl -d ${camdev} -c height_offset=${1}
}

set_csi_hs_settle() {
    check_arguments_count $# 1 "<csi_hs_settle>"
    check_devices
    v4l2-ctl -d ${csidev} -c csi_hs_settle=${1}
}

set_csi_clk_settle() {
    check_arguments_count $# 1 "<csi_clk_settle>"
    check_devices
    v4l2-ctl -d ${csidev} -c csi_clk_settle=${1}
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

set_cam_binning() {
    check_arguments_count $# 1 "<binning_mode>"
    check_devices
    v4l2-ctl -d ${camdev} -c binning_mode=${1} 
}

get_size_in_tuning_file() {
    local path=/opt/imx8-isp/bin
    local tuning_file=$(cat ${path}/Sensor${1}_Entry.cfg | grep -oP "(?<=xml = \").*(?=\")")
    local size=$(cat ${path}/${tuning_file} | grep -oE -m 1 "<resolution.*resolution>" | \
        grep -oP "(?<=>)[0-9]+x[0-9]+(?=<)")
    echo ${size}
}

get_width_from_size() {
    local width=$(echo ${1} | grep -oP "[0-9]+(?=x)")
    echo ${width}
}

get_height_from_size() {
    local height=$(echo ${size} | grep -oP "(?<=x)[0-9]+")
    echo ${height}
}

init_isp() {
    check_arguments_count $# 0
    local ret=$(
        cd /opt/imx8-isp/bin
        ./vc-mipi-setup.sh --force init
        echo $?
    )
    if [[ ${ret} == 1 ]]; then
        exit 1
    fi
    sleep ${wait_for_service}

    set_camera 0
    local size=$(get_size_in_tuning_file ${camera})
    local width=$(get_width_from_size ${size})
    local height=$(get_height_from_size ${size})
    set_cam_size ${width} ${height}

    set_camera 1
    local size=$(get_size_in_tuning_file ${camera})
    local width=$(get_width_from_size ${size})
    local height=$(get_height_from_size ${size})
    set_cam_size ${width} ${height}
}

setup_isp() {
    check_arguments_count $# 2 "<w> <h>"
    check_devices
    local ret=$(
        cd /opt/imx8-isp/bin
        ./vc-mipi-setup.sh --force setup-c${camera} ${1} ${2}
        echo $?
    )
    if [[ ${ret} == 1 ]]; then
        exit 1
    fi
    sleep ${wait_for_service}
    set_cam_size ${1} ${2}
}

set_selection() {
    check_arguments_count $# 4 "<l> <t> <w> <h>"
    check_devices
    v4l2-ctl -d ${device} --set-selection left=${1},top=${2},width=${3},height=${4}
}

set_size() {
    check_arguments_count $# 2 "<w> <h>"
    check_devices
    v4l2-ctl -d ${device} --set-fmt-video width=${1},height=${2}
}

set_cam_selection() {
    check_arguments_count $# 4 "<l> <t> <w> <h>"
    check_devices
    # Note: --set-subdev-selection is only for testing.
    # v4l2-ctl -d ${camdev} --set-subdev-selection left=${1},top=${2},width=${3},height=${4}
    entity=$(get_entity_name ${camdev})
    media-ctl -d ${media0} --set-v4l2 "\"${entity}\":0[crop:(${1},${2})/${3}x${4}]"
}

set_cam_size() {
    check_arguments_count $# 2 "<w> <h>"
    check_devices
    # Note: --set-subdev-fmt is only for testing.
    # v4l2-ctl -d ${camdev} --set-subdev-fmt width=${1},height=${2}
    entity=$(get_entity_name ${camdev})
    fcc=$(get_entity_fcc "${entity}")
    media-ctl -d ${media0} --set-v4l2 "\"${entity}\":0[fmt:${fcc}/${1}x${2}]"
}

# Note: --set-subdev-fmt is only for testing.
# set_cam_subdev_fmt() {
#     check_arguments_count $# 1
#
#     local code=
#     case ${1} in
#     GREY) code=0x2001 ;; 
#     Y10)  code=0x200a ;;
#     Y12)  code=0x2013 ;;
#     Y14)  code=0x202d ;;
#     RGGB) code=0x3014 ;;
#     RG10) code=0x300f ;;
#     RG12) code=0x3012 ;;
#     GBRG) code=0x3013 ;;
#     GB10) code=0x300e ;;
#     GB12) code=0x3010 ;;
#     *) echo "Pixelformat not supported!"; exit 1
#     esac
#
#     v4l2-ctl -d ${camdev} --set-subdev-fmt code=${code}
# }

set_cam_format() {
    check_arguments_count $# 1 "<f>"
    check_devices

    local fcc=
    case ${1} in
    GREY) fcc=Y8_1X8 ;;
    Y10)  fcc=Y10_1X10 ;;
    Y12)  fcc=Y12_1X12 ;;
    Y14)  fcc=Y14_1X14 ;;
    RGGB) fcc=SRGGB8_1X8 ;;
    RG10) fcc=SRGGB10_1X10 ;;
    RG12) fcc=SRGGB12_1X12 ;;
    GBRG) fcc=SGBRG8_1X8 ;;
    GB10) fcc=SGBRG10_1X10 ;;
    GB12) fcc=SGBRG12_1X12 ;;
    *) echo "Pixelformat not supported!"; exit 1
    esac

    local entity=$(get_entity_name ${camdev})
    local size=$(get_entity_size "${entity}")
    media-ctl -d ${media0} --set-v4l2 "\"${entity}\":0[fmt:${fcc}/${size}]"
}

restart_service() {
    check_arguments_count $# 0
    systemctl restart imx8-isp
    sleep ${wait_for_service}
}

run() {
    check_arguments_count $# 4 "<w> <h> <f> <n>"
    check_devices
    v4l2-ctl -d ${device} --set-fmt-video width=${1},height=${2},pixelformat="${3}"
    v4l2_test ${4}
}

run_rtp()
{
    check_arguments_count $# 8 "<iw> <ih> <cl> <ct> <cw> <ch> <ow> <oh>"

    local in_width=${1}
    local in_height=${2}
    local crop_left=${3}
    local crop_top=${4}
    local crop_width=${5}
    local crop_height=${6}
    local out_width=${7}
    local out_height=${8}

    (( crop_right = in_width - crop_left - crop_width ))
    (( crop_bottom = in_height - crop_top - crop_height ))
    local rotation=0

    echo "in   width:${in_width}, height:${in_height}"
    echo "crop left:${crop_left}, top:${crop_top}, width:${crop_width}, height:${crop_height}"
    echo "     right:${crop_right}   , bottom:${crop_bottom}"
    echo "out  width:${out_width}, height:${out_height}"

    # export GST_DEBUG=videobox:5,imxvideoconvert_g2d:5
    gst-launch-1.0 v4l2src device=${device} ! \
        video/x-raw,width=${in_width},height=${in_height},format=YUY2 ! \
        videobox name=vb top=${crop_top} bottom=${crop_bottom} left=${crop_left} right=${crop_right} ! \
        imxvideoconvert_g2d ! \
        video/x-raw,width=${out_width},height=${out_height} ! \
        vpuenc_h264 ! \
        rtph264pay pt=96 ! \
        udpsink host=${host} port=${port}
}

run_gst()
{
    check_arguments_count $# 8 "<iw> <ih> <cl> <ct> <cw> <ch> <ow> <oh>"

    local in_width=${1}
    local in_height=${2}
    local crop_left=${3}
    local crop_top=${4}
    local crop_width=${5}
    local crop_height=${6}
    local out_width=${7}
    local out_height=${8}

    (( crop_right = in_width - crop_left - crop_width ))
    (( crop_bottom = in_height - crop_top - crop_height ))
    local rotation=0

    echo "in   width:${in_width}, height:${in_height}"
    echo "crop left:${crop_left}, top:${crop_top}, width:${crop_width}, height:${crop_height}"
    echo "     right:${crop_right}   , bottom:${crop_bottom}"
    echo "out  width:${out_width}, height:${out_height}"

    # export GST_DEBUG=videobox:5,imxvideoconvert_g2d:5
    gst-launch-1.0 v4l2src device=${device} ! \
        video/x-raw,width=${in_width},height=${in_height},format=YUY2 ! \
        queue name=bf_vb_c${camera} ! \
        videobox name=vb top=${crop_top} bottom=${crop_bottom} left=${crop_left} right=${crop_right} ! \
        queue name=af_vb_c${camera} ! \
        imxvideoconvert_g2d ! \
        video/x-raw,width=${out_width},height=${out_height} ! \
        fpsdisplaysink video-sink=fakesink text-overlay=false -v 2>&1 
}

test_fps() {
    check_arguments_count $# 0
    check_devices
    v4l2-ctl -d ${device} --stream-mmap
}

test_hs_settle() {
    check_arguments_count $# 5 "<min> <max> <w> <h> <n>"
    check_devices
    v4l2-ctl -d ${device} --set-fmt-video width=${3},height=${4}
    for ((hs_settle = ${1} ; hs_settle <= ${2} ; hs_settle++)); do
        echo 
        echo "--- TEST csis-hs-settle ${hs_settle} ------------------------"
        v4l2-ctl -d ${csidev} -c csi_hs_settle=${hs_settle}
        v4l2_test ${5}
        echo "----------------------------------------------------------"
    done
}

test_hmax() {
    check_arguments_count $# 5 "<min> <max> <w> <h> <n>"
    check_devices
    v4l2-ctl -d ${device} --set-fmt-video width=${3},height=${4}
    for ((hmax = ${1} ; hmax <= ${2} ; hmax++)); do
        echo 
        echo "--- TEST hmax ${hmax} --------------------------------------"
        v4l2-ctl -d ${camdev} -c hmax_overwrite=${hmax}
        v4l2_test ${5}
        echo "----------------------------------------------------------"
    done
}

test_cam_width() {
    check_arguments_count $# 5 "<min> <max> <step> <h> <n>"
    check_devices
    v4l2-ctl -d ${device} --set-fmt-video width=${2},height=${4}
    for ((width = ${1} ; width <= ${2} ; width+=${3})); do
        echo 
        echo "--- TEST cam width ${width} -----------------------------------"
        set_cam_size ${width} ${4}
        v4l2_test ${5}
        echo "----------------------------------------------------------"
    done
}

test_isi_width() {
    check_arguments_count $# 5 "<min> <max> <step> <h> <n>"
    check_devices
    for ((width = ${1} ; width <= ${2} ; width+=${3})); do
        echo 
        echo "--- TEST cam width ${width} -----------------------------------"
        v4l2-ctl -d ${device} --set-fmt-video width=${width},height=${4}
        set_cam_size ${width} ${4}
        v4l2_test ${5}
        echo "----------------------------------------------------------"
    done
}

test_isp_width() {
    check_arguments_count $# 5 "<min> <max> <step> <h> <n>"
    check_devices
    for ((width = ${1} ; width <= ${2} ; width+=${3})); do
        echo 
        echo "--- TEST isp width ${width} ----------------------------------"
        setup_isp ${width} ${4}
        v4l2-ctl -d ${device} --set-fmt-video width=${width},height=${4}
        set_cam_size ${width} ${4}
        v4l2_test ${5}
        echo "----------------------------------------------------------"
    done
}

test-live-roi() {
    check_arguments_count $# 6 "<b1> <l1> <t1> <b2> <l2> <t2>"
    check_devices

    local binning_mode1=${1}
    local left1=${2}
    local top1=${3}
    local binning_mode2=${4}
    local left2=${5}
    local top2=${6}

    local live_roi1=$(( ${binning_mode1} * 100000000 + ${left1} * 10000 + ${top1}))
    local live_roi2=$(( ${binning_mode2} * 100000000 + ${left2} * 10000 + ${top2}))

    while true; do
        echo "Roi 1 (binning_mode:${binning_mode1}, left:${left1}, top:${top1})"
        v4l2-ctl -d ${camdev} -c live_roi=${live_roi1}
        sleep 1
        echo "Roi 2 (binning_mode:${binning_mode2}, left:${left2}, top:${top2})"
        v4l2-ctl -d ${camdev} -c live_roi=${live_roi2}
        sleep 1
    done
}

save_raw() {
    check_arguments_count $# 3 "<w> <h> <f>"
    check_devices
    filename=VC_$(date '+%Y%m%d_%H%M%S')_${1}x${2}.raw
    v4l2-ctl -d ${device} --set-fmt-video width=${1},height=${2},pixelformat="${3}"
    v4l2-ctl -d ${device} --stream-mmap --stream-count=1 --stream-to=${filename}
}

save_jpg() {
    check_arguments_count $# 4 "<w> <h> <r> <n>"
    check_devices
    filename=VC_$(date '+%Y%m%d_%H%M%S')_${1}x${2}.jpg
    v4l2-ctl -d ${device} --set-fmt-video width=${1},height=${2},pixelformat=YUYV
    gst-launch-1.0 \
        v4l2src device=${device} num-buffers=${4} ! \
        "video/x-raw,width=${1},height=${2},format=YUY2" ! \
        imxvideoconvert_g2d rotation=${3} ! \
        jpegenc quality=100 ! \
        multifilesink max-files=1 location=${filename}
}

save_media() {
    if [[ -e /dev/media0 ]]; then
        media-ctl -d /dev/media0 --print-dot > media0.dot
    fi
    if [[ -e /dev/media1 ]]; then
        media-ctl -d /dev/media1 --print-dot > media1.dot
    fi
    echo "Convert dot files with:"
    echo "$ dot -Tsvg media0.dot > media0.svg"
}

while [ $# != 0 ] ; do
    option=${1}
    shift

    case ${option} in
    -b|--binning)
        set_cam_binning ${1}
        shift
        ;;
    -bl|--black_level)
        set_cam_black_level ${1}
        shift
        ;;
    -c|--camera)
        set_camera ${1}
        shift
        ;;
    -cs|--clk-settle)
        set_csi_clk_settle ${1}
        shift
        ;;
    -d|--device)
        set_device ${1}
        shift
        ;;
    -dcsi|--device-csi)
        set_csidev ${1}
        shift
        ;;
    -dcam|--device-cam)
        set_camdev ${1}
        shift
        ;;
    -dbgcam|--debug-cam)
        set_debug_cam ${1}
        shift
        ;;
    -dbgcsi|--debug-csi)
        set_debug_csi ${1}
        shift
        ;;
    -dbgisi|--debug-isi)
        set_debug_isi ${1}
        shift
        ;;
    -dbgisp|--debug-isp)
        set_debug_isp ${1}
        shift
        ;;
    -dbggst|--debug-gst)
        set_debug_gst ${1}
        shift
        ;;
    -e|--exposure)
        set_cam_exposure ${1}
        shift
        ;;
    -f|--format)
        set_format "${1}"
        shift
        ;;
    -fc|--format-cam)
        set_cam_format ${1}
        shift
        ;;
    -fr|--frame-rate)
        set_cam_frame_rate ${1}
        shift
        ;;
    fps)
        test_fps
        ;;
    -g|--gain)
        set_cam_gain ${1}
        shift
        ;;
    gst)
        run_gst ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8};
        shift; shift; shift; shift; shift; shift; shift; shift
        ;;
    -h|--host)
        set_host ${1}
        shift
        ;;
    --help)
        usage
        exit 0
        ;;
    -i|--io-mode)
        set_cam_io_mode ${1}
        shift
        ;;
    -ho|--height-offset)
        set_height_offset ${1}
        shift
        ;;
    -hs|--hs-settle)
        set_csi_hs_settle ${1}
        shift
        ;;
    init)
        init_isp
        ;;
    isi)
        activate isp isi
        ;;
    isp)
        activate isi isp
        ;;
    jpg)
        save_jpg ${1} ${2} ${3} ${4}
        shift; shift; shift; shift
        ;;
    -l|--lanes)
        set_lanes ${1}
        shift
        ;;
    media)
        save_media
        ;;
    -p|--port)
        set_port ${1}
        shift
        ;;
    -r|--roi)
        set_selection ${1} ${2} ${3} ${4}
        shift; shift; shift; shift
        ;;
    -rc|--roi-cam)
        set_cam_selection ${1} ${2} ${3} ${4}
        shift; shift; shift; shift
        ;;
    raw)
        save_raw ${1} ${2} "${3}"
        shift; shift; shift
        ;;
    restart)
        restart_service
        ;;
    run)
        run ${1} ${2} "${3}" ${4}
        shift; shift; shift; shift
        ;;
    rtp)
        run_rtp ${1} ${2} ${3} ${4} ${5} ${6} ${7} ${8};
        shift; shift; shift; shift; shift; shift; shift; shift
        ;;
    -s|--size)
        set_size ${1} ${2}
        shift; shift
        ;;
    -sc|--size-cam)
        set_cam_size ${1} ${2}
        shift; shift
        ;;
    -st|--single-trigger)
        set_cam_single_trigger
        ;;
    setup)
        setup_isp ${1} ${2}
        shift; shift
        ;;
    --shift)
        set_bitshift ${1}
        shift
        ;;
    -t|--trigger)
        set_cam_trigger_mode ${1}
        shift
        ;;
    test-hmax)
        test_hmax ${1} ${2} ${3} ${4} ${5}
        shift; shift; shift; shift; shift
        ;;
    test-hs-settle)
        test_hs_settle ${1} ${2} ${3} ${4} ${5}
        shift; shift; shift; shift; shift
        ;;
    test-cam-width)
        test_cam_width ${1} ${2} ${3} ${4} ${5}
        shift; shift; shift; shift; shift
        ;;
    test-isi-width)
        test_isi_width ${1} ${2} ${3} ${4} ${5}
        shift; shift; shift; shift; shift
        ;;
    test-isp-width)
        test_isp_width ${1} ${2} ${3} ${4} ${5}
        shift; shift; shift; shift; shift
        ;;
    test-live-roi)
        test-live-roi ${1} ${2} ${3} ${4} ${5} ${6}
        shift; shift; shift; shift; shift; shift
        ;;
    x)
        set_host "macbook-pro"
        ;;
    *)
        echo "Unknown option: ${option}"
        exit 1
        ;;
    esac
done
