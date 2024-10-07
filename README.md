# Vision Components MIPI CSI-2 driver for NXP SoMs

![VC MIPI camera](doc/images/mipi_sensor_front_back.png)

## Version 0.3.0.pre1 ([History](VERSION.md))

* Supported system on modules
  * [Toradex Verdin iMX8M Plus](https://developer.toradex.com/hardware/verdin-som-family/modules/verdin-imx8m-plus)
  * [Toradex Verdin iMX8M Mini](https://developer.toradex.com/hardware/verdin-som-family/modules/verdin-imx8m-mini)
  * [Variscite DART-MX8M-PLUS](https://www.variscite.com/product/system-on-module-som/cortex-a53-krait/dart-mx8m-plus-nxp-i-mx-8m-plus)

* Supported carrier boards
  * [Toradex Dahlia Carrier Board](https://developer.toradex.com/hardware/verdin-som-family/carrier-boards/dahlia-carrier-board)
  * [Variscite DART-MX8M-PLUS Evaluation Kits](https://www.variscite.com/product/evaluation-kits/dart-mx8m-plus-evaluation-kits/)
  
* Supported board support packages
  * [Toradex Yocto Project 6.6.0](https://developer.toradex.com/software/toradex-embedded-software/embedded-linux-release-matrix/)
  * [Variscite Kirkstone 5.15.71](https://variwiki.com/index.php?title=DART-MX8M-PLUS_Yocto&release=mx8mp-yocto-kirkstone-5.15.71_2.2.0-v1.2)
  
* Supported [VC MIPI Camera Modules](https://www.vision-components.com/fileadmin/external/documentation/hardware/VC_MIPI_Camera_Module/index.html)
  * IMX290, IMX327, IMX462

* Features
  * Quickstart script for an easier installation process
  * Auto detection of VC MIPI camera modules
  * Image Streaming in GREY, Y10, Y12, SRGGB8, SRGGB10, SRGGB12, SGBRG8, SGBRG10, SGBRG12 format
  * **Exposure** can be set via V4L2 control 'exposure'
  * **Gain** can be set via V4L2 control 'gain'
  * **[Trigger mode](doc/TRIGGER_MODE.md)** '0: disabled', '1: external', '2: pulsewidth', '3: self', '4: single', '5: sync', '6: stream_edge', '7: stream_level' can be set via device tree or V4L2 control 'trigger_mode'
    * **Software trigger** can be executed by V4L2 control 'single_trigger'
  * **[IO mode](doc/IO_MODE.md)** '0: disabled', '1: flash active high', '2: flash active low', '3: trigger active low', '4: trigger active low and flash active high', '5: trigger and flash active low' can be set via device tree or V4L2 control 'flash_mode'
  * **Frame rate** can be set via V4L2 control 'frame_rate' *(except OV9281)*
  * **[Black level](doc/BLACK_LEVEL.md)** can be set via V4L2 control 'black_level' *(except OV7251 and OV9281)*
  * **[ROI cropping](doc/ROI_CROPPING.md)** can be set via device tree properties active_l, active_t, active_w and active_h or v4l2-ctl.
  * **[Binning mode](doc/BINNING_MODE.md)** can be set via V4L2 control 'binning_mode' *(IMX412, IMX565, IMX566, IMX567, IMX568 only)*

## Quickstart

### Toradex
  * Follow the instructions to [Build a Reference Image with Yocto Project/OpenEmbedded](https://developer.toradex.com/linux-bsp/os-development/build-yocto/build-a-reference-image-with-yocto-projectopenembedded)

### Variscite
  * Follow the instructions to [Build Yocto from source code](https://variwiki.com/index.php?title=Yocto_Build_Release&release=mx8mp-yocto-kirkstone-5.15.71_2.2.0-v1.2)