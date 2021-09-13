FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /usr/src

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y python3-pip && \
    apt-get install -y python3.8-venv && \
    apt-get install -y git wget && \
    apt-get install -y libusb-1.0-0-dev libasound2-dev libsndfile1-dev && \
    apt-get install -y portaudio19-dev python3-pyaudio libportmidi-dev liblo-dev && \
    apt-get install -y pulseaudio pulseaudio-utils && \
    apt-get install -y python3-pygame && \
    apt-get install -y libhdf5-serial-dev && \
    apt-get install -y libx11-dev libglib2.0-dev libgtk-3-dev libtiff-dev && \
    apt-get install -y qt5-default ffmpeg && \
    apt-get install -y libgl1-mesa-glx mesa-utils x11-xserver-utils dbus-x11 xauth && \
    apt-get install -y firefox libpci3

# create python3 VENV
RUN python3 -m venv --system-site-packages ~/venv/py3
RUN . ~/venv/py3/bin/activate && pip install --upgrade pip setuptools wheel

# install portaudio python library from source
RUN mkdir tmp
RUN cd tmp && git clone https://github.com/PortAudio/portaudio.git && \
    cd portaudio && \
    ./configure && make

# install pyo python library from source
RUN cd tmp && . ~/venv/py3/bin/activate && \
    git clone https://github.com/belangeo/pyo.git && \
    cd pyo && \
    python setup.py install

# install remaining dependencies and PsychoPy
COPY requirements.txt ./
RUN . ~/venv/py3/bin/activate && pip install --no-cache-dir -r requirements.txt

COPY start_psychopy.sh ./
CMD ["sh", "start_psychopy.sh"]
