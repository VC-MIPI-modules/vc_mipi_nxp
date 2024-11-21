FILESEXTRAPATHS:prepend := "${THISDIR}/linux-imx:"

SRC_URI += "file://0001-arm64-imx8-Added-Vision-Components-MIPI-CSI-2-device.patch"
SRC_URI += "file://0001-media-imx8-Added-missing-pixelformats.patch"
SRC_URI += "file://0002-media-imx8-Fixed-missing-pixelformat-negotiation-bet.patch"
SRC_URI += "file://0003-media-imx8-Fixed-bytesperline-calculation.patch"
SRC_URI += "file://0004-media-imx8-Added-v4l2-controls-to-csis-driver-for-ad.patch"
SRC_URI += "file://0005-media-imx8-Added-advanced-logging-of-csis-and-isi-dr.patch"

KERNEL_DEVICETREE += " \
    freescale/imx8mp-var-dart-dt8mcustomboard-vc-mipi-isi-csi0.dtb \
    freescale/imx8mp-var-dart-dt8mcustomboard-vc-mipi-isi-csi1.dtb \
    freescale/imx8mp-var-dart-dt8mcustomboard-vc-mipi-isi-csi0-csi1.dtb \
    freescale/imx8mp-var-dart-dt8mcustomboard-vc-mipi-isp-csi0.dtb \
    freescale/imx8mp-var-dart-dt8mcustomboard-vc-mipi-isp-csi0-csi1.dtb \
"