#!/data/data/com.termux/files/usr/bin/bash
# 💾 MINECRAFT BACKUP MANAGER
# Auto-cleanup • Restore • Schedule

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║          💾 BACKUP MANAGER                   ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

SERVER_DIR="$HOME/minecraft-server"
BACKUP_DIR="/storage/emulated/0/MinecraftBackups"
mkdir -p "$BACKUP_DIR/worlds"
mkdir -p "$BACKUP_DIR/configs"

show_menu() {
    clear
    echo ""
    echo "📋 BACKUP MENU"
    echo "══════════════════════════════════════════"
    echo "1) 💾 Quick Backup (World Only)"
    echo "2) 📦 Full Backup (World + Configs)"
    echo "3) 📋 List All Backups"
    echo "4) 🔄 Restore Backup"
    echo "5) ⚙️  Auto-Backup Settings"
    echo "6) 🗑️  Clean Old Backups"
    echo "7) 🏠 Back to Main Menu"
    echo "══════════════════════════════════════════"
    echo ""
    read -p "Choose [1-7]: " choice
    echo ""
    
    case $choice in
        1) quick_backup ;;
        2) full_backup ;;
        3) list_backups ;;
        4) restore_backup ;;
        5) auto_backup_settings ;;
        6) clean_backups ;;
        7) exit 0 ;;
        *) echo "❌ Invalid choice"; sleep 2; show_menu ;;
    esac
}

quick_backup() {
    echo "💾 Creating quick backup..."
    
    if [ ! -d "$SERVER_DIR/world" ]; then
        echo "❌ No world found to backup"
        return
    fi
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_FILE="$BACKUP_DIR/worlds/quick_$TIMESTAMP.tar.gz"
    
    cd "$SERVER_DIR"
    tar -czf "$BACKUP_FILE" world world_nether world_the_end
    
    if [ $? -eq 0 ]; then
        size=$(du -h "$BACKUP_FILE" | cut -f1)
        echo "✅ Quick backup created: $BACKUP_FILE ($size)"
    else
        echo "❌ Backup failed"
    fi
    
    read -p "Press Enter to continue..."
    show_menu
}

full_backup() {
    echo "📦 Creating full backup..."
    
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    
    # Backup world
    if [ -d "$SERVER_DIR/world" ]; then
        cd "$SERVER_DIR"
        tar -czf "$BACKUP_DIR/worlds/full_world_$TIMESTAMP.tar.gz" world world_nether world_the_end
        echo "✅ World backed up"
    fi
    
    # Backup configs
    cd "$SERVER_DIR"
    tar -czf "$BACKUP_DIR/configs/full_config_$TIMESTAMP.tar.gz" \
        server.properties bukkit.yml eula.txt ops.json plugins/ 2>/dev/null
    echo "✅ Configs backed up"
    
    echo ""
    echo "📦 FULL BACKUP COMPLETE"
    echo "   World: full_world_$TIMESTAMP.tar.gz"
    echo "   Config: full_config_$TIMESTAMP.tar.gz"
    
    read -p "Press Enter to continue..."
    show_menu
}

list_backups() {
    echo "📋 AVAILABLE BACKUPS"
    echo "══════════════════════════════════════════"
    echo ""
    echo "🌍 WORLD BACKUPS:"
    echo "──────────────────────────────────────────"
    ls -lh "$BACKUP_DIR/worlds/"*.tar.gz 2>/dev/null | while read line; do
        echo "   $line"
    done | head -20 || echo "   No world backups found"
    
    echo ""
    echo "⚙️ CONFIG BACKUPS:"
    echo "──────────────────────────────────────────"
    ls -lh "$BACKUP_DIR/configs/"*.tar.gz 2>/dev/null | while read line; do
        echo "   $line"
    done | head -10 || echo "   No config backups found"
    
    echo ""
    echo "📊 STATS:"
    WORLD_COUNT=$(ls "$BACKUP_DIR/worlds/"*.tar.gz 2>/dev/null | wc -l)
    CONFIG_COUNT=$(ls "$BACKUP_DIR/configs/"*.tar.gz 2>/dev/null | wc -l)
    echo "   Total world backups: $WORLD_COUNT"
    echo "   Total config backups: $CONFIG_COUNT"
    
    read -p "Press Enter to continue..."
    show_menu
}

restore_backup() {
    echo "🔄 RESTORE BACKUP"
    echo ""
    
    echo "Available world backups:"
    ls -1 "$BACKUP_DIR/worlds/"*.tar.gz 2>/dev/null
    
    echo ""
    read -p "Enter backup filename (or press Enter to cancel): " backup_file
    
    if [ -z "$backup_file" ]; then
        show_menu
        return
    fi
    
    if [ ! -f "$BACKUP_DIR/worlds/$backup_file" ]; then
        echo "❌ Backup file not found: $backup_file"
        read -p "Press Enter to continue..."
        show_menu
        return
    fi
    
    echo "⚠️  WARNING: This will replace your current world!"
    read -p "Continue? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        show_menu
        return
    fi
    
    echo "Stopping server..."
    pkill -f "java.*server.jar" 2>/dev/null
    sleep 3
    
    echo "Restoring world..."
    cd "$SERVER_DIR"
    rm -rf world world_nether world_the_end 2>/dev/null
    tar -xzf "$BACKUP_DIR/worlds/$backup_file"
    
    echo "✅ World restored from: $backup_file"
    echo ""
    echo "🎮 Start server to play with restored world!"
    
    read -p "Press Enter to continue..."
    show_menu
}

auto_backup_settings() {
    echo "⚙️ AUTO-BACKUP SETTINGS"
    echo ""
    echo "Auto-backup runs every hour and keeps:"
    echo "• Last 24 hourly backups"
    echo "• Last 7 daily backups"
    echo "• Last 4 weekly backups"
    echo ""
    echo "Current status:"
    if pgrep -f "auto-backup.sh" >/dev/null; then
        echo "✅ Auto-backup: ACTIVE"
    else
        echo "❌ Auto-backup: INACTIVE"
        echo "   Start with: ./minecraft-server.sh"
    fi
    
    echo ""
    echo "1) Start auto-backup now"
    echo "2) Stop auto-backup"
    echo "3) View backup schedule"
    echo "4) Back to menu"
    echo ""
    read -p "Choose: " choice
    
    case $choice in
        1)
            "$SERVER_DIR/auto-backup.sh" &
            echo "✅ Auto-backup started"
            ;;
        2)
            pkill -f "auto-backup.sh"
            echo "✅ Auto-backup stopped"
            ;;
        3)
            echo "📅 BACKUP SCHEDULE:"
            echo "   • Runs every hour"
            echo "   • Keeps last 24 hours"
            echo "   • Keeps last 7 days"
            echo "   • Keeps last 4 weeks"
            ;;
    esac
    
    read -p "Press Enter to continue..."
    show_menu
}

clean_backups() {
    echo "🗑️  CLEAN OLD BACKUPS"
    echo ""
    
    echo "Current backup counts:"
    WORLD_COUNT=$(ls "$BACKUP_DIR/worlds/"*.tar.gz 2>/dev/null | wc -l)
    CONFIG_COUNT=$(ls "$BACKUP_DIR/configs/"*.tar.gz 2>/dev/null | wc -l)
    echo "   World backups: $WORLD_COUNT"
    echo "   Config backups: $CONFIG_COUNT"
    
    echo ""
    echo "Cleanup options:"
    echo "1) Keep last 10 backups (delete older)"
    echo "2) Keep last 24 hours only"
    echo "3) Delete all backups (⚠️ Dangerous)"
    echo "4) Back to menu"
    echo ""
    read -p "Choose: " choice
    
    case $choice in
        1)
            cd "$BACKUP_DIR/worlds"
            ls -t world_*.tar.gz 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null
            cd "$BACKUP_DIR/configs"
            ls -t config_*.tar.gz 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null
            echo "✅ Kept last 10 backups"
            ;;
        2)
            find "$BACKUP_DIR" -name "*.tar.gz" -mtime +1 -delete 2>/dev/null
            echo "✅ Kept last 24 hours"
            ;;
        3)
            echo "⚠️  THIS WILL DELETE ALL BACKUPS!"
            read -p "Type 'DELETE' to confirm: " confirm
            if [ "$confirm" = "DELETE" ]; then
                rm -f "$BACKUP_DIR/worlds/"*.tar.gz 2>/dev/null
                rm -f "$BACKUP_DIR/configs/"*.tar.gz 2>/dev/null
                echo "✅ All backups deleted"
            else
                echo "❌ Cancelled"
            fi
            ;;
    esac
    
    read -p "Press Enter to continue..."
    show_menu
}

# Start menu
show_menu
