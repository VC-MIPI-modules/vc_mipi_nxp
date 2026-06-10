# Vision Components MIPI CSI-2 driver for NXP SoMs

![VC MIPI camera](doc/images/mipi_sensor_front_back.png)

## Version 0.6.0 ([History](VERSION.md))

* Supported system on modules
  * [Adlink LEC-IMX8MP](https://www.adlinktech.com/Products/Computer_on_Modules/SMARC/LEC-IMX8MP)
  * [Variscite DART-MX8M-PLUS](https://variscite.com/system-on-module-som/i-mx-8/i-mx-8m-plus/dart-mx8m-plus)
  * [Variscite DART-MX95](https://variscite.com/system-on-module-som/i-mx-9/i-mx-95/dart-mx95/)
  * [Toradex Verdin iMX8M Plus](https://developer.toradex.com/hardware/verdin-som-family/modules/verdin-imx8m-plus)
  * [Toradex Verdin iMX8M Mini](https://developer.toradex.com/hardware/verdin-som-family/modules/verdin-imx8m-mini)

* Supported carrier boards
  * [Adlink I-Pi SMARC IMX8M Plus](https://www.adlinktech.com/products/Computer_on_Modules/SMARCStarterKits/I-Pi_SMARC_IMX8M_Plus)
  * [Toradex Dahlia Carrier Board](https://developer.toradex.com/hardware/verdin-som-family/carrier-boards/dahlia-carrier-board)
  * [Variscite DART-MX8M-PLUS Evaluation Kits](https://www.variscite.com/product/evaluation-kits/dart-mx8m-plus-evaluation-kits/)
  * [Variscite DART-MX95 Evaluation Kits](https://variscite.com/system-on-module-som/i-mx-9/i-mx-95/dart-mx95-evaluation-kits/)
  
* Supported board support packages
  * [Adlink Yocto Project](doc/adlink_yocto_project.md)
  * [Toradex Yocto Project](doc/toradex_yocto_project.md)
  * [Variscite Yocto Project](doc/variscite_yocto_project.md)
      
* Tested [VC MIPI Camera Modules](https://www.vision-components.com/fileadmin/external/documentation/hardware/VC_MIPI_Camera_Module/index.html)
  * IMX178, IMX183, IMX226
  * IMX250, IMX252, IMX264, IMX265, IMX273, IMX392
  * IMX290, IMX327, IMX462
  * IMX296, IMX297
  * IMX335
  * IMX412
  * IMX415
  * IMX565, IMX566, IMX567, IMX568
  * IMX900
  * OV9281

  ## Build

  Follow the instructions in the yocto project descriptions above.

  ## Test

  For a first test follow the instructions in [Using the test.sh Script](doc/using_test.sh_script.md)