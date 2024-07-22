FILESEXTRAPATHS:prepend := "${THISDIR}/linux-toradex:"

SRC_URI += "file://0001-media-csi-Added-missing-pixelformats-for-mx6s-csi-dr.patch"
SRC_URI += "file://0002-media-csi-Fixed-a-missing-mipi_csis_clk_disable-in-m.patch"
SRC_URI += "file://0003-media-csi-Changed-MAX_VIDEO_MEM-to-256-to-support-up.patch"
SRC_URI += "file://0004-media-csi-The-bytesperline-and-pixelformat-settings-.patch"
SRC_URI += "file://0005-media-csi-Added-support-for-v4l2-controls-from-senso.patch"
SRC_URI += "file://0006-media-i2c-Added-universal-VC-MIPI-CSI-2-camera-drive.patch"
SRC_URI += "file://0007-arm64-toradex_defconfig-Added-universal-VC-MIPI-CSI-.patch"