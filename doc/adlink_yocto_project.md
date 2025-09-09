# Adlink Yocto Project 

## Scarthgap

[Official documentation](https://github.com/ADLINK/meta-adlink-nxp/wiki/Building-Yocto-for-LEC%E2%80%90IMX8MP)

### Build Image
```
$ repo init -u https://github.com/VC-MIPI-modules/manifest-vc-bsp.git -b adlink-scarthgap -m adlink-lec-imx8mX-yocto-scarthgap_1v0.xml
$ repo sync
$ MACHINE=lec-imx8mp DISTRO=fsl-imx-xwayland source adlink-imx-setup-release.sh -b build
```
In `build/conf/local.conf` 
set the LPDDR4 DRAM size, available options are: 
LPDDR4_2GB, LPDDR4_2GK, LPDDR4_4GB, LPDDR4_8GB
* Add `UBOOT_EXTRA_CONFIGS = "LPDDR4_2GB"`
```
$ bitbake-layers add-layer ../sources/meta-vc-mipi
$ bitbake-layers add-layer ../sources/meta-vc-mipi-test
$ bitbake imx-image-multimedia
```

### Create SD Card
```
$ cd build
$ sudo dd if=tmp/deploy/images/lec-imx8mp/imx-image-multimedia-lec-imx8mp.rootfs.wic of=/dev/mmcblk0 bs=64M conv=fsync status=progress
```