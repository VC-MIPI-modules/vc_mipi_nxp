# Using the test.sh Script

## Device Tree Files

For your first tests it is recommended to use the test.sh script. It will be installed by using 
the meta-vc-mipi-test layer. You will find the test.sh script in /home/root or /root. The script 
uses the v4l2-test test application from https://github.com/pmliquify/v4l2-test.

After the first boot up for Adlink, Toradex or Variscite please login by ssh to your target.

### Adlink

First you have to setup a DTB file which activates the ISI, ISP, CSI and Camera driver.
You will find two DTB files for different cases.

```
$ find /run/media/boot-mmcblk1p1/ -name "*vc-mipi*"
/run/media/boot-mmcblk1p1/lec-imx8mp-vc-mipi-csi1.dtb
/run/media/boot-mmcblk1p1/lec-imx8mp-vc-mipi-csi0-csi1.dtb
```

You have to set the uboot variable FDT_FILE to one of these files. 

```
u-boot=> setenv fdt_file lec-imx8mp-vc-mipi-csi0-csi1.dtb
u-boot=> saveenv
u-boot=> boot
```

### Toradex

In the case of a toradex system a DTBO file is already added to /boot/overlays.txt. So the 
system already is setup properly.

```
$ find /boot/overlays -name *vc_mipi*
/boot/overlays/verdin-imx8mp_vc_mipi_overlay.dtbo
```

### Variscite

As for Adlink there are two DTB files for different cases.

```
$ find /boot -name "*vc-mipi*"
/boot/imx8mp-var-dart-dt8mcustomboard-vc-mipi-csi1.dtb
/boot/imx8mp-var-dart-dt8mcustomboard-vc-mipi-csi0-csi1.dtb
```

You have to set the uboot variable FDT_FILE to one of these files. 

```
u-boot=> setenv fdt_file imx8mp-var-dart-dt8mcustomboard-vc-mipi-csi0-csi1.dtb
u-boot=> saveenv
u-boot=> boot
```

## Check your system

To check if you have setup the device tree properly you can do

```
$ find /sys/firmware/devicetree/base/soc\@0/ -name *vc_mipi*
/sys/firmware/devicetree/base/soc@0/bus@30800000/i2c@30a50000/vc_mipi@1a
/sys/firmware/devicetree/base/soc@0/bus@30800000/i2c@30a30000/vc_mipi@1a
```

You should find one or two entries.

## Setup Tuning Files

After device tree setup you have to create a tuning file which fits to the installed cameras.

```
$ ./test.sh init
Found VC MIPI camera on i2c-1 (i2c@30a30000)
Detected device with address 0x10 on i2c-1
Detected device is a VC MIPI IMX412C camera
Image size will be set to 4032x3040
Found VC MIPI camera on i2c-3 (i2c@30a50000)
Detected device with address 0x10 on i2c-3
Detected device is a VC MIPI IMX412C camera
Image size will be set to 4032x3040
ISP: viv_v4l20 <- vvcam-isp.0 <- mxc-mipi-csi2.0 <- vc-mipi-cam 1-001a
CAM0: device=/dev/video5, csidev=/dev/v4l-subdev0, camdev=/dev/v4l-subdev3
ISP: viv_v4l21 <- vvcam-isp.1 <- mxc-mipi-csi2.1 <- vc-mipi-cam 3-001a
CAM1: device=/dev/video6, csidev=/dev/v4l-subdev1, camdev=/dev/v4l-subdev2
```

You can check this by

```
$ find /opt/imx8-isp/bin/ -name *vc_imx*
/opt/imx8-isp/bin/vc_imx412c_tuning.xml
/opt/imx8-isp/bin/dewarp_config/vc_imx412c_dewarp.json

$ cat /opt/imx8-isp/bin/Sensor0_Entry.cfg
name = "vc-mipi-vvcam"
drv = "vc-mipi.drv"
mode = 0
[mode.0]
xml = "vc_imx412c_tuning.xml"
dwe = "dewarp_config/vc_imx412c_dewarp.json"
```

## Start Streaming

Now is the time to start an image stream

```
$ ./test.sh --isp --camera 0 run 4032 3040 YUYV 3
ISP: viv_v4l20 <- vvcam-dwe.0 <- mxc-mipi-csi2.0 <- vc-mipi-cam 1-001a
CAM0: device=/dev/video5, csidev=/dev/v4l-subdev0, camdev=/dev/v4l-subdev3
Format (width: 4032, height: 3040, pixelformat: YUYV, colorspace: )
[#0000, ts:  226768, t:   0 ms, 4032, 3040, 8064, YUYV] (2016, 1520) 0000000000000000 0000000000000000 0000000000000000 
[#0001, ts:  226818, t:  50 ms, 4032, 3040, 8064, YUYV] (2016, 1520) 0000000000000000 0000000000000000 0000000000000000 
[#0002, ts:  226868, t:  50 ms, 4032, 3040, 8064, YUYV] (2016, 1520) 0000000000000000 0000000000000000 0000000000000000 
```

To use the ISI media pipeline 

```
./test.sh --isi --camera 0 --shift 6 run 4032 3040 RG10 3
ISI: mxc_isi.0.capture <- mxc_isi.0 <- mxc-mipi-csi2.0 <- vc-mipi-cam 1-001a
CAM0: device=/dev/video3, csidev=/dev/v4l-subdev0, camdev=/dev/v4l-subdev3
Format (width: 4032, height: 3040, pixelformat: RG10, colorspace: SRGB)
[#0001, ts:  192030, t:   0 ms, 4032, 3040, 8064, RG10] (2016, 1520) 0000000000001011 0000000000001010 0000000000001010 
[#0002, ts:  192080, t:  50 ms, 4032, 3040, 8064, RG10] (2016, 1520) 0000000000001011 0000000000001001 0000000000001011 
[#0003, ts:  192130, t:  50 ms, 4032, 3040, 8064, RG10] (2016, 1520) 0000000000001010 0000000000001001 0000000000001010 
```

Perfect, your system is running properly.