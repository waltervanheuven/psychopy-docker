# start_psychopy.sh

export LIBGL_ALWAYS_INDIRECT=1

# venv
. ~/venv/py3/bin/activate

#┬ástarting pulseaudio needed
pulseaudio --start &

psychopy
