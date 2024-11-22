#!/bin/bash

# Check if Jupyter is running, start it if not
echo "---------------------------------------------------------------------------------"
pid=$(pgrep -f "jupyter-notebook")

if [[ -z $pid ]]; then
    echo "Jupyter is not running, starting on http://localhost:8888/tree"
    nohup jupyter notebook --ip 0.0.0.0 --port 8888 --IdentityProvider.token='' --no-browser --NotebookApp.token='' --NotebookApp.password='' >/dev/null 2>&1 &
else
    echo "Jupyter is already running, available on http://localhost:8888/tree"
    echo "PID=$pid"
fi

# Print the SSH command
echo ""
echo "Run this in a local shell to forward the Jupyter server to your local machine"
echo "ssh -v -N -L 8888:$(hostname):8888 $USER@polaris.alcf.anl.gov"
echo "---------------------------------------------------------------------------------"
