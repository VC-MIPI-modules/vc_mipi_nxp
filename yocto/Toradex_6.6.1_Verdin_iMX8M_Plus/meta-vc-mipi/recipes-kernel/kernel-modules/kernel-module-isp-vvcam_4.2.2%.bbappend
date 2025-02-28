FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://0001-Added-Vision-Components-MIPI-CSI-2-driver.patch;patchdir=../.. \
    file://0002-Vision-Components-MIPI-CSI-2-driver-Fix-for-IMX568.patch;patchdir=../.. \
    file://0003-Add-mode-12-bit-2lanes-imx462.patch;patchdir=../.. \
"