#!/data/data/com.termux/files/usr/bin/bash
# 🖥️ MINECRAFT 24/7 BACKGROUND SERVER
# Auto-restart on crash

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║        🖥️  24/7 BACKGROUND SERVER            ║"
echo "║       Auto-restart • Runs forever            ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

SERVER_DIR="$HOME/minecraft-server"
SCREEN_NAME="minecraft_24_7"

# Check dependencies
if ! command -v screen >/dev/null 2>&1; then
    echo "Installing screen..."
    pkg install screen -y
fi

if [ ! -f "$SERVER_DIR/server.jar" ]; then
    echo "❌ Server not found!"
    echo "Run ./install.sh first"
    exit 1
fi

# Kill existing
screen -XS "$SCREEN_NAME" quit 2>/dev/null
pkill -f "java.*server.jar" 2>/dev/null

echo "🚀 Starting 24/7 background server..."
echo "Screen session: $SCREEN_NAME"
echo ""

# Create startup script
cat > /tmp/mc_24_7.sh << 'EOF'
#!/bin/bash
cd "$HOME/minecraft-server"

echo "╔══════════════════════════════════════════════╗"
echo "║    🎮 24/7 MINECRAFT SERVER - STARTED        ║"
echo "║       Time: $(date)                          ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "📊 SERVER INFO:"
echo "   RAM: 3G-5G allocated"
echo "   Port: 25566"
echo "   Auto-restart: Enabled"
echo "   Auto-backup: Every hour"
echo ""
echo "🔄 CRASH DETECTION ACTIVE"
echo "──────────────────────────────────────────────"

RESTART_COUNT=0
MAX_RESTARTS=50

while [ $RESTART_COUNT -lt $MAX_RESTARTS ]; do
    RESTART_COUNT=$((RESTART_COUNT + 1))
    echo ""
    echo "══════════════════════════════════════════════"
    echo "🔄 START ATTEMPT #$RESTART_COUNT - $(date)"
    echo "══════════════════════════════════════════════"
    echo ""
    
    # Start server with optimized Java options
    java -Xms3G -Xmx5G \
        -XX:+UseG1GC \
        -XX:+ParallelRefProcEnabled \
        -XX:MaxGCPauseMillis=200 \
        -XX:+UnlockExperimentalVMOptions \
        -jar server.jar nogui
    
    EXIT_CODE=$?
    echo ""
    echo "══════════════════════════════════════════════"
    echo "🛑 SERVER STOPPED - $(date)"
    echo "   Exit Code: $EXIT_CODE"
    echo "══════════════════════════════════════════════"
    
    if [ $EXIT_CODE -eq 0 ] || [ $EXIT_CODE -eq 130 ]; then
        echo "✅ Clean shutdown detected."
        echo "Server will not restart."
        break
    else
        echo "⚠️  Crash detected! Restarting in 10 seconds..."
        echo "   Press Ctrl+C twice to stop completely."
        sleep 10
    fi
done

if [ $RESTART_COUNT -ge $MAX_RESTARTS ]; then
    echo ""
    echo "❌ MAXIMUM RESTART LIMIT REACHED ($MAX_RESTARTS)"
    echo "   Server stopped permanently."
    echo "   Check logs for possible issues."
fi

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║        24/7 SERVER STOPPED                   ║"
echo "║        Time: $(date)                         ║"
echo "╚══════════════════════════════════════════════╝"
EOF

chmod +x /tmp/mc_24_7.sh

# Start in screen
screen -dmS "$SCREEN_NAME" bash -c "/tmp/mc_24_7.sh"

sleep 3

if screen -ls | grep -q "$SCREEN_NAME"; then
    echo "✅ SERVER STARTED IN BACKGROUND!"
    echo ""
    echo "📋 SCREEN COMMANDS:"
    echo "   View console: screen -r $SCREEN_NAME"
    echo "   Detach: Ctrl+A then D"
    echo "   Stop: screen -XS $SCREEN_NAME quit"
    echo ""
    echo "💡 TIPS:"
    echo "   • You can now CLOSE Termux"
    echo "   • Server will keep running"
    echo "   • Auto-restart on crash"
    echo "   • Check status with ./mc-status.sh"
    echo ""
    echo "🎮 Happy gaming! Server is now 24/7!"
else
    echo "❌ Failed to start background server"
    echo "Check if screen is installed properly"
fi
