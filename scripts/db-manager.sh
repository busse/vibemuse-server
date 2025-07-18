#!/bin/bash

# VibeMUSE Database Management Script
# This script provides utilities for managing the VibeMUSE cloud database

set -e

case "$1" in
    "migrate")
        echo "🔄 Running database migrations..."
        npx supabase db push
        ;;
    "generate-types")
        echo "📝 Generating TypeScript types..."
        npx supabase gen types typescript > types/supabase.ts
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
    *)
        echo "VibeMUSE Database Management (Cloud Only)"
        echo ""
        echo "Usage: $0 {migrate|generate-types|status|backup}"
        echo ""
        echo "Commands:"
        echo "  migrate         Run database migrations"
        echo "  generate-types  Generate TypeScript types from database"
        echo "  status          Show current Supabase status"
        echo "  backup          Create database backup"
        echo ""
        echo "Note: This script only works with cloud Supabase instances."
        echo "Local development database support has been removed."
        echo ""
        exit 1
        ;;
esac