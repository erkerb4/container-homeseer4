## HomeSeer HS4 Container Image

This image containerizes the HomeSeer HS4 home automation software. This is a fork from E1iTeDa357/docker-homeseer4 image with few changes. 

Here are few changes/additions to this container image:
* You can set a specific version of HS4
* Mono patch could be applied to help loading ASPX pages on Linux.
* Latest version of S6 layer is pulled during build time

### Running the HomeSeer Container

```
docker/podman run -d \
    --name homeseer \
    -e LINUX_ASPX=true \
    -e HOMESEER_VERSION=4_1_10_0 \
    -v /opt/homeseer:/opt/homeseer \
    -v /etc/localtime:/etc/localtime:ro \
    -p 80:80 \
    -p 10200:10200 \
    -p 10300:10300 \
    -p 10401:10401 \
    -p 11000:11000 \
    --device /dev/ttyUSB0 \
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
    restart: unless-stopped
    environment:
      - TZ=America/New_York
      - LINUX_ASPX="true"
      - HOMESEER_VERSION=4_1_10_0
    volumes:
      - /opt/homeseer:/opt/homeseer
      - /etc/localtime:/etc/localtime:ro
    ports:
      - 8080:80
      - 10200:10200
      - 10300:10300
      - 10401:10401
      - 11000:11000
```

#### Options:  
`--name homeseer`: Names the container "homeseer".
`-e LINUX_ASPX` : Applies the mono fix to help load ASPX pages in Linux documented in [HomeSeer Forums](https://forums.homeseer.com/forum/homeseer-products-services/system-software-controllers/hs4-hs4pro-software/1415987-installing-hs4-on-linux?p=1416953#post1416953). Accepted values are true/false 
`-e HOMESEER_VERSION` : Downloads the version of HomeSeer4 release.
`-v /opt/homeseer:/opt/homeseer`: Bind mount /opt/homeseer (or the directory of your choice) into the container for persistent storage. This directory on the host will contain the complete HomeSeer installation and could be moved between systems if necessary (be sure to shutdown HomeSeer cleanly first, via Tools - System - Shutdown HomeSeer).  
`-v /etc/localtime:/etc/localtime:ro`: Ensure the container has the correct localtime.  
`-p 80:80`: Port 80, used by the HomeSeer web user interface (specify a different WebUI listen port by changing the first number, e.g. `-p 8080:80` to listen on port 8080 instead).  
`-p 10200:10200`: Port 10200, used by HSTouch.  
`-p 10300:10300`: Port 10300, used by myHS.  
`-p 10401:10401`: Port 10401, used by speaker clients.  
`--device /dev/ttyUSB0`: Pass a USB device at /dev/ttyUSB0 (i.e. a USB Zwave interface) into the container; replace `ttyUSB0` with the actual name of your device (e.g. ttyUSB1, ttyACM0, etc.).
`erkerb4/homeseer4:latest`: See below for descriptions of available image tags.

### Available Image Tags

| Tag | Description |
|-----|-------------|
| `latest` | The latest version of HomeSeer 4 for Linux including avahi-daemon and dbus-daemon for wider plugin support|


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

* Create a homeseer user, and run homeseer as that user
* Find a dynamic way to find the latest stable version of HomeSeer4
* Figure out a way to properly shutdown?
