#!/usr/bin/env bash

# Simple code-server heartbeat check: If the heartbeat file hasn't been touched
# in the last 10 minutes _and_ there's an active editor instance running,
# terminate it.
# Per run only one instance (the oldest) is killed. If run at a set interval
# (i.e. every 5 minutes) should eventuelly churn through all active instances.
#
# This script is intended to be used with the (LinuxServer.io) code-server
# Docker container: s6-overlay Inside the container restarts the "listener"
# process (which we kill) automatically (thus keeping code-server available,
# but consuming minimal resources).

if [ $(($(date +%s) - 600)) -gt \
    "$(date +%s --reference ~/code-server/config/.local/share/code-server/heartbeat)" ] \
  && pgrep -o -f "node.*yarn/global/node_modules/code-server" ; then

  pkill -o -f "node /usr/local/bin/code-server"
fi
