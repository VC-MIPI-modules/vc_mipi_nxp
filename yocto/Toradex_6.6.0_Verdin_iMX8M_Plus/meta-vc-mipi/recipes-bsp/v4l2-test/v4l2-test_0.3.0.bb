# Copyright 2024-2024 Vision Components GmbH
DESCRIPTION = "Test and example application to use v4l2 cameras"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"
SECTION = "BSP"

FILESEXTRAPATHS:prepend := "${THISDIR}/v4l2-test:"

SRC_URI += "git://github.com/pmliquify/v4l2-test.git;protocol=https;branch=develop"
SRCREV = "c26ecfd2d57fc8e55654f0cd209673d78e5dab40"

SRC_URI += "file://test.sh"

S = "${WORKDIR}/git"

inherit cmake

do_install() {
    install -d ${D}${ROOT_HOME}
    install -m 0755 ${WORKDIR}/test.sh ${D}${ROOT_HOME}
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/build/v4l2-test ${D}${bindir}
}

FILES:${PN} = "${ROOT_HOME}* ${bindir}/*"
RDEPENDS:${PN} += "bash" 