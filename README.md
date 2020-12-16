# DuetCam

This is mainly a rework of the `webcamd` service provided as part of [OctoPi](https://github.com/guysoft/OctoPi)
As such it is [licensed](LICENSE) under GPL v3.0 to comply with the OctoPi license.

It has been tweaked to play nice with the Raspberry Pi OS image [provided by Duet3D](https://duet3d.dozuki.com/Wiki/SBC_Setup_for_Duet_3) for use with the Duet 3 board in SBC mode.

## Install

```
cd DuetCam
sudo ./install.sh
```

## Configuration

Once installed there will be a config file located at `/home/pi/.config/webcamd.txt`
This file is near identical to the `/boot/octopi.txt` file provided for camera configuration with OctoPi.
It is very well documented so just follow the instructions provided in that file to update your stream config.

You can also setup multiple cameras on the same system by creating the folder `/home/pi/.config/webcamd.conf.d/` and copying `webcamd.txt` into that folder. Any `*.txt` file in that folder will be used to configure another camera.

**Note:** This could cause performance issues with Duet Web Control, use at your own risk!

## Start / Stop

You can start/stop/restart the service with:

```
sudo systemctl start webcamd.service
sudo systemctl stop webcamd.service
sudo systemctl restart webcamd.service
```

If you change the config as described above, simply use the restart option to have those changes take effect.

## Usage

Once the service is running, you should be able to go to `http://<pi_ip_address>:8080/` and you will be presented with a test page containing both a still frame and a live mjpg stream. You can access these directly via:

- `http://<pi_ip_address>:8080/action=snapshot`: A single frame captured at the time the image is requested. Refresh the image/page to capture a new image.
- `http://<pi_ip_address>:8080/action=stream`: A live mjpg formatted video stream from the camera. This can be embeded into any HTML page with nothing more than the `<img>` tag.

