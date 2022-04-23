FROM ubuntu:21.04

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y locales

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

WORKDIR /usr/src

SHELL ["/bin/bash", "-c"]

# Using: Python 3.9
# avoids issues with tobii-research library that only runs on Intel processors and requires Python 3.8

RUN apt-get install -y xpra xserver-xorg-video-dummy xvfb xauth libgl1-mesa-dri && \
    apt-get install -y libportaudio2 libwebkit2gtk-4.0-37 libasound2-dev alsa-utils alsa-oss && \
    apt-get install -y python3.9 python3-dev python3-venv && \
    apt-get install -y python3-pip python3-xlib && \
    apt-get install -y git wget && \
    apt-get install -y libusb-1.0-0-dev libsndfile1-dev && \
    apt-get install -y portaudio19-dev python3-pyaudio libportmidi-dev liblo-dev && \
    apt-get install -y pulseaudio pulseaudio-utils libpulse-dev && \
    apt-get install -y python3-pygame && \
    apt-get install -y libhdf5-serial-dev && \
    apt-get install -y libx11-dev libglib2.0-dev libgtk-3-dev libtiff-dev && \
    apt-get install -y ffmpeg && \
    apt-get install -y libgl1-mesa-glx mesa-utils x11-xserver-utils dbus-x11 && \
    apt-get install -y firefox libpci3 nano

RUN apt-get install -y libgstreamer-gl1.0-0 python3-gst-1.0 ubuntu-restricted-extras python-dev bison
RUN apt-get install -y autoconf libtool-bin swig freeglut3 freeglut3-dev
RUN apt-get install -y libgl1-mesa-dev libglu1-mesa-dev libgstreamer-plugins-base1.0-dev
RUN apt-get install -y libjpeg-dev libnotify-dev libsdl2-dev libsm-dev libwebkit2gtk-4.0-dev libxtst-dev

# https://discourse.psychopy.org/t/installation-headaches-and-partly-fixes-on-ubuntu-20-04/16476
RUN apt-get install -y libsdl2-2.0 libxcb-xinerama0

# create python3 VENV
#RUN python3 -m venv --system-site-packages ~/venv/py3
RUN python3 -m venv ~/venv/py3
RUN . ~/venv/py3/bin/activate && pip install --upgrade pip setuptools wheel numpy scipy

RUN . ~/venv/py3/bin/activate && python -v

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

# install psychtoolbox from source
RUN cd tmp && . ~/venv/py3/bin/activate && \
    git clone https://github.com/Psychtoolbox-3/Psychtoolbox-3.git && \
    cd Psychtoolbox-3 && \
    python setup.py install

# fix sound issues
COPY asound.conf /etc/asound.conf

# install remaining dependencies and PsychoPy
COPY requirements.txt ./
RUN . ~/venv/py3/bin/activate && pip install --no-cache-dir -r requirements.txt

# install PyQt5
#RUN . ~/venv/py3/bin/activate && pip install pyqt5-sip pyqt5-tools PyQt5==5.15.2
#RUN . ~/venv/py3/bin/activate && pip install pyqt6

# install psychopy from source
#RUN . ~/venv/py3/bin/activate && pip install psychopy
#RUN cd tmp && . ~/venv/py3/bin/activate && \
#    git clone https://github.com/psychopy/psychopy.git && \
#    cd psychopy && \
#    python setup.py install

# https://discourse.psychopy.org/t/installation-headaches-and-partly-fixes-on-ubuntu-20-04/16476/7
RUN groupadd --force psychtoolbox
RUN usermod -a -G psychtoolbox root

RUN echo "@psychtoolbox   -  nice       -20" > /etc/security/limits.d/99-psychopylimits.conf
RUN echo "@psychtoolbox   -  rtprio      50" >> /etc/security/limits.d/99-psychopylimits.conf
RUN echo "@psychtoolbox   -  memlock     unlimited" >> /etc/security/limits.d/99-psychopylimits.conf

#COPY start_psychopy.sh ./
#CMD ["sh", "start_psychopy.sh"]
