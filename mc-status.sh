#!/data/data/com.termux/files/usr/bin/bash
# 📊 MINECRAFT SERVER STATUS CHECKER
# Shows everything about your server

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║          📊 SERVER STATUS                    ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

SERVER_DIR="$HOME/minecraft-server"

# Get IP address
get_ip() {
    IP=$(termux-wifi-connectioninfo 2>/dev/null | grep -o '"ip"[^,]*' | cut -d'"' -f4)
    echo "${IP:-"Not connected to WiFi"}"
}

# Check if process is running
is_running() {
    if pgrep -f "java.*server.jar" >/dev/null; then
        return 0
    else
        return 1
    fi
}

# Get player count from logs
get_player_count() {
    if [ -f "$SERVER_DIR/logs/latest.log" ]; then
        # Look for join/leave messages in last 5 minutes
        COUNT=$(grep -E "joined the game|left the game" "$SERVER_DIR/logs/latest.log" | tail -1 | grep -o "joined the game" | wc -l)
        echo "$COUNT"
    else
        echo "0"
    fi
}

# Get server uptime
get_uptime() {
    if is_running; then
        PID=$(pgrep -f "java.*server.jar")
        if [ -n "$PID" ]; then
            # Get start time from proc
            START_TIME=$(stat -c %Y /proc/$PID 2>/dev/null || echo 0)
            NOW=$(date +%s)
            UPTIME=$((NOW - START_TIME))
            
            if [ $UPTIME -gt 0 ]; then
                HOURS=$((UPTIME / 3600))
                MINUTES=$(( (UPTIME % 3600) / 60 ))
                SECONDS=$((UPTIME % 60))
                echo "${HOURS}h ${MINUTES}m ${SECONDS}s"
            else
                echo "Unknown"
            fi
        else
            echo "Unknown"
        fi
    else
        echo "Not running"
    fi
}

# Display status
echo "🔗 NETWORK INFORMATION:"
echo "──────────────────────────────────────────────"
echo "   Local IP: $(get_ip)"
echo "   Port: 25566"
echo "   Connect: $(get_ip):25566"
echo ""

echo "⚙️ INSTALLATION STATUS:"
echo "──────────────────────────────────────────────"
# Java
if command -v java >/dev/null 2>&1; then
    JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2)
    echo "   ✅ Java: $JAVA_VERSION"
else
    echo "   ❌ Java: Not installed"
fi

# Server
if [ -f "$SERVER_DIR/server.jar" ]; then
    SIZE=$(du -h "$SERVER_DIR/server.jar" | cut -f1)
    echo "   ✅ Server: Installed ($SIZE)"
else
    echo "   ❌ Server: Not installed"
fi

# Playit
if command -v playit >/dev/null 2>&1; then
    echo "   ✅ Playit.gg: Installed"
else
    echo "   ❌ Playit.gg: Not installed"
fi

echo ""

echo "🎮 SERVER STATUS:"
echo "──────────────────────────────────────────────"
if is_running; then
    echo "   ✅ Status: RUNNING"
    echo "   ⏱️  Uptime: $(get_uptime)"
    echo "   👥 Players: $(get_player_count) online"
    
    # Check screen sessions
    if screen -ls | grep -q "minecraft"; then
        echo "   🖥️  Mode: Background (screen)"
    else
        echo "   🖥️  Mode: Console"
    fi
else
    echo "   ❌ Status: STOPPED"
    
    # Check if in screen but crashed
    if screen -ls | grep -q "minecraft"; then
        echo "   ⚠️  Screen session exists but server not running"
    fi
fi

echo ""

echo "💾 STORAGE STATUS:"
echo "──────────────────────────────────────────────"
SERVER_SIZE=$(du -sh "$SERVER_DIR" 2>/dev/null | cut -f1 || echo "0B")
BACKUP_SIZE=$(du -sh "/storage/emulated/0/MinecraftBackups" 2>/dev/null | cut -f1 || echo "0B")

echo "   Server: $SERVER_SIZE"
echo "   Backups: $BACKUP_SIZE"

# Check world size
if [ -d "$SERVER_DIR/world" ]; then
    WORLD_SIZE=$(du -sh "$SERVER_DIR/world" 2>/dev/null | cut -f1 || echo "0B")
    echo "   World: $WORLD_SIZE"
fi

echo ""

echo "📈 PERFORMANCE:"
echo "──────────────────────────────────────────────"
# Show memory usage if server is running
if is_running; then
    PID=$(pgrep -f "java.*server.jar")
    if [ -n "$PID" ]; then
        MEM_MB=$(ps -o rss= -p $PID | awk '{print int($1/1024)}')
        echo "   Memory: ${MEM_MB}MB used"
    fi
fi

# Disk free space
DISK_FREE=$(df -h "$HOME" | tail -1 | awk '{print $4}')
echo "   Free space: $DISK_FREE"

echo ""

echo "🚀 QUICK ACTIONS:"
echo "──────────────────────────────────────────────"
echo "   1. Start server: ./start-mc.sh"
echo "   2. 24/7 mode: ./mc-background.sh"
echo "   3. Stop server: pkill -f java"
echo "   4. View logs: tail -f ~/minecraft-server/logs/latest.log"
echo ""

echo "╔══════════════════════════════════════════════╗"
echo "║          STATUS CHECK COMPLETE               ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
