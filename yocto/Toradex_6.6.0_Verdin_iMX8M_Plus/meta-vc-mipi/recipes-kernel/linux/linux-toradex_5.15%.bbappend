FILESEXTRAPATHS:prepend := "${THISDIR}/linux-toradex:"

SRC_URI += "file://0001-media-imx8-Added-missing-pixelformats.patch"
SRC_URI += "file://0002-media-imx8-Fixed-missing-pixelformat-negotiation-bet.patch"
SRC_URI += "file://0003-media-imx8-Fixed-bytesperline-calculation.patch"
SRC_URI += "file://0004-media-imx8-Changed-debug-message-printing.patch"
SRC_URI += "file://0005-media-imx8-Added-v4l2-controls-to-csis-driver-for-ad.patch"
SRC_URI += "file://0006-media-i2c-Added-Vision-Components-MIPI-CSI-2-driver.patch"