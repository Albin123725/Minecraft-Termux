#!/data/data/com.termux/files/usr/bin/bash
# 🚀 ULTIMATE MINECRAFT SERVER LAUNCHER
# Main menu for iQOO Neo 10R

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear_menu() {
    clear
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║    🎮 ULTIMATE MINECRAFT SERVER LAUNCHER     ║${NC}"
    echo -e "${BLUE}║           iQOO Neo 10R Edition               ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
    echo ""
}

show_menu() {
    clear_menu
    
    # Show quick status
    echo -e "${CYAN}📊 QUICK STATUS:${NC}"
    if pgrep -f "java.*server.jar" >/dev/null; then
        echo -e "   Server: ${GREEN}RUNNING${NC}"
    else
        echo -e "   Server: ${RED}STOPPED${NC}"
    fi
    
    if screen -ls | grep -q "minecraft"; then
        echo -e "   Background: ${GREEN}ACTIVE${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}📋 MAIN MENU:${NC}"
    echo ""
    echo "1) 🚀 FIRST TIME SETUP (Recommended)"
    echo "2) 🎮 START SERVER (Console)"
    echo "3) 🖥️  BACKGROUND MODE (24/7)"
    echo "4) 🌐 PLAYIT.GG TUNNEL (Public URL)"
    echo "5) 💾 BACKUP MANAGER"
    echo "6) 📊 SERVER STATUS"
    echo "7) 🔗 CONNECTION INFO"
    echo "8) ⚙️  UPDATE SCRIPTS"
    echo "9) 🛑 STOP SERVER"
    echo "0) 🚪 EXIT"
    echo ""
    echo -e "${CYAN}──────────────────────────────────────────────${NC}"
    
    read -p "Choose option [0-9]: " choice
    
    case $choice in
        1) first_time_setup ;;
        2) start_console ;;
        3) background_mode ;;
        4) playit_tunnel ;;
        5) backup_manager ;;
        6) show_status ;;
        7) connection_info ;;
        8) update_scripts ;;
        9) stop_server ;;
        0) 
            echo ""
            echo -e "${GREEN}👋 Goodbye! Your server can keep running.${NC}"
            exit 0
            ;;
        *) 
            echo -e "${RED}❌ Invalid option!${NC}"
            sleep 2
            show_menu
            ;;
    esac
}

first_time_setup() {
    clear_menu
    echo -e "${YELLOW}🚀 FIRST TIME SETUP${NC}"
    echo ""
    echo "This will install:"
    echo "• Java Runtime"
    echo "• Minecraft Server"
    echo "• Playit.gg Tunnel"
    echo "• Backup System"
    echo ""
    read -p "Continue? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./minecraft-server.sh
    else
        show_menu
    fi
}

start_console() {
    clear_menu
    echo -e "${YELLOW}🎮 STARTING SERVER...${NC}"
    echo ""
    ./start-mc.sh
    echo ""
    read -p "Press Enter to return to menu..."
    show_menu
}

background_mode() {
    clear_menu
    echo -e "${YELLOW}🖥️  STARTING BACKGROUND MODE...${NC}"
    echo ""
    echo "This will run server 24/7 with auto-restart."
    echo "You can close Termux and server will keep running."
    echo ""
    read -p "Continue? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./mc-background.sh
    fi
    read -p "Press Enter to return to menu..."
    show_menu
}

playit_tunnel() {
    clear_menu
    echo -e "${YELLOW}🌐 PLAYIT.GG TUNNEL${NC}"
    echo ""
    echo "This will give you a public URL for your server."
    echo "Anyone can join using the URL!"
    echo ""
    echo "1) Install Playit.gg"
    echo "2) Start Tunnel"
    echo "3) Back to Menu"
    echo ""
    read -p "Choose: " tunnel_choice
    
    case $tunnel_choice in
        1) 
            ./install-playit.sh
            read -p "Press Enter to continue..."
            show_menu
            ;;
        2)
            echo "Starting playit.gg..."
            playit &
            echo "✅ Playit started in background"
            echo "Check URL in logs: ~/minecraft-server/playit.log"
            sleep 3
            show_menu
            ;;
        3) show_menu ;;
        *) show_menu ;;
    esac
}

backup_manager() {
    ./backup-mc.sh
    show_menu
}

show_status() {
    ./mc-status.sh
    echo ""
    read -p "Press Enter to continue..."
    show_menu
}

connection_info() {
    clear_menu
    echo -e "${YELLOW}🔗 CONNECTION INFORMATION${NC}"
    echo ""
    
    IP=$(termux-wifi-connectioninfo 2>/dev/null | grep -o '"ip"[^,]*' | cut -d'"' -f4)
    
    echo -e "${CYAN}📱 LOCAL CONNECTION:${NC}"
    echo "   IP: ${IP:-"Unknown (connect to WiFi)"}"
    echo "   Port: 25566"
    echo ""
    
    echo -e "${CYAN}🌐 PUBLIC TUNNEL:${NC}"
    if pgrep -f playit >/dev/null; then
        echo "   Status: ${GREEN}ACTIVE${NC}"
        if [ -f ~/minecraft-server/playit.log ]; then
            URL=$(grep -o "https://playit.gg/[^ ]*" ~/minecraft-server/playit.log | tail -1)
            if [ -n "$URL" ]; then
                echo "   URL: $URL"
            else
                echo "   URL: Check playit.gg website"
            fi
        fi
    else
        echo "   Status: ${RED}INACTIVE${NC}"
        echo "   Run option 4 from main menu"
    fi
    
    echo ""
    echo -e "${CYAN}🎮 MINECRAFT CONNECT STRING:${NC}"
    echo "   ${IP:-"your_ip"}:25566"
    echo ""
    read -p "Press Enter to continue..."
    show_menu
}

update_scripts() {
    clear_menu
    echo -e "${YELLOW}🔄 UPDATING SCRIPTS...${NC}"
    echo ""
    
    if [ -f update.sh ]; then
        ./update.sh
    else
        echo "Update script not found."
        echo "Pulling from GitHub..."
        git pull
        chmod +x *.sh
        echo "✅ Scripts updated!"
    fi
    
    read -p "Press Enter to continue..."
    show_menu
}

stop_server() {
    clear_menu
    echo -e "${YELLOW}🛑 STOPPING SERVER...${NC}"
    echo ""
    
    # Stop screen sessions
    screen -XS minecraft_bg quit 2>/dev/null
    screen -XS mc_server quit 2>/dev/null
    
    # Stop Java processes
    pkill -f "java.*server.jar" 2>/dev/null
    
    # Stop playit
    pkill -f playit 2>/dev/null
    
    echo "✅ All server processes stopped"
    echo ""
    
    # Create backup
    read -p "Create backup before stopping? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Creating backup..."
        cd ~/minecraft-server
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        tar -czf "/storage/emulated/0/MinecraftBackups/stop_backup_$TIMESTAMP.tar.gz" world world_nether world_the_end 2>/dev/null
        echo "✅ Backup created"
    fi
    
    sleep 2
    show_menu
}

# Initial check for dependencies
if ! command -v java >/dev/null 2>&1 && [ ! -f ~/minecraft-server/server.jar ]; then
    clear_menu
    echo -e "${YELLOW}⚠️  FIRST TIME SETUP REQUIRED${NC}"
    echo ""
    echo "It looks like this is your first time."
    echo "Please run option 1 for automatic setup."
    echo ""
    read -p "Run first time setup now? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        first_time_setup
    else
        show_menu
    fi
else
    show_menu
fi
