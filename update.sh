#!/data/data/com.termux/files/usr/bin/bash
# 🔄 UPDATER SCRIPT
# Updates all scripts and server

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║          🔄 UPDATER                          ║"
echo "║       Update scripts and server              ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

SERVER_DIR="$HOME/minecraft-server"

echo "📥 Checking for updates..."
echo ""

# Update from Git if cloned from repository
if [ -d ".git" ]; then
    echo "🔄 Updating from GitHub..."
    git pull
    if [ $? -eq 0 ]; then
        echo "✅ Scripts updated from GitHub"
    else
        echo "❌ Git update failed"
    fi
fi

# Update system packages
echo "📦 Updating system packages..."
pkg update -y
pkg upgrade -y

# Update Java
echo "☕ Checking Java..."
pkg install openjdk-21 -y

# Update playit.gg
echo "🌐 Updating playit.gg..."
if command -v playit >/dev/null 2>&1; then
    pkg install playit -y 2>/dev/null || echo "⚠️ Could not update playit"
fi

# Check server version
echo "🎮 Checking Minecraft server..."
if [ -f "$SERVER_DIR/server.jar" ]; then
    echo "   Current server installed"
    echo "   To update server, delete server.jar and run setup again"
fi

# Refresh permissions
echo "🔧 Refreshing permissions..."
chmod +x *.sh

echo ""
echo "✅ UPDATE COMPLETE!"
echo ""
echo "📋 What was updated:"
echo "   • System packages"
echo "   • Java runtime"
echo "   • Scripts (if from Git)"
echo "   • Playit.gg (if installed)"
echo ""
echo "🎮 Restart server for changes to take effect."
echo ""
