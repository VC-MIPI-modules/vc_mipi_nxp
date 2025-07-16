# Using the test.sh Script

## Device Tree Files

For you first tests it is recommended to use the test.sh script. It will be installed by using 
the meta-vc-mipi-test layer. You will find the test.sh script in /home/root. The script uses the 
v4l2-test test application from https://github.com/pmliquify/v4l2-test.

After the first boot up for Variscite or Toradex please login by ssh to your target.

### Variscite

First you have to setup a DTB file which activates the ISI or ISP, CSI and Camera driver.
You will find five DTB files for different cases.

```
$ find /boot -name "*vc-mipi*"
/boot/imx8mp-var-dart-dt8mcustomboard-vc-mipi-isp-csi0.dtb
/boot/imx8mp-var-dart-dt8mcustomboard-vc-mipi-isi-csi0.dtb
/boot/imx8mp-var-dart-dt8mcustomboard-vc-mipi-isp-csi0-csi1.dtb
/boot/imx8mp-var-dart-dt8mcustomboard-vc-mipi-isi-csi0-csi1.dtb
/boot/imx8mp-var-dart-dt8mcustomboard-vc-mipi-isi-csi1.dtb
```

You have to set the uboot variable FDT_FILE to one of these files. 

### Toradex

In the case of a toradex system a DTBO file is already added to /boot/overlays.txt. So the 
system already is setup properly.

```
$ find /boot/overlays -name *vc_mipi*
/boot/overlays/verdin-imx8mp_vc_mipi_isp_overlay.dtbo
/boot/overlays/verdin-imx8mp_vc_mipi_isi_overlay.dtbo
```

## Select a DTB or DTBO

The easiest way to setup the device tree is to use one of these command

```
$ ./test.sh isi 
$ ./test.sh isp
```

It sets on the above files and restarts the target automatically. Please check the test.sh script 
itselve to see which file is used. To check if you have setup the device tree properly you can do

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
CAM0: device=/dev/video2, csidev=/dev/v4l-subdev0, camdev=/dev/v4l-subdev3
CAM1: device=/dev/video3, csidev=/dev/v4l-subdev1, camdev=/dev/v4l-subdev2
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
$ ./test.sh run 4032 3040 YUYV 3
CAM0: device=/dev/video2, csidev=/dev/v4l-subdev0, camdev=/dev/v4l-subdev3
Format (width: 4032, height: 3040, pixelformat: YUYV, colorspace: )
[#0000, ts: 2548494, t:   0 ms, 4032, 3040, 8064, YUYV] (2016, 1520) 0000000000000000 0000000000000000 0000000000000000 
[#0001, ts: 2548544, t:  50 ms, 4032, 3040, 8064, YUYV] (2016, 1520) 0000000000000000 0000000000000000 0000000000000000 
[#0002, ts: 2548594, t:  50 ms, 4032, 3040, 8064, YUYV] (2016, 1520) 0000000000000000 0000000000000000 0000000000000000 
```

Perfect, your system is running properly.