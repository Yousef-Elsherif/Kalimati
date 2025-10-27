#!/bin/bash

# Quick Setup Script for Floor Database
# Run this to get everything set up and view your database

set -e

echo "🚀 Floor Database Quick Setup"
echo "================================"
echo ""

# Step 1: Install dependencies
echo "📦 Step 1/4: Installing dependencies..."
flutter pub get

# Step 2: Generate Floor code
echo "🔨 Step 2/4: Generating Floor database code..."
flutter pub run build_runner build --delete-conflicting-outputs

# Step 3: Seed database
echo "🌱 Step 3/4: Seeding database with JSON data..."
dart run tools/seed_floor_db.dart

# Step 4: Check database
echo "✅ Step 4/4: Checking database..."
if [ -f "kalimaiti_app.db" ]; then
    echo ""
    echo "✅ Database created successfully!"
    echo "   Location: $(pwd)/kalimaiti_app.db"
    echo "   Size: $(ls -lh kalimaiti_app.db | awk '{print $5}')"
    echo ""
    echo "📊 Quick Stats:"
    sqlite3 kalimaiti_app.db "SELECT 'Users: ' || COUNT(*) FROM UserEntity; SELECT 'Packages: ' || COUNT(*) FROM PackageEntity; SELECT 'Words: ' || COUNT(*) FROM WordEntity;"
    echo ""
    echo "🎉 Setup complete! Now you can:"
    echo ""
    echo "   1. View in DB Browser for SQLite:"
    echo "      brew install --cask db-browser-for-sqlite"
    echo "      open -a 'DB Browser for SQLite' kalimaiti_app.db"
    echo ""
    echo "   2. Use the custom viewer tool:"
    echo "      dart run tools/view_db.dart"
    echo ""
    echo "   3. Use SQLite CLI:"
    echo "      sqlite3 kalimaiti_app.db"
    echo ""
else
    echo "❌ Database file not found. Something went wrong."
    exit 1
fi
