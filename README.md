# PsychoPy running in a Docker container

Instructions to create a [docker](https://www.docker.com) container that runs the latest version (v2021.2.3) of [PsychoPy](https://www.psychopy.org).

Container should work on Intel (x64) and Arm (aarch64/ARM64/Apple Silicon) computers.

Note. This is work in progress. Tested so far only on an M1 Mac.

## 1. Create docker image

```bash
docker build -t psychopy -f Dockerfile/Dockerfile .
```

Please note that this image will take a while to create.

## 2. Install X11

### macOS

Download and install latest [XQuartz](https://www.xquartz.org).

Enable `Allow connections from network clients` in X11 Preferences -> Security.

Add `XAuthLocation` to `./ssh.config`:

```txt
XAuthLocation /opt/X11/bin/xauth
```

## 3. Start PsychoPy in Docker container

Start PsychoPy in docker container with shared local folder and network.

Type in `Terminal` app:

1. enable_iglx (needed?)

    ```sh
    # mac
    # check if enable_iglx is 1
    defaults read org.xquartz.X11 enable_iglx
    defaults read org.macosforge.xquartz.X11 enable_iglx

    # both should be 1? if 0 set them to 1
    # defaults write org.xquartz.X11 enable_iglx -bool true
    # defaults write org.macosforge.xquartz.X11 enable_iglx -bool true
    ```

2. Enable Xhost, which should start `XQuartz` on macOS

    ```sh
    xhost +
    ```

3. Set DISPLAY variable to computer IP address

    Replace XXX.XXX.XXX.XXX with IP address of host computer. Find IP address of your computer with `ifconfig`.

    ```sh
    # https://stackoverflow.com/questions/8529181/which-terminal-command-to-get-just-ip-address-and-nothing-else
    ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\  -f2

    export DISPLAY=XXX.XXX.XXX.XXX:0
    ```

4. Run docker container with shared folder and network

    ```sh
    docker run --rm -it \
        -v $(pwd):/usr/src/sharedfolder \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        --env="DISPLAY" \
        --net=host \
        psychopy
    ```

    PsychoPy should now start.

## Audio

## Pass audio through to macOS

To get audio from the container passing through to macOS, you need to install `pulseaudio`.

```sh
brew install pulseaudio

# https://askubuntu.com/questions/14077/how-can-i-change-the-default-audio-device-from-command-line
# find audio output sources
pacmd list-sinks

# set default audio output on macOS
pacmd set-default-sink 1

# start pulseaudio daemon
pulseaudio --load=module-native-protocol-tcp --exit-idle-time=-1 --daemon

# defaults can also be changed in file `default.pa` 
# edit file to change pulseaudio settings
pico $(brew --prefix pulseaudio)/etc/pulse/default.pa
```

Start container then with this command.

Note: replace XXX.XXX.XXX.XXX with ip address of your computer (host).

```sh
# set pulse server address
export PULSE_SERVER=XXX.XXX.XXX.XXX

docker run --rm -it \
    -v $(pwd):/usr/src/sharedfolder \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e PULSE_SERVER=$PULSE_SERVER \
    -e PULSE_COOKIE=/home/pulseaudio/.config/pulse/cookie \
    -v ~/.config/pulse/:/home/pulseaudio/.config/pulse/ \
    --env="DISPLAY" \
    --net=host \
    psychopy
```

Audio not yet working in PsychoPy but it works in other apps (e.g. Firefox). Check audio with Firefox running in the same Docker container (e.g. watch video on youtube).

```sh
docker run --rm -it \
    -v $(pwd):/usr/src/sharedfolder \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e PULSE_SERVER=$($PULSE_SERVER) \
    -e PULSE_COOKIE=/home/pulseaudio/.config/pulse/cookie \
    -v ~/.config/pulse/:/home/pulseaudio/.config/pulse/ \
    --env="DISPLAY" \
    --net=host \
    psychopy firefox
```

## Issues

- Keys presses are not detected in PsychoPy.

## Debug

- Debug container if starting psychopy fails

    Start `bash` rather than `psychopy`.

    ```sh
    docker run --rm -it -v $(pwd):/usr/src/psychopy --env="DISPLAY" --net=host psychopy bash
    ```
