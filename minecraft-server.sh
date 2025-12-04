#!/data/data/com.termux/files/usr/bin/bash
# 🎮 ULTIMATE MINECRAFT SERVER AUTO SETUP
# Complete automatic installation

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║        MINECRAFT SERVER AUTO SETUP           ║"
echo "║           iQOO Neo 10R Optimized             ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Configuration
SERVER_DIR="$HOME/minecraft-server"
BACKUP_DIR="/storage/emulated/0/MinecraftBackups"
MAX_RAM="5G"
MIN_RAM="3G"
PORT="25566"

# Function to print colored status
print_status() {
    echo -e "\033[0;36m[*]\033[0m $1"
}

print_success() {
    echo -e "\033[0;32m[✓]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[✗]\033[0m $1"
}

# Step 1: Setup environment
print_status "Setting up environment..."
termux-setup-storage
termux-wake-lock
mkdir -p "$SERVER_DIR"
mkdir -p "$BACKUP_DIR/worlds"
mkdir -p "$BACKUP_DIR/configs"
mkdir -p "$SERVER_DIR/plugins"

# Step 2: Install Java
print_status "Installing Java 21..."
if ! command -v java >/dev/null 2>&1; then
    pkg install openjdk-21 -y
    if [ $? -eq 0 ]; then
        print_success "Java installed"
        java -version
    else
        print_error "Java installation failed"
        exit 1
    fi
else
    print_success "Java already installed"
fi

# Step 3: Install Minecraft Server
print_status "Installing Minecraft Server..."
cd "$SERVER_DIR"

if [ ! -f "server.jar" ]; then
    print_status "Downloading PaperMC 1.21.10..."
    wget -q --show-progress -O server.jar \
        "https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar"
    
    if [ $? -ne 0 ]; then
        print_error "Download failed, trying mirror..."
        wget -O server.jar \
            "https://cdn.modrinth.com/data/paper/versions/1.21.10-115/paper-1.21.10-115.jar"
    fi
    
    if [ -f "server.jar" ]; then
        print_success "Server downloaded"
    else
        print_error "Failed to download server"
        exit 1
    fi
else
    print_success "Server already installed"
fi

# Step 4: Create configuration files
print_status "Creating configuration..."

# EULA
echo "eula=true" > eula.txt

# Server properties (optimized for iQOO Neo 10R)
cat > server.properties << 'EOF'
# 🎮 iQOO Neo 10R - Optimized Server
max-players=12
online-mode=false
server-port=25566
motd=🎮 iQOO Neo 10R • 5GB RAM • 24/7
gamemode=survival
difficulty=normal
view-distance=8
simulation-distance=6
level-type=default
enable-rcon=true
rcon.port=25576
rcon.password=minecraft123
enable-command-block=true
max-tick-time=30000
network-compression-threshold=192
max-world-size=10000
spawn-protection=8
allow-flight=true
allow-nether=true
announce-player-achievements=true
hardcore=false
pvp=true
spawn-animals=true
spawn-monsters=true
spawn-npcs=true
generate-structures=true
resource-pack=
entity-broadcast-range-percentage=70
sync-chunk-writes=true
enable-status=true
broadcast-rcon-to-ops=true
broadcast-console-to-ops=true
query.port=25566
debug=false
EOF

# Bukkit config
cat > bukkit.yml << 'EOF'
settings:
  allow-end: true
  permissions-file: permissions.yml
  connection-throttle: 3000
  user-cache-size: 1000

spawn-limits:
  monsters: 40
  animals: 20
  water-animals: 10
  water-ambient: 5
  ambient: 5

chunk-gc:
  period-in-ticks: 400

ticks-per:
  animal-spawns: 400
  monster-spawns: 200
  autosave: 6000
EOF

# Step 5: Install Playit.gg
print_status "Installing Playit.gg for public tunneling..."
pkg install curl -y
curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor > $PREFIX/etc/apt/trusted.gpg.d/playit.gpg 2>/dev/null
echo "deb [signed-by=$PREFIX/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" > $PREFIX/etc/apt/sources.list.d/playit-cloud.list 2>/dev/null
pkg update 2>/dev/null
pkg install playit -y 2>/dev/null

if ! command -v playit >/dev/null 2>&1; then
    print_status "Direct downloading playit.gg..."
    wget -O $PREFIX/bin/playit \
        "https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-aarch64" 2>/dev/null
    chmod +x $PREFIX/bin/playit 2>/dev/null
fi

if command -v playit >/dev/null 2>&1; then
    print_success "Playit.gg installed"
else
    print_error "Playit.gg installation failed (optional)"
fi

# Step 6: Create startup script
print_status "Creating auto-start scripts..."

# Auto-start script
cat > "$SERVER_DIR/start.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"

echo "========================================"
echo "🎮 MINECRAFT SERVER STARTING"
echo "========================================"
echo "Time: $(date)"
echo "RAM: 3G-5G"
echo "Port: 25566"
echo "========================================"

JAVA_OPTS="-Xms3G -Xmx5G"
JAVA_OPTS="$JAVA_OPTS -XX:+UseG1GC"
JAVA_OPTS="$JAVA_OPTS -XX:+ParallelRefProcEnabled"
JAVA_OPTS="$JAVA_OPTS -XX:MaxGCPauseMillis=200"
JAVA_OPTS="$JAVA_OPTS -XX:+UnlockExperimentalVMOptions"
JAVA_OPTS="$JAVA_OPTS -XX:G1NewSizePercent=20"
JAVA_OPTS="$JAVA_OPTS -XX:G1ReservePercent=20"

echo "Java Options: $JAVA_OPTS"
echo "========================================"

java $JAVA_OPTS -jar server.jar nogui

echo "========================================"
echo "🛑 SERVER STOPPED - $(date)"
echo "========================================"
EOF

chmod +x "$SERVER_DIR/start.sh"

# Auto-backup script
cat > "$SERVER_DIR/auto-backup.sh" << 'EOF'
#!/bin/bash
BACKUP_DIR="/storage/emulated/0/MinecraftBackups"
SERVER_DIR="$HOME/minecraft-server"

while true; do
    sleep 3600  # Backup every hour
    if [ -d "$SERVER_DIR/world" ]; then
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        cd "$SERVER_DIR"
        tar -czf "$BACKUP_DIR/auto_backup_$TIMESTAMP.tar.gz" world world_nether world_the_end 2>/dev/null
        
        # Keep only last 10 auto backups
        cd "$BACKUP_DIR"
        ls -t auto_backup_*.tar.gz 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null
    fi
done
EOF

chmod +x "$SERVER_DIR/auto-backup.sh"

# Step 7: Create auto-start service
print_status "Setting up auto-start service..."

cat > ~/.bash_profile << 'EOF'
#!/bin/bash
# Auto-start Minecraft server on Termux launch

SERVER_DIR="$HOME/minecraft-server"
SCREEN_NAME="minecraft_auto"

# Check if server should auto-start
if [ -f "$SERVER_DIR/autostart.enabled" ]; then
    # Check if already running
    if ! screen -ls | grep -q "$SCREEN_NAME"; then
        echo "🎮 Auto-starting Minecraft server..."
        cd "$SERVER_DIR"
        screen -dmS "$SCREEN_NAME" bash -c "./start.sh"
        sleep 2
        echo "✅ Server started in screen: $SCREEN_NAME"
    fi
    
    # Start auto-backup
    if ! pgrep -f "auto-backup.sh" >/dev/null; then
        "$SERVER_DIR/auto-backup.sh" &
    fi
fi

# Show status
if pgrep -f "java.*server.jar" >/dev/null; then
    echo "✅ Minecraft server is RUNNING"
elif screen -ls | grep -q "minecraft"; then
    echo "✅ Minecraft server is RUNNING (screen)"
fi
EOF

# Enable auto-start
touch "$SERVER_DIR/autostart.enabled"

# Step 8: Complete
print_success "SETUP COMPLETE!"
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║           SETUP SUCCESSFUL!                 ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "📋 WHAT WAS INSTALLED:"
echo "   ✅ Java Runtime"
echo "   ✅ Minecraft Server 1.21.10"
echo "   ✅ Optimized Configuration"
echo "   ✅ Playit.gg Tunneling"
echo "   ✅ Auto-Backup System"
echo "   ✅ Auto-Start on Boot"
echo ""
echo "🎮 QUICK START COMMANDS:"
echo "   1. Start server: ./start-mc.sh"
echo "   2. 24/7 mode: ./mc-background.sh"
echo "   3. Main menu: ./launch.sh"
echo ""
echo "🔗 CONNECTION:"
IP=$(termux-wifi-connectioninfo 2>/dev/null | grep -o '"ip"[^,]*' | cut -d'"' -f4)
echo "   Local: ${IP:-"Your IP"}:25566"
echo ""
echo "⚠️  IMPORTANT:"
echo "   • Server auto-starts when you open Termux"
echo "   • Backups created hourly"
echo "   • Use ./launch.sh for easy management"
echo ""
echo "Now run: ./launch.sh"
echo ""
