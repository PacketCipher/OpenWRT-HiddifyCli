#!/bin/sh

CONF_FILE="/root/hiddify-conf.json"
LIVE_CONFIG_FILE="/root/hiddify-sub"
TMP_CONFIG_FILE="/tmp/hiddify-sub.new"
RUN_CMD="./HiddifyCli run --config $LIVE_CONFIG_FILE --hiddify $CONF_FILE"
# WEB_SECRET is not used in this script's logic after the proposed changes,
# but we keep it in case other parts of a larger system might rely on it being set by this script.
# If CONF_FILE itself might change, this would need to be re-evaluated.
if [ -f "$CONF_FILE" ]; then
    WEB_SECRET=$(jq -r '.["web-secret"]' "$CONF_FILE")
else
    echo "Warning: $CONF_FILE not found. WEB_SECRET not set."
    WEB_SECRET=""
fi

# Function to handle SIGUSR1 signal for configuration update
update_config() {
    echo "Received SIGUSR1. Starting configuration update..."

    # Download the new configuration
    # The SUB_URL variable is expected to be in the environment, set by the init script
    if [ -z "$SUB_URL" ]; then
        echo "Error: SUB_URL is not set. Cannot download new configuration."
        return
    fi

    echo "Downloading new configuration from $SUB_URL to $TMP_CONFIG_FILE..."
    curl -L -o "$TMP_CONFIG_FILE" "$SUB_URL"

    if [ ! -s "$TMP_CONFIG_FILE" ]; then
        echo "Error: Downloaded configuration file $TMP_CONFIG_FILE is empty or download failed."
        rm -f "$TMP_CONFIG_FILE" # Clean up empty file
        return
    fi

    # Basic validation: Check if it's a valid JSON (optional, requires jq)
    # if jq -e . "$TMP_CONFIG_FILE" >/dev/null 2>&1; then
    #    echo "Downloaded configuration is valid JSON."
    # else
    #    echo "Error: Downloaded configuration is not valid JSON. Aborting update."
    #    rm -f "$TMP_CONFIG_FILE"
    #    return
    # fi

    echo "Configuration downloaded successfully. Moving $TMP_CONFIG_FILE to $LIVE_CONFIG_FILE."
    mv "$TMP_CONFIG_FILE" "$LIVE_CONFIG_FILE"

    if [ $? -eq 0 ]; then
        echo "Configuration updated successfully. Restarting HiddifyCli..."
        # Kill HiddifyCli; the main loop will restart it.
        # Using pkill to ensure all instances are targeted if any.
        # The -f flag matches against the full argument list.
        pkill -f "HiddifyCli run --config $LIVE_CONFIG_FILE"
    else
        echo "Error: Failed to move $TMP_CONFIG_FILE to $LIVE_CONFIG_FILE."
    fi
}

# Trap SIGUSR1 and call update_config function
trap 'update_config' USR1

echo "Hiddify Watchdog started. PID: $$"
echo "Monitoring HiddifyCli. Ready to receive SIGUSR1 for config updates."

# Main loop to keep HiddifyCli running
while true; do
    # Check if HiddifyCli is running with the correct config file path
    # Using pgrep -f to match the command line arguments for more accuracy
    if ! pgrep -fl "HiddifyCli run --config $LIVE_CONFIG_FILE" &>/dev/null; then
        echo "HiddifyCli is not running or not using $LIVE_CONFIG_FILE. Restarting..."
        if [ -z "$SERVICE_DIR" ]; then
            echo "Error: SERVICE_DIR is not set. Cannot start HiddifyCli."
            sleep 60 # Wait before retrying to avoid rapid spinning if SERVICE_DIR is never set
            continue
        fi
        if [ ! -f "$LIVE_CONFIG_FILE" ]; then
            echo "Error: $LIVE_CONFIG_FILE does not exist. Cannot start HiddifyCli."
            echo "Please ensure the configuration file is in place or trigger an update."
            sleep 60 # Wait for config to appear
            continue
        fi
        (cd "$SERVICE_DIR" && nohup $RUN_CMD > /dev/null 2>&1 &)
        echo "HiddifyCli started."
    fi
    sleep 5
done
