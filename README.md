[![Docker Repository on Quay](https://quay.io/repository/erkerb4/homeseer4/status "Docker Repository on Quay")](https://quay.io/repository/erkerb4/homeseer4)  

## HomeSeer HS4 Container Image

This image containerizes the HomeSeer HS4 home automation software.  

Here are few changes/additions to this container image:
* You can set a specific version of HS4
* Mono patch could be applied to help loading ASPX pages on Linux
* Latest version of S6 layer is pulled during build time
* Ability to run HomeSeer with unpriviledged account in the container
* HS is configured to run on a unpriv port within container

### Running the HomeSeer Container

#### Running with docker/podman run

```
docker/podman run -d \
    --name homeseer \
    --hostname homeseer \
    -e LINUX_ASPX=true \
    -e HOMESEER_VERSION=4_1_10_0 \
    -e HS_RUNASUSER=true \ ## optional, explanation below
    -e PUID=1001 \ ## optional, explanation below
    -e PGID=1001 \ ## optional, explanation below
    -e USER_NAME=homeseer \ ## optional, explanation below
    -v /opt/homeseer:/homeseer \
    -v /etc/localtime:/etc/localtime:ro \
    -p 1080:1080 \  ## WebUI will respond on 1080
    -p 10200:10200 \
    -p 10300:10300 \
    -p 10401:10401 \
    -p 11000:11000 \
    --device /dev/ttyACM0 \ ## Your USB mount may differ
    quay.io/erkerb4/homeseer4:latest
```
### Running the HomeSeer Container with docker-compose

This is a copy of docker-compose-template.yaml. You can use [podman-compose](https://github.com/containers/podman-compose)

```
version: '2.4'

services:
  homeseer:
    image: quay.io/erkerb4/homeseer4:latest
    hostname: homeseer
    environment:
      - TZ=America/New_York
      - LINUX_ASPX="true"
      - HOMESEER_VERSION=4_1_10_0
      - HS_RUNASUSER=true
      - PUID=1001
      - PGID=1001
      - USER_NAME=homeseer
    volumes:
      - /opt/homeseer:/homeseer
      - /etc/localtime:/etc/localtime:ro
    devices:
      - /dev/ttyACM0:/dev/ttyACM0
    ports:
      - 1080:1080     ## WebUI will respond on port 8080
      - 10200:10200
      - 10300:10300
      - 10401:10401
      - 11000:11000
```

#### Options:  
`--name homeseer`: Names the container "homeseer"  
`--hostname homeseer`: Configures the hostname of the container instance to "homeseer"   
`-e LINUX_ASPX` : Applies the mono fix to help load ASPX pages in Linux documented in [HomeSeer Forums](https://forums.homeseer.com/forum/homeseer-products-services/system-software-controllers/hs4-hs4pro-software/1415987-installing-hs4-on-linux?p=1416953#post1416953). Accepted values are true/false  
`-e HOMESEER_VERSION` : Downloads the desired version of HomeSeer4 release to run in the container   
`-e HS_RUNASUSER` : This parameter configures a regular user account in the container, and runs HomeSeer software with that user. It is enabled by default. Accepts true/false. Make sure to follow "Setting udev rule for USB Device for homeseer" section   
`-e PUID` : for UserID, used if HS_RUNASUSER flag is set to true  
`-e PUID` : for GroupID, used if HS_RUNASUSER flag is set to true  
`-e USER_NAME` : Configures the name of the user account in the container. Used if HS_RUNASUSER flag is set to true and defaults to username homeseer  
`-v /opt/homeseer:/homeseer`: Mount /opt/homeseer (or the directory of your choice on your house) to /homeseer in container to persistent state. This directory on the host will contain the complete HomeSeer installation and could be moved between systems if necessary (be sure to shutdown HomeSeer cleanly first, via Tools - System - Shutdown HomeSeer)  
`-v /etc/localtime:/etc/localtime:ro`: Ensure the container has the correct localtime  
`-p 1080:1080`: Port 1080, used by the HomeSeer web user interface (specify a different WebUI listen port by changing the first number, e.g.)   
`-p 10200:10200`: Port 10200, used by HSTouch  
`-p 10300:10300`: Port 10300, used by myHS  
`-p 10401:10401`: Port 10401, used by speaker clients   
`--device /dev/ttyACM0`: Pass a USB device at /dev/ttyACM0 (i.e. a USB Zwave interface) into the container; replace `ttyACM0` with the actual name of your device (e.g. ttyUSB1, ttyACM0, etc.)   
`erkerb4/homeseer4:latest`: See below for descriptions of available image tags   

## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```

## Setting udev rule for USB Device for homeseer

If you are setting HS_RUNASUSER to true, you will need to configure this. By default, serial devices are mounted so that only root users can access the device. We need to add a udev rule to make them readable by non-root users. In this case, when homeseer runs as non-root user in the container, it is not be able to access the USB device (it'll get Permission Denied, because homeseer user is a regular user, and won't be able to access device that requires root). 

Create a file named /etc/udev/rules.d/99-zwavestick.rules on the host. Add the following line to that file:

KERNEL=="ttyACM0",MODE="0666"

MODE="0666" will give all users read/write (but not execute) permissions to your ttyUSB devices. This is the most permissive option, and you may want to restrict this further depending on your security requirements. You can read up on udev to learn more about controlling what happens when a device is plugged into a Linux gateway.

## WebUI Port Changes
To make it easier to run the container rootless, I've changed to port to listen to 1080.

You can create a UFW rules to forward 80-->1080, so that you can get to it without specifying a port number with your browser.

### Available Image Tags

| Tag | Description |
|-----|-------------|
| `latest` | The latest version of container environment to run HomeSeer4 software|
| `develop` | Tag used for experimentation, or updating logic/configuration. Changes will eventually get merged to master/latest branch|


### Updating HomeSeer

You can control the version of HS4 running with the container. Container is just the environment that HS4 needs to run. It makes it easier to control/maintain all the dependencies. When container runs for the first time, it will download and install desired version of HomeSeer4. When you update the version of HS4, it will download the desired version, and update the instance. Container is merely a shell for HS4, and I will update it regularly to ensure environment is up-to-date. To update HS4, do the following

`docker/podman stop homeseer` [or, whatever name you gave to the container via the `--name` parameter]  
`docker/podman rm homeseer` [or, whatever name you gave to the container via the `--name` parameter]  
Take the docker/podman run command above, and update -e HOMESEER_VERSION= parameter

...then re-create your container using the same command-line parameters used at first run. The new HomeSeer version will be downloaded and installed when the container is run. Your existing user data, plugins, etc., will be preserved.

### Updating Container

`docker/podman stop homeseer` [or, whatever name you gave to the container via the `--name` parameter]  
`docker/podman rm homeseer` [or, whatever name you gave to the container via the `--name` parameter]  
`docker/podman pull quay.io/erkerb4/homeseer4:latest` Take the docker/podman run command above, and update -e HOMESEER_VERSION= parameter

### Gotchas / Known Issues

HomeSeer is fundamentally a Windows program that runs under the Mono framework on Linux. As such, it does not correctly respond to Unix signals (e.g. SIGTERM, SIGKILL, etc. ). For this reason, the `docker/podman stop` command does not cleanly shutdown HomeSeer. Instead, shutdown HomeSeer cleanly via Tools - System - Shutdown HomeSeer, which will also stop the container.

HomeSeer will be installed when container is started for the first time. Starting/restarting the container will not trigger reinstallation. The only time HS is downloaded is when you update the HS4 release version.  

This image currently only runs on amd64/x86_64.

### Acknowledgments

This is a fork from E1iTeDa357/docker-homeseer4 image with few changes.

This image was inspired by @marthoc's HomeSeer image (on Docker Hub at marthoc/homeseer), and E1iTeDa357/docker-homeseer4. Thanks to @luck-y13 for updating DockerFile to latest version.

### Wish-List

* Find a dynamic way to find the latest stable version of HomeSeer4
* Figure out a way to properly shutdown?
* Find a better way for setting udev rule for USB Device for homeseer
* Backup HS instance to a seperate directory
