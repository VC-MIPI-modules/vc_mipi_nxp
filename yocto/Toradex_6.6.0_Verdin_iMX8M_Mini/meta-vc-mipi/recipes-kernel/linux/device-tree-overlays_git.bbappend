FILESEXTRAPATHS:prepend := "${THISDIR}/device-tree-overlays:"

CUSTOM_OVERLAYS_SOURCE = " \
    verdin-imx8mm_vc_mipi_overlay.dts \
"
CUSTOM_OVERLAYS_BINARY = " \
    verdin-imx8mm_vc_mipi_overlay.dtbo \
"

SRC_URI += " \
    file://verdin-imx8mm_vc_mipi_overlay.dts \
"

TEZI_EXTERNAL_KERNEL_DEVICETREE_BOOT:append = " \
    ${CUSTOM_OVERLAYS_BINARY} \
"

do_collect_overlays:prepend() {
    for DTS in ${CUSTOM_OVERLAYS_SOURCE}; do
        cp ${WORKDIR}/${DTS} ${S}
    done
}