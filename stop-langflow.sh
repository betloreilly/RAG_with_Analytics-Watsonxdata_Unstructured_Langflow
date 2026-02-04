#!/bin/bash

# Stop Langflow Script

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ ! -f "langflow.pid" ]; then
    echo -e "${YELLOW}No langflow.pid file found${NC}"
    echo "Langflow may not be running, or was started manually"
    exit 1
fi

PID=$(cat langflow.pid)

if ps -p $PID > /dev/null 2>&1; then
    echo -e "${GREEN}Stopping Langflow (PID: $PID)...${NC}"
    kill $PID
    
    # Wait for process to stop
    WAIT_TIME=0
    while ps -p $PID > /dev/null 2>&1 && [ $WAIT_TIME -lt 10 ]; do
        sleep 1
        WAIT_TIME=$((WAIT_TIME + 1))
    done
    
    if ps -p $PID > /dev/null 2>&1; then
        echo -e "${RED}Process didn't stop gracefully, forcing...${NC}"
        kill -9 $PID
    fi
    
    echo -e "${GREEN}Langflow stopped${NC}"
    rm -f langflow.pid
else
    echo -e "${YELLOW}Langflow process (PID: $PID) is not running${NC}"
    rm -f langflow.pid
fi
