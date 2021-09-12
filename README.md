# PsychoPy running in a Docker container

Instructions to create a [docker](https://www.docker.com) container that runs the latest version (v2021.2.3) of [PsychoPy](https://www.psychopy.org).

Container should work on Intel (x64) and Arm (aarch64 / Apple Silicon) computers.

Note. This is work in progress. Tested so far only on an M1 Mac.

## Creating docker image

```bash
docker build -t psychopy -f Dockerfile/Dockerfile .
```

Please note that this image will take a while to create.

## Install X11

### macOS

Download and install latest [XQuartz](https://www.xquartz.org).

Enable `Allow connections from network clients` in X11 Preferences -> Security.

Add `XAutLocation` to `./ssh.config`:

```txt
XAuthLocation /opt/X11/bin/xauth
```

## Start PsychoPy in Docker container

Start PsychoPy in docker container with shared local folder and network.

In `Terminal`:

```bash
# mac
# check if enable_iglx is 1
defaults read org.xquartz.X11 enable_iglx
defaults read org.macosforge.xquartz.X11 enable_iglx

# both should be 1, if 0 set them to 1
# defaults write org.xquartz.X11 enable_iglx -bool YES
# defaults write org.macosforge.xquartz.X11 enable_iglx -bool true

# xhost + should start XQuartx on macOS
xhost +

# set DISPLAY, replace <computer IP address> with IP address
# find IP address computer with: `ifconfig en0`
export DISPLAY=<computer IP address>:0

# run docker container
docker run --rm -it -v $(pwd):/usr/src/psychopy --env="DISPLAY" --net=host psychopy
```

PsychoPy should now start. 

## Useful other commands

- Debug container if starting psychopy fails

    Start `bash` rather than `psychopy`.

    ```sh
    docker run --rm -it -v $(pwd):/usr/src/psychopy --env="DISPLAY" --net=host psychopy bash
    ```

- Remove docker build cache and unused containers/images:

    ```sh
    docker system prune
    ```
