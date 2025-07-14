#!/bin/ash

# A script to repeatedly set the active proxy to "WarpInWarp" every minute.
# It runs in a continuous loop until manually stopped (e.g., with Ctrl+C).

# --- Configuration ---
# You can override these by setting environment variables before running the script.
# Example: API_URL="http://127.0.0.1:9090" ./set_warp_proxy_loop.sh

API_URL="${API_URL:-http://127.0.0.1:16756}"
BEARER_TOKEN="${BEARER_TOKEN:-hiddify-server-selector}"
PROXY_GROUP_NAME="${PROXY_GROUP_NAME:-select}"
TARGET_PROXY_NAME="WarpInWarp✅ § 1"
LOOP_INTERVAL_SECONDS=60

# --- Pre-flight Check ---
if ! command -v curl &> /dev/null; then
    echo "Error: 'curl' is not installed. Please install it to continue."
    exit 1
fi

# --- Graceful Shutdown ---
# This function will be called when the script receives an interrupt signal (Ctrl+C).
function shutdown() {
    echo -e "\n🛑 Interrupt received. Shutting down the loop gracefully."
    exit 0
}

# Trap the INT (Ctrl+C) and TERM signals and call the shutdown function.
trap shutdown INT TERM

echo "▶️  Starting proxy-setting loop."
echo "----------------------------------------"
echo "API URL:             $API_URL"
echo "Proxy Group:         $PROXY_GROUP_NAME"
echo "Target Proxy:        $TARGET_PROXY_NAME"
echo "Update Interval:     ${LOOP_INTERVAL_SECONDS}s"
echo "----------------------------------------"
echo "Press Ctrl+C to stop the script."

# --- Main Loop ---
while true; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 🔁 Attempting to set proxy to '$TARGET_PROXY_NAME'..."

    # Send the PUT request to change the proxy.
    http_status=$(curl -s -o /dev/null -w "%{http_code}" \
        --connect-timeout 5 --max-time 10 \
        -X PUT \
        -H "Authorization: Bearer" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$TARGET_PROXY_NAME\"}" \
        "$API_URL/proxies/$PROXY_GROUP_NAME"
    )

    # Check the response status code.
    if [ "$http_status" -ge 200 ] && [ "$http_status" -lt 300 ]; then
        echo "✅ Success! API responded with status $http_status."
    else
        echo "❌ Failure. API responded with an error (status: $http_status)."
    fi

    echo "--- Waiting for $LOOP_INTERVAL_SECONDS seconds before next attempt... ---"
    sleep "$LOOP_INTERVAL_SECONDS"
done
