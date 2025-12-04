#!/data/data/com.termux/files/usr/bin/bash
# 📦 ULTIMATE MINECRAFT SERVER INSTALLER
# One-click setup for iQOO Neo 10R

echo ""
echo "╔═══════════════════════════════════════════════════╗"
echo "║     🎮 ULTIMATE MINECRAFT SERVER INSTALLER        ║"
echo "║           iQOO Neo 10R Edition                    ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${CYAN}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# ============================================================================
# STEP 1: SYSTEM PREPARATION
# ============================================================================

print_status "Step 1: Preparing Termux environment..."

# Request storage permission
echo ""
print_warning "Grant storage permission when prompted!"
termux-setup-storage
sleep 3

# Update and upgrade
print_status "Updating package database..."
pkg update -y && pkg upgrade -y

# Install essential tools
print_status "Installing essential tools..."
pkg install git wget curl tar screen nano -y

# ============================================================================
# STEP 2: INSTALL JAVA 21
# ============================================================================

print_status "Step 2: Installing Java 21..."

if command -v java >/dev/null 2>&1; then
    JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2)
    print_success "Java already installed: $JAVA_VERSION"
else
    print_status "Installing OpenJDK 21..."
    pkg install openjdk-21 -y
    
    if command -v java >/dev/null 2>&1; then
        JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2)
        print_success "Java installed: $JAVA_VERSION"
    else
        print_error "Java installation failed, trying alternative..."
        pkg install openjdk-21-jre -y
        
        if command -v java >/dev/null 2>&1; then
            print_success "Java installed via alternative method"
        else
            print_error "Failed to install Java. Manual installation required."
            echo "Run: pkg install openjdk-21"
            exit 1
        fi
    fi
fi

# ============================================================================
# STEP 3: SETUP SERVER DIRECTORY
# ============================================================================

print_status "Step 3: Setting up server directories..."

SERVER_DIR="$HOME/minecraft-server"
BACKUP_DIR="/storage/emulated/0/MinecraftBackups"

# Create directories
mkdir -p "$SERVER_DIR"
mkdir -p "$BACKUP_DIR/worlds"
mkdir -p "$BACKUP_DIR/configs"
mkdir -p "$SERVER_DIR/plugins"

print_success "Directories created:"
echo "  Server: $SERVER_DIR"
echo "  Backups: $BACKUP_DIR"

# ============================================================================
# STEP 4: DOWNLOAD MINECRAFT SERVER
# ============================================================================

print_status "Step 4: Downloading Minecraft Server..."

cd "$SERVER_DIR"

if [ -f "server.jar" ]; then
    size=$(du -h server.jar | cut -f1 2>/dev/null || echo "?MB")
    print_success "Server already exists ($size)"
else
    print_status "Downloading PaperMC 1.21.10 (latest stable)..."
    
    # Try official PaperMC API
    wget -q --show-progress -O server.jar \
        "https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar"
    
    if [ $? -ne 0 ]; then
        print_warning "Primary download failed, trying mirror..."
        wget -O server.jar \
            "https://cdn.modrinth.com/data/paper/versions/1.21.10-115/paper-1.21.10-115.jar"
    fi
    
    if [ -f "server.jar" ]; then
        size=$(du -h server.jar | cut -f1)
        print_success "Server downloaded ($size)"
    else
        print_error "Failed to download server jar"
        print_warning "Manual download required:"
        echo "  1. Visit: https://papermc.io/downloads"
        echo "  2. Download Paper 1.21.10"
        echo "  3. Save to: $SERVER_DIR/server.jar"
        exit 1
    fi
fi

# ============================================================================
# STEP 5: CREATE BASIC CONFIGURATION
# ============================================================================

print_status "Step 5: Creating server configuration..."

# Accept EULA
echo "eula=true" > eula.txt

# Create basic server.properties
cat > server.properties << 'EOF'
# iQOO Neo 10R Optimized Server
max-players=12
online-mode=false
server-port=25566
motd=🎮 iQOO Neo 10R Server
gamemode=survival
difficulty=normal
view-distance=8
simulation-distance=6
level-type=default
enable-rcon=false
enable-command-block=true
max-tick-time=30000
network-compression-threshold=192
max-world-size=10000
spawn-protection=8
allow-flight=true
allow-nether=true
hardcore=false
pvp=true
spawn-animals=true
spawn-monsters=true
spawn-npcs=true
generate-structures=true
resource-pack=
EOF

print_success "Configuration files created"

# ============================================================================
# STEP 6: MAKE ALL SCRIPTS EXECUTABLE
# ============================================================================

print_status "Step 6: Setting up scripts..."

# Go back to script directory
cd - >/dev/null

# Make all shell scripts executable
chmod +x *.sh 2>/dev/null

# Create a simple start script if not exists
if [ ! -f "start-server.sh" ]; then
    cat > start-server.sh << 'EOF'
#!/bin/bash
cd ~/minecraft-server
echo "Starting Minecraft Server..."
java -Xms3G -Xmx5G -jar server.jar nogui
EOF
    chmod +x start-server.sh
fi

# ============================================================================
# STEP 7: ENABLE WAKE LOCK
# ============================================================================

print_status "Step 7: Enabling wake lock (prevents sleep)..."
termux-wake-lock
print_success "Wake lock enabled (server won't sleep)"

# ============================================================================
# STEP 8: INSTALLATION COMPLETE
# ============================================================================

echo ""
echo "╔═══════════════════════════════════════════════════╗"
echo "║            INSTALLATION COMPLETE!                 ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""
print_success "✅ Minecraft Server is ready!"
echo ""

# Show connection info
IP=$(termux-wifi-connectioninfo 2>/dev/null | grep -o '"ip"[^,]*' | cut -d'"' -f4)
echo "${CYAN}🔗 LOCAL CONNECTION:${NC}"
echo "  IP: ${IP:-"Connect to WiFi first"}"
echo "  Port: 25566"
echo "  Connect: ${IP:-"your_ip"}:25566"
echo ""

echo "${YELLOW}📋 AVAILABLE COMMANDS:${NC}"
echo "  ${GREEN}./launch.sh${NC}        - Main menu (recommended)"
echo "  ${GREEN}./start-mc.sh${NC}      - Quick start server"
echo "  ${GREEN}./install-playit.sh${NC} - Get public URL"
echo "  ${GREEN}./mc-background.sh${NC} - Run 24/7 in background"
echo "  ${GREEN}./backup-mc.sh${NC}     - Backup manager"
echo "  ${GREEN}./mc-status.sh${NC}     - Check server status"
echo ""

echo "${BLUE}🚀 RECOMMENDED NEXT STEPS:${NC}"
echo "  1. Run ${CYAN}./launch.sh${NC} for easy menu"
echo "  2. Choose option 4 for public URL"
echo "  3. Share URL with friends!"
echo ""

echo "${YELLOW}⚠️  IMPORTANT NOTES:${NC}"
echo "  • Keep Termux open or use background mode"
echo "  • First startup may take 1-2 minutes"
echo "  • Backups auto-save to /storage/emulated/0/MinecraftBackups"
echo "  • Use Ctrl+C to stop server"
echo ""

# Ask to run launcher
read -p "Run launcher now? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f "launch.sh" ]; then
        ./launch.sh
    else
        ./start-mc.sh
    fi
else
    echo ""
    echo "Run ${CYAN}./launch.sh${NC} anytime to start!"
fi
