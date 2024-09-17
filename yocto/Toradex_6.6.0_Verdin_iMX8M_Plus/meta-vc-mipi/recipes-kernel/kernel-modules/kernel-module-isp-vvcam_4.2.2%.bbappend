FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://0001-Added-Vision-Components-MIPI-CSI-2-driver.patch;patchdir=../.. \
    file://0002-Vision-Components-MIPI-CSI-2-driver-Fix-for-IMX568.patch;patchdir=../.. \
"