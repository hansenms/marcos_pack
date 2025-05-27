#!/bin/bash
# restart_server.sh - A simple, reliable script for managing the MaRCoS server

# Default configuration
SERVER_DIR="/workspaces/marcos_pack/marga/build"
SERVER_BIN="marga_sim"
SERVER_PORT=11111
OUTPUT_FORMAT="csv"
LOG_FILE="/tmp/marcos_server.log"
PID_FILE="/tmp/marcos_server.pid"

# Function to stop the server
stop_server() {
    echo "Checking for running server processes..."
    if pgrep -f $SERVER_BIN > /dev/null; then
        echo "Found server processes. Stopping them..."
        pkill -f $SERVER_BIN
        sleep 1
        # Make sure they're really gone
        pkill -9 -f $SERVER_BIN 2>/dev/null
        echo "Server stopped."
    else
        echo "No server processes found."
    fi

    # Really make sure the port is free
    echo "Making sure port $SERVER_PORT is available..."
    fuser -k $SERVER_PORT/tcp 2>/dev/null
    sleep 1
}

# Function to start the server
start_server() {
    # Check if server is already running
    if pgrep -f $SERVER_BIN > /dev/null; then
        echo "Server is already running. Use '$0 restart' to restart it."
        return 1
    fi

    echo "Starting MaRCoS server..."
    cd $SERVER_DIR || { echo "Server directory not found: $SERVER_DIR"; exit 1; }
    
    if [ ! -x "./$SERVER_BIN" ]; then
        echo "Server executable not found or not executable: ./$SERVER_BIN"
        exit 1
    fi
    
    # Run the server in the background and redirect output to log file
    nohup ./$SERVER_BIN $OUTPUT_FORMAT > $LOG_FILE 2>&1 &
    
    # Save the PID
    echo $! > $PID_FILE
    sleep 1
    
    # Check if the server is actually running
    if pgrep -f $SERVER_BIN > /dev/null; then
        echo "MaRCoS server started successfully. PID: $(cat $PID_FILE)"
        echo "Log file: $LOG_FILE"
    else
        echo "Failed to start MaRCoS server. Check the log file: $LOG_FILE"
        exit 1
    fi
}

# Function to show server status
status_server() {
    if pgrep -f $SERVER_BIN > /dev/null; then
        echo "MaRCoS server is running."
        echo "Process information:"
        ps -ef | grep -v grep | grep $SERVER_BIN
        echo "Port status:"
        netstat -tuln | grep $SERVER_PORT || echo "Port $SERVER_PORT is not in use"
    else
        echo "MaRCoS server is not running."
    fi
}

# Process command line arguments
case "$1" in
    start)
        start_server
        ;;
    stop)
        stop_server
        ;;
    restart)
        stop_server
        start_server
        ;;
    status)
        status_server
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        echo "If no argument is provided, restart is assumed."
        stop_server
        start_server
        ;;
esac

exit 0
