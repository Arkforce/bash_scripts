#!/bin/bash

# Telegram Bot Token
BOT_TOKEN="YOUR_TELEGRAM_BOT_TOKEN"
# Telegram Chat ID
CHAT_ID="YOUR_TELEGRAM_CHAT_ID"

# CPU threshold (in percentage)
CPU_THRESHOLD=80

# Function to send Telegram message
send_telegram_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$message" \
        -d parse_mode="Markdown"
}

# Function to get the process consuming the most CPU
get_top_process() {
    ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 2 | tail -n 1
}

# Main monitoring loop
while true; do
    # Get the current CPU usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

    # Check if CPU usage exceeds the threshold
    if (( $(echo "$CPU_USAGE >= $CPU_THRESHOLD" | bc -l) )); then
        # Get the top process consuming CPU
        TOP_PROCESS=$(get_top_process)

        # Prepare the message
        MESSAGE="🚨 *High CPU Usage Alert!* 🚨
        \n- CPU Usage: $CPU_USAGE%
        \n- Top Process:
        \n\`\`\`
        $TOP_PROCESS
        \`\`\`"

        # Send the message via Telegram
        send_telegram_message "$MESSAGE"
    fi

    # Wait for a minute before checking again
    sleep 60
done
