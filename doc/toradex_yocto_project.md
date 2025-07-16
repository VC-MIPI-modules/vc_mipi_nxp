# Toradex Yocto Project 

## Kirkstone

[Embedded Linux Release Matrix](https://developer.toradex.com/software/toradex-embedded-software/embedded-linux-release-matrix/#680)

Check prerequisites here [Building a Reference Image with Yocto Project](https://developer.toradex.com/linux-bsp/os-development/build-yocto/build-a-reference-image-with-yocto-projectopenembedded/#prerequisites)

### Build Image
```
$ repo init -u https://github.com/VC-MIPI-modules/manifest-vc-bsp.git -b toradex-kirkstone -m tdxref/default.xml
$ repo sync -j1
$ . export
```
In `build/conf/local.conf`
* Uncomment `MACHINE ?= "verdin-imx8mp"`
* Add `ACCEPT_FSL_EULA = "1"`
* Add `IMAGE_INSTALL += " v4l2-test test.sh"`
```
$ bitbake-layers add-layer ../layers/meta-vc-mipi
$ bitbake-layers add-layer ../layers/meta-vc-mipi-test
$ bitbake tdx-reference-multimedia-image
```


## Scarthgap

[Embedded Linux Release Matrix](https://developer.toradex.com/software/toradex-embedded-software/embedded-linux-release-matrix/#700)

Check prerequisites here [Building a Reference Image with Yocto Project](https://developer.toradex.com/linux-bsp/os-development/build-yocto/build-a-reference-image-with-yocto-projectopenembedded/#prerequisites)

### Build Image
```
$ repo init -u https://github.com/VC-MIPI-modules/manifest-vc-bsp.git -b toradex-scarthgap -m tdxref/default.xml
$ repo sync -j1
$ . export
```
In `build/conf/local.conf`
* Uncomment `MACHINE ?= "verdin-imx8mp"`
* Add `ACCEPT_FSL_EULA = "1"`
* Add `IMAGE_INSTALL += " v4l2-test test.sh"`
```
$ bitbake-layers add-layer ../layers/meta-vc-mipi
$ bitbake-layers add-layer ../layers/meta-vc-mipi-test
$ bitbake tdx-reference-multimedia-image
```

The output artifacts can be found here [Build Artifacts](https://developer.toradex.com/linux-bsp/os-development/build-yocto/build-a-reference-image-with-yocto-projectopenembedded/#build-artifacts)


## Install Image for Kirkstone and Scarthgap

Follow the instructions in [Toradex Easy Installer Documentation](https://developer.toradex.com/easy-installer/toradex-easy-installer)
