FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}/:"

SRC_URI += "file://0001-Added-VC-MIPI-CSI-2-driver.patch"

FILES_SOLIBS_VERSIONED += " \
    ${libdir}/libvc-mipi.so \
"

do_install:append() {
    cp ${S}/imx/vc-mipi-setup.sh ${D}/opt/imx8-isp/bin
    chmod +x ${D}/opt/imx8-isp/bin/vc-mipi-setup.sh
}

RDEPENDS:${PN} += "bash" 