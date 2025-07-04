#!/bin/bash
set -e

#Delete leftover server PID file so Rails doesn't crash
rm -f /app/tmp/pids/server.pid

#Run whatever command Docker was given (like starting Rails)
exec "$@"
