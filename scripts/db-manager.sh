#!/bin/bash

# VibeMUSE Database Management Script
# This script provides utilities for managing the VibeMUSE database

set -e

case "$1" in
    "start")
        echo "🚀 Starting Supabase local development..."
        npx supabase start
        ;;
    "stop")
        echo "🛑 Stopping Supabase local development..."
        npx supabase stop
        ;;
    "reset")
        echo "🔄 Resetting database..."
        npx supabase db reset
        ;;
    "migrate")
        echo "🔄 Running database migrations..."
        npx supabase db push
        ;;
    "generate-types")
        echo "📝 Generating TypeScript types..."
        npx supabase gen types typescript --local > types/supabase.ts
        ;;
    "status")
        echo "📊 Checking Supabase status..."
        npx supabase status
        ;;
    "backup")
        echo "💾 Creating database backup..."
        timestamp=$(date +%Y%m%d_%H%M%S)
        npx supabase db dump > "backups/vibemuse_backup_${timestamp}.sql"
        echo "✅ Backup created: backups/vibemuse_backup_${timestamp}.sql"
        ;;
    "restore")
        if [ -z "$2" ]; then
            echo "❌ Usage: $0 restore <backup_file>"
            exit 1
        fi
        echo "🔄 Restoring from backup: $2"
        npx supabase db reset
        psql -h 127.0.0.1 -p 54322 -U postgres -d postgres < "$2"
        ;;
    *)
        echo "VibeMUSE Database Management"
        echo ""
        echo "Usage: $0 {start|stop|reset|migrate|generate-types|status|backup|restore}"
        echo ""
        echo "Commands:"
        echo "  start           Start local Supabase development server"
        echo "  stop            Stop local Supabase development server"
        echo "  reset           Reset database to initial state"
        echo "  migrate         Run database migrations"
        echo "  generate-types  Generate TypeScript types from database"
        echo "  status          Show current Supabase status"
        echo "  backup          Create database backup"
        echo "  restore <file>  Restore database from backup file"
        echo ""
        exit 1
        ;;
esac