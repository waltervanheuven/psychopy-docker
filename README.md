# PsychoPy running in a Docker container

Instructions to create a [docker](https://www.docker.com) container that runs the latest version (v2021.2.3) of [PsychoPy](https://www.psychopy.org).

Container should work on Intel (x64) and Arm (aarch64/ARM64/Apple Silicon) computers.

Note. This is work in progress. Tested so far only on an M1 Mac.

## 1. Creating docker image

```bash
docker build -t psychopy -f Dockerfile/Dockerfile .
```

Please note that this image will take a while to create.

## 2. Install X11

### macOS

Download and install latest [XQuartz](https://www.xquartz.org).

Enable `Allow connections from network clients` in X11 Preferences -> Security.

Add `XAutLocation` to `./ssh.config`:

```txt
XAuthLocation /opt/X11/bin/xauth
```

## 3. Start PsychoPy in Docker container

Start PsychoPy in docker container with shared local folder and network.

Type in `Terminal` app:

1. Check enable_iglx is 1

    ```sh
    # mac
    # check if enable_iglx is 1
    defaults read org.xquartz.X11 enable_iglx
    defaults read org.macosforge.xquartz.X11 enable_iglx

    # both should be 1, if 0 set them to 1
    # defaults write org.xquartz.X11 enable_iglx -bool YES
    # defaults write org.macosforge.xquartz.X11 enable_iglx -bool true
    ```

2. Enable Xhost, which should start `XQuartz` on macOS

    ```sh
    xhost +
    ```

3. Set DISPLAY variable to computer IP address

    Replace <> with IP address. Find IP address computer with `ifconfig`.

    ```sh
    # https://stackoverflow.com/questions/8529181/which-terminal-command-to-get-just-ip-address-and-nothing-else
    ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\  -f2

    export DISPLAY=<computer IP address>:0
    ```

4. Run docker container.

    ```sh
    docker run --rm -it -v $(pwd):/usr/src/psychopy --env="DISPLAY" --net=host psychopy
    ```

    PsychoPy should now start.

## Audio

## Pass audio through to macOS

To get audio from the container passing through to macOS, you need to install `pulseaudio`.

```sh
brew install pulseaudio

# start pulseaudio daemon
pulseaudio --load=module-native-protocol-tcp --exit-idle-time=-1 --daemon
```

Start container then with this command.

```sh
docker run --rm -it \
    -e PULSE_SERVER=docker.for.mac.localhost \
    -v ~/.config/pulse:/home/pulseaudio/.config/pulse \
    -v $(pwd):/usr/src/psychopy \
    --env="DISPLAY" \
    --net=host \
    psychopy
```

Error...

```txt
Normally all extra capabilities would be dropped now, but that's impossible because PulseAudio was built without capabilities support
```

```sh
pico $(brew --prefix pulseaudio)/etc/pulse/default.pa
```

Still not working...

[Expose audio from docker info](https://stackoverflow.com/questions/40136606/how-to-expose-audio-from-docker-container-to-a-mac)

## Useful other commands

- Debug container if starting psychopy fails

    Start `bash` rather than `psychopy`.

    ```sh
    docker run --rm -it -v $(pwd):/usr/src/psychopy --env="DISPLAY" --net=host psychopy bash
    ```
