#!/data/data/com.termux/files/usr/bin/bash
# 🎮 QUICK MINECRAFT SERVER START
# One-command startup for iQOO Neo 10R

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║          🎮 QUICK SERVER START               ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Setup
termux-setup-storage
termux-wake-lock

SERVER_DIR="$HOME/minecraft-server"
mkdir -p "$SERVER_DIR"
cd "$SERVER_DIR"

# Check Java
if ! command -v java >/dev/null 2>&1; then
    echo "☕ Installing Java..."
    pkg update -y
    pkg install openjdk-21 -y
fi

# Check server
if [ ! -f "server.jar" ]; then
    echo "📦 Downloading server..."
    wget -q --show-progress -O server.jar \
        "https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar"
    
    echo "eula=true" > eula.txt
    
    cat > server.properties << 'EOF'
max-players=12
online-mode=false
server-port=25566
motd=🎮 iQOO Neo 10R Server
gamemode=survival
view-distance=8
level-type=default
EOF
fi

# Get IP
IP=$(termux-wifi-connectioninfo 2>/dev/null | grep -o '"ip"[^,]*' | cut -d'"' -f4)

echo ""
echo "🔗 CONNECTION INFO"
echo "══════════════════════════════════════════"
echo "Local: ${IP:-"Your IP"}:25566"
echo "LAN: Same WiFi network"
echo ""
echo "🎮 Starting in 3 seconds..."
echo "Press Ctrl+C to stop"
echo "══════════════════════════════════════════"
echo ""

sleep 3

# Start with optimized settings
java -Xms3G -Xmx5G \
    -XX:+UseG1GC \
    -XX:+ParallelRefProcEnabled \
    -XX:MaxGCPauseMillis=200 \
    -jar server.jar nogui
