# Variscite Yocto Project 

## Kirkstone

[Official documentation](https://variwiki.com/index.php?title=DART-MX8M-PLUS_Yocto&release=mx8mp-yocto-kirkstone-5.15.71_2.2.0-v1.2)

Check the prerequisites here [Build Yocto from source code](https://variwiki.com/index.php?title=Yocto_Build_Release&release=mx8mp-yocto-kirkstone-5.15.71_2.2.0-v1.2) before building the image.

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

[Official documentation](https://variwiki.com/index.php?title=DART-MX8M-PLUS_Yocto&release=mx8mp-yocto-scarthgap-6.6.52_2.2.0-v1.0)

Check the prerequisites here [Build Yocto from source code](https://variwiki.com/index.php?title=Yocto_Build_Release&release=mx8mp-yocto-scarthgap-6.6.52_2.2.0-v1.0) before building the image.

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