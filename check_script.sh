#!/bin/ash

# ==============================================================================
#           Hiddify Proxy Monitor & Auto-Restart Script
#
# This script continuously checks if the proxy service is responsive. If the
# check fails, it will trigger a restart of the hiddify service.
# ==============================================================================

# --- Configuration ---
PROXY_HOST="127.0.0.1"
PROXY_PORT="2334"
# The full command to restart the service.
RESTART_COMMAND="/etc/init.d/hiddify restart"
# URL for a lightweight connectivity check. Google's 204 page is excellent for this.
CHECK_URL="http://www.gstatic.com/generate_204"
# How long to wait between successful checks (in seconds).
CHECK_INTERVAL=60
# How long to wait after a restart before checking again (in seconds).
# This gives the service enough time to come back online.
POST_RESTART_WAIT=600
# Curl connection timeout in seconds.
CURL_TIMEOUT=10


# --- State Variable ---
# This flag prevents multiple restart commands from running at the same time.
restarting=0

# --- Functions ---

# Checks if the proxy is responding correctly.
# It sends a request through the proxy and expects a "204 No Content" HTTP status code.
check_proxy() {
    echo "$(date) - INFO: Checking proxy ${PROXY_HOST}:${PROXY_PORT}..."
    # Use --proxy for an HTTP proxy. For a SOCKS5 proxy, change to --socks5.
    http_code=$(curl --silent --proxy "http://${PROXY_HOST}:${PROXY_PORT}" \
                     --output /dev/null \
                     --write-out "%{http_code}" \
                     --max-time "${CURL_TIMEOUT}" \
                     "${CHECK_URL}")

    if [ "$http_code" -eq 204 ]; then
        return 0 # Success
    else
        echo "$(date) - WARN: Proxy check failed. Expected HTTP code 204, but got '$http_code'."
        return 1 # Failure
    fi
}

# Restarts the hiddify service.
restart_service() {
    # If a restart is already in progress, do nothing.
    if [ "$restarting" -eq 1 ]; then
        echo "$(date) - INFO: Restart is already in progress. Skipping."
        return
    fi

    restarting=1
    echo "$(date) - CRITICAL: Restarting hiddify service due to proxy failure."

    # Execute the restart command and hide its output for cleaner logs.
    eval "${RESTART_COMMAND}" > /dev/null 2>&1

    echo "$(date) - INFO: Restart command sent. Waiting ${POST_RESTART_WAIT} seconds for service to initialize."
    sleep "${POST_RESTART_WAIT}"

    restarting=0
}


# --- Main Loop ---

echo "$(date) - INFO: Hiddify monitor script started."
echo "$(date) - INFO: Waiting ${POST_RESTART_WAIT} seconds before the first check..."
sleep "${POST_RESTART_WAIT}"

while true; do
    if ! check_proxy; then
        # If the check fails, call the restart function.
        # The restart function includes its own wait period.
        restart_service
    else
        # If the check succeeds, print a confirmation and wait for the next interval.
        echo "$(date) - INFO: Proxy check successful."
        sleep "${CHECK_INTERVAL}"
    fi
done