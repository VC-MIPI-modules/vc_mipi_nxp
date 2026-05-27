# Variscite Yocto Project 

## Kirkstone

[Official documentation](https://dev.variscite.com/var-som-mx8m-plus/mx8mp-yocto-kirkstone-5.15.71_2.2.0-v1.3/yocto-build-release)

Check the prerequisites here [Build Yocto from source code](https://dev.variscite.com/var-som-mx8m-plus/mx8mp-yocto-kirkstone-5.15.71_2.2.0-v1.3/yocto-build-release/#installing-required-packages) before building the image.

### Build Image
```
$ repo init -u https://github.com/VC-MIPI-modules/manifest-vc-bsp.git -b variscite-kirkstone -m kirkstone-5.15.71-2.2.0.xml
$ repo sync -j1
$ MACHINE=imx8mp-var-dart DISTRO=fslc-xwayland . var-setup-release.sh build_xwayland
$ bitbake-layers add-layer ../sources/meta-vc-mipi
$ bitbake-layers add-layer ../sources/meta-vc-mipi-test
$ bitbake fsl-image-gui
```

### Create SD Card
```
$ cd build_xwayland
$ zcat tmp/deploy/images/imx8mp-var-dart/fsl-image-gui-imx8mp-var-dart.wic.gz | sudo dd of=/dev/mmcblk0 bs=1M conv=fsync status=progress
```

## Scarthgap

[Official documentation](https://dev.variscite.com/dart-mx8m-plus/mx8mp-yocto-scarthgap-6.6.y_2.2.2-v1.0/yocto-build-release)

Check the prerequisites here [Build Yocto from source code](https://dev.variscite.com/dart-mx8m-plus/mx8mp-yocto-scarthgap-6.6.y_2.2.2-v1.0/yocto-build-release/#installing-required-packages) before building the image.

### Build Image
```
$ repo init -u https://github.com/VC-MIPI-modules/manifest-vc-bsp.git -b variscite-scarthgap -m imx-6.6.52-2.2.0.xml
$ repo sync -j1
$ MACHINE=imx8mp-var-dart DISTRO=fslc-xwayland . var-setup-release.sh build_xwayland
$ bitbake-layers add-layer ../sources/meta-vc-mipi
$ bitbake-layers add-layer ../sources/meta-vc-mipi-test
$ bitbake fsl-image-gui
```

### Create SD Card
```
$ cd build_xwayland
$ zstdcat tmp/deploy/images/imx8mp-var-dart/fsl-image-gui-imx8mp-var-dart.rootfs.wic.zst | sudo dd of=/dev/mmcblk0 bs=1M conv=fsync status=progress
```

## Walnascar

[Official documentation DART-MX95](https://dev.variscite.com/dart-mx95/mx95-yocto-walnascar-6.12.49_2.2.0-v1.0/yocto-build-release/)

Check the prerequisites here [Build Yocto from source code](https://dev.variscite.com/dart-mx95/mx95-yocto-walnascar-6.12.49_2.2.0-v1.0/yocto-build-release/#installing-required-packages) before building the image.

### Build Image
```
$ repo init -u https://github.com/VC-MIPI-modules/manifest-vc-bsp.git -b variscite-walnascar -m imx-6.12.49-2.2.0.xml
$ repo sync -j1
$ MACHINE=imx95-var-dart DISTRO=fsl-imx-xwayland . var-setup-release.sh build_xwayland
```
In `build_xwayland/conf/local.conf` 
* Add `MACHINE_EXTRA_RRECOMMENDS:remove = "kernel-module-nxp-wlan"`
Because this kernel module package seems to be broken.
```
$ bitbake-layers add-layer ../sources/meta-vc-mipi
$ bitbake-layers add-layer ../sources/meta-vc-mipi-test
$ bitbake fsl-image-gui
```

### Create SD Card
```
$ cd build_xwayland
$ zstdcat tmp/deploy/images/imx95-var-dart/fsl-image-gui-imx95-var-dart.rootfs.wic.zst | sudo dd of=/dev/mmcblk0 bs=1M conv=fsync status=progress
```