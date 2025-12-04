#!/data/data/com.termux/files/usr/bin/bash
# 🌐 PLAYIT.GG INSTALLER - Get Public URL
# Official tunneling for Minecraft server

echo ""
echo "╔═══════════════════════════════════════════════════╗"
echo "║            🌐 PLAYIT.GG TUNNEL INSTALLER          ║"
echo "║       Get Public URL for Your Server              ║"
echo "╚═══════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_status() {
    echo -e "${CYAN}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# ============================================================================
# CHECK EXISTING INSTALLATION
# ============================================================================

if command -v playit >/dev/null 2>&1; then
    echo -e "${GREEN}✅ playit.gg is already installed!${NC}"
    echo ""
    echo "To start tunnel: ${CYAN}playit${NC}"
    echo "To get version: ${CYAN}playit --version${NC}"
    echo ""
    
    read -p "Start tunnel now? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Starting playit.gg..."
        echo "Look for the claim URL below:"
        echo "${YELLOW}═══════════════════════════════════════════════════${NC}"
        playit
        exit 0
    else
        exit 0
    fi
fi

# ============================================================================
# INSTALLATION METHOD SELECTION
# ============================================================================

echo "Select installation method:"
echo ""
echo "1) ${GREEN}Official APT Repository${NC} (Recommended)"
echo "2) ${YELLOW}Direct Binary Download${NC} (Fallback)"
echo "3) ${RED}Skip Installation${NC}"
echo ""
read -p "Choose [1-3]: " method

# ============================================================================
# METHOD 1: OFFICIAL APT REPOSITORY
# ============================================================================

if [ "$method" = "1" ]; then
    print_status "Installing via official repository..."
    
    # Update system first
    pkg update -y
    pkg upgrade -y
    
    # Install dependencies
    print_status "Installing dependencies..."
    pkg install curl gnupg -y
    
    # Add GPG key
    print_status "Adding GPG key..."
    curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor > $PREFIX/etc/apt/trusted.gpg.d/playit.gpg 2>/dev/null
    
    if [ $? -ne 0 ]; then
        print_error "Failed to add GPG key"
        echo "Switching to direct download method..."
        method="2"
    else
        # Add repository
        print_status "Adding repository..."
        echo "deb [signed-by=$PREFIX/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" > $PREFIX/etc/apt/sources.list.d/playit-cloud.list
        
        # Update package list
        print_status "Updating package database..."
        pkg update 2>/dev/null
        
        # Install playit
        print_status "Installing playit.gg..."
        pkg install playit -y 2>/dev/null
        
        if command -v playit >/dev/null 2>&1; then
            print_success "Installed via official repository!"
        else
            print_error "Repository install failed"
            method="2"
        fi
    fi
fi

# ============================================================================
# METHOD 2: DIRECT BINARY DOWNLOAD
# ============================================================================

if [ "$method" = "2" ]; then
    print_status "Installing via direct download..."
    
    # Install wget if not present
    if ! command -v wget >/dev/null 2>&1; then
        pkg install wget -y
    fi
    
    print_status "Downloading latest playit.gg binary..."
    
    # Try to download latest ARM64 binary
    wget -q --show-progress -O $PREFIX/bin/playit \
        "https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-aarch64"
    
    if [ $? -eq 0 ]; then
        # Make executable
        chmod +x $PREFIX/bin/playit
        print_success "Downloaded successfully!"
    else
        print_error "Download failed!"
        echo ""
        echo "Try manual download:"
        echo "1. Visit: ${CYAN}https://playit.gg/download${NC}"
        echo "2. Download Linux ARM64 version"
        echo "3. Save to: ${YELLOW}$PREFIX/bin/playit${NC}"
        echo "4. Run: ${YELLOW}chmod +x $PREFIX/bin/playit${NC}"
        exit 1
    fi
fi

# ============================================================================
# METHOD 3: SKIP INSTALLATION
# ============================================================================

if [ "$method" = "3" ]; then
    echo ""
    echo "Installation skipped."
    echo "You can manually install playit.gg later."
    exit 0
fi

# ============================================================================
# VERIFY INSTALLATION
# ============================================================================

echo ""
print_status "Verifying installation..."

if command -v playit >/dev/null 2>&1; then
    # Get version
    VERSION=$(playit --version 2>/dev/null || echo "unknown version")
    
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║          ✅ PLAYIT.GG INSTALLED!                  ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
    echo "${GREEN}Version:${NC} $VERSION"
    echo ""
    
    # ============================================================================
    # CREATE STARTUP SCRIPTS
    # ============================================================================
    
    print_status "Creating startup scripts..."
    
    # Script 1: Simple start
    cat > start-tunnel.sh << 'EOF'
#!/bin/bash
echo "🌐 Starting playit.gg tunnel..."
echo "Look for the claim URL below!"
echo ""
echo "📝 Important:"
echo "1. Copy the URL that appears"
echo "2. Open it in browser"
echo "3. Claim your tunnel"
echo "4. Share the public URL with friends!"
echo ""
echo "═══════════════════════════════════════════════════"
playit
EOF
    chmod +x start-tunnel.sh
    
    # Script 2: Background mode
    cat > tunnel-background.sh << 'EOF'
#!/bin/bash
echo "🌐 Starting playit.gg in background..."
echo "Check logs: ~/playit.log"
echo ""
playit > ~/playit.log 2>&1 &
TUNNEL_PID=$!
echo "✅ Tunnel started (PID: $TUNNEL_PID)"
echo ""
echo "📋 Commands:"
echo "  View logs: tail -f ~/playit.log"
echo "  Stop tunnel: kill $TUNNEL_PID"
echo ""
echo "🔗 Look for URL in the log file!"
EOF
    chmod +x tunnel-background.sh
    
    # Script 3: Auto-start with Minecraft
    cat > start-minecraft-with-tunnel.sh << 'EOF'
#!/bin/bash
echo "🎮 Starting Minecraft server with public tunnel..."
echo ""
echo "Step 1: Starting Minecraft server..."
cd ~/minecraft-server
java -Xms3G -Xmx5G -jar server.jar nogui &
MC_PID=$!
echo "Minecraft PID: $MC_PID"
echo ""
echo "Step 2: Starting playit.gg tunnel..."
playit > ~/playit.log 2>&1 &
TUNNEL_PID=$!
echo "Playit PID: $TUNNEL_PID"
echo ""
echo "✅ Both services started!"
echo ""
echo "📋 Management:"
echo "  Minecraft logs: ~/minecraft-server/logs/latest.log"
echo "  Tunnel logs: ~/playit.log"
echo "  Stop all: kill $MC_PID $TUNNEL_PID"
EOF
    chmod +x start-minecraft-with-tunnel.sh
    
    print_success "Created startup scripts:"
    echo "  ${CYAN}./start-tunnel.sh${NC} - Simple tunnel start"
    echo "  ${CYAN}./tunnel-background.sh${NC} - Run in background"
    echo "  ${CYAN}./start-minecraft-with-tunnel.sh${NC} - Auto both"
    
    # ============================================================================
    # START TUNNEL PROMPT
    # ============================================================================
    
    echo ""
    echo "${YELLOW}🚀 QUICK START:${NC}"
    echo ""
    echo "Option 1: ${GREEN}Start tunnel now${NC}"
    echo "Option 2: ${CYAN}Show help and exit${NC}"
    echo ""
    read -p "Choose option (1 or 2): " start_choice
    
    if [ "$start_choice" = "1" ]; then
        echo ""
        echo "${YELLOW}═══════════════════════════════════════════════════${NC}"
        echo "Starting playit.gg tunnel..."
        echo "When URL appears, copy and open in browser!"
        echo "${YELLOW}═══════════════════════════════════════════════════${NC}"
        echo ""
        sleep 2
        playit
    else
        echo ""
        echo "${CYAN}📖 PLAYIT.GG QUICK GUIDE:${NC}"
        echo ""
        echo "1. ${GREEN}Start tunnel:${NC}"
        echo "   ${YELLOW}./start-tunnel.sh${NC}"
        echo ""
        echo "2. ${GREEN}Get public URL:${NC}"
        echo "   Run above command, copy the URL shown"
        echo "   Open it in browser and claim your tunnel"
        echo ""
        echo "3. ${GREEN}Run in background:${NC}"
        echo "   ${YELLOW}./tunnel-background.sh${NC}"
        echo "   Check URL in: ${CYAN}~/playit.log${NC}"
        echo ""
        echo "4. ${GREEN}Stop tunnel:${NC}"
        echo "   Press Ctrl+C if in foreground"
        echo "   Or: ${YELLOW}pkill -f playit${NC}"
        echo ""
        echo "${BLUE}🔗 Your friends can join using the public URL!${NC}"
    fi
    
else
    print_error "Installation failed!"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check internet connection"
    echo "2. Try manual download from:"
    echo "   ${CYAN}https://playit.gg/download${NC}"
    echo "3. Or use alternative: ngrok or localtunnel"
fi

echo ""
echo "${YELLOW}═══════════════════════════════════════════════════${NC}"
echo "Need help? Visit: ${CYAN}https://playit.gg/help${NC}"
echo "${YELLOW}═══════════════════════════════════════════════════${NC}"
