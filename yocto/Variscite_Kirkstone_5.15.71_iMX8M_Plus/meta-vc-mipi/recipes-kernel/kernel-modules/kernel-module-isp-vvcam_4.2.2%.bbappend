FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0001-Added-Vision-Components-MIPI-CSI-2-driver.patch;patchdir=../.."
SRC_URI += "file://0002-Vision-Components-MIPI-CSI-2-driver-Fix-for-IMX568.patch;patchdir=../.."
SRC_URI += "file://0003-Added-debug-module-parameter-to-VC-MIPI-CSI-2-driver.patch;patchdir=../.."
SRC_URI += "file://0004-Fixed-issues-with-i.MX8M-Plus-ISP-Auto-Exposure-Cont.patch;patchdir=../.."