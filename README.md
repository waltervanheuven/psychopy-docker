# PsychoPy running in a Docker container with Ubuntu

Instructions to create a [docker](https://www.docker.com) container that runs [PsychoPy](https://www.psychopy.org) on Ubuntu 21.04.

Please note that dockerfiles are work in progress. Tested so far only with an M1 MacBook Pro running macOS Monterey 12.3.1 and Docker 4.7.1. Dockerfile should also work on Intel computers.

## 1. Create docker image

```bash
# image with Ubuntu 21.04
# using Python venv with system-site-packages
# installs PsychoPy 2022.1.3
#
# GUI works but issues with PTB and ioHub
#
docker build -t psychopy -f Dockerfile/DockerfileSSP .

# image with Ubuntu 22.04
# PsychoPy 2022.1.2
#
# Unfortunately, PyQT5 fails to install.
# error: module 'sipbuild.api' has no attribute 'prepare_metadata_for_build_wheel'
#
# docker build -t psychopy -f Dockerfile/Dockerfile .
```

Please note that it will take a while to create the docker image.

## 2. Install X11

### macOS

Download and install latest [XQuartz](https://www.xquartz.org).

Enable `Allow connections from network clients` in X11 Preferences -> Security.

Add following line to file `~/.ssh/config`.

```txt
XAuthLocation /opt/X11/bin/xauth
```

Enable indirect OpenGL rendering with X11 forwarding

```sh
defaults write org.macosforge.xquartz.X11 enable_iglx -bool true
```

Unfortunately, XQuartz only supports OpenGL 1.4.

## 3. Start PsychoPy in Docker container

Start PsychoPy in docker container with shared local folder and network.

In `Terminal` or `iTerm` app:

1. Enable Xhost, which should start `XQuartz` on macOS

    ```sh
    xhost +
    ```

2. Set DISPLAY variable to computer IP address

    Replace XXX.XXX.XXX.XXX with IP address of host computer. Find IP address of your computer with `ifconfig`.

    ```sh
    # https://stackoverflow.com/questions/8529181/which-terminal-command-to-get-just-ip-address-and-nothing-else
    ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\  -f2

    export DISPLAY=XXX.XXX.XXX.XXX:0
    ```

3. Run docker container with shared folder and network

    ```sh
    docker run --rm -it \
        -v $(pwd):/usr/src/sharedfolder \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e PSYCH_XINITTHREADS=1 \
        -e XDG_RUNTIME_DIR=/tmp/ \
        -e RUNLEVEL=5 \
        --env="DISPLAY" \
        --net=host \
        --user psychopy \
        psychopy
    ```

    PsychoPy should now start.

## Audio

## Pass audio through to macOS

To get audio from the container passing through to macOS, you need to install `pulseaudio`.

```sh
brew install pulseaudio

# start pulseaudio daemon
pulseaudio --load=module-native-protocol-tcp --exit-idle-time=-1 --daemon
#pulseaudio --start

# https://askubuntu.com/questions/14077/how-can-i-change-the-default-audio-device-from-command-line
# find audio output sources
pacmd list-sinks

# set default audio output on macOS using index
# pacmd set-default-sink <index>
pacmd set-default-sink 1

# defaults can also be changed in file `default.pa` 
# edit file to change pulseaudio settings
# pico $(brew --prefix pulseaudio)/etc/pulse/default.pa
```

Start container then with this command.

Note: replace XXX.XXX.XXX.XXX with ip address of your computer (host).

```sh
# set pulse server address
export PULSE_SERVER=XXX.XXX.XXX.XXX

docker run --rm -it \
    --privileged \
    -v $(pwd):/usr/src/sharedfolder \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e PULSE_SERVER=$PULSE_SERVER \
    -e PULSE_COOKIE=/home/pulseaudio/.config/pulse/cookie \
    -v ~/.config/pulse/:/home/pulseaudio/.config/pulse/ \
    -e PSYCH_XINITTHREADS=1 \
    -e XDG_RUNTIME_DIR=/tmp/ \
    -e RUNLEVEL=2 \
    --env="DISPLAY" \
    --net=host \
    psychopy
```

Audio not yet working in PsychoPy but it works in other apps (e.g. Firefox). Check audio with Firefox running in the same Docker container (e.g. watch video on youtube).

```sh
docker run --rm -it \
    -v $(pwd):/usr/src/sharedfolder \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e PULSE_SERVER=$PULSE_SERVER \
    -e PULSE_COOKIE=/home/pulseaudio/.config/pulse/cookie \
    -v ~/.config/pulse/:/home/pulseaudio/.config/pulse/ \
    -e PSYCH_XINITTHREADS=1 \
    -e XDG_RUNTIME_DIR=/tmp/ \
    -e RUNLEVEL=2 \    
    --env="DISPLAY" \
    --net=host \
    psychopy firefox
```

## Issues

Errors:

```txt
PTB-CRITICAL: In call to PsychSetThreadPriority(): Failed to set new basePriority 2, tweakPriority 1, effective 1 [REALTIME] for thread (nil) provided!

PsychHID: KbQueueStart: Failed to switch to realtime priority [Operation not permitted].

RECORD extension not found. ioHub can not use python Xlib. Exiting....
```

## Debug

- Debug container if starting psychopy fails

    Start `bash` rather than `psychopy`.

    ```sh
    docker run --rm -it -v $(pwd):/usr/src/psychopy --env="DISPLAY" --net=host psychopy bash
    ```

    In container activate Python venv to start PsychoPy.

    ```sh
    source ~/venv/py3/bin/activate
    psychopy
    ```
