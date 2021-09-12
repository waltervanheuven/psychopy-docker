# start_psychopy.sh

export LIBGL_ALWAYS_INDIRECT=1

# starting pulseaudio needed
pulseaudio --start --system

# venv
. ~/venv/py3/bin/activate
psychopy
