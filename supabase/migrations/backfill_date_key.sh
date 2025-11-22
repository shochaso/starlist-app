#!/bin/bash
# Backfill script for ad_views date_key migration
# Run this after applying the 20251121_add_ad_views_logging_and_gacha_rpc.sql migration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Ad Views Date Key Backfill Script ===${NC}"
echo ""

# Check if SUPABASE_DB_URL is set
if [ -z "$SUPABASE_DB_URL" ]; then
  echo -e "${YELLOW}Warning: SUPABASE_DB_URL not set${NC}"
  echo "Please set SUPABASE_DB_URL environment variable or pass database URL as argument"
  echo "Usage: $0 [database_url]"
  echo ""
  
  if [ -z "$1" ]; then
    echo -e "${RED}Error: No database URL provided${NC}"
    exit 1
  fi
  
  DB_URL="$1"
else
  DB_URL="$SUPABASE_DB_URL"
fi

echo "Database URL: ${DB_URL:0:30}..." # Show first 30 chars only for security

# Function to run SQL
run_sql() {
  psql "$DB_URL" -c "$1"
}

echo ""
echo -e "${GREEN}Step 1: Checking migration status${NC}"
echo "----------------------------------------"

# Check if date_key_jst3 function exists
FUNCTION_EXISTS=$(run_sql "SELECT COUNT(*) FROM pg_proc WHERE proname = 'date_key_jst3';" -t | tr -d ' ')

if [ "$FUNCTION_EXISTS" -eq "0" ]; then
  echo -e "${RED}Error: date_key_jst3 function not found${NC}"
  echo "Please run the migration 20251121_add_ad_views_logging_and_gacha_rpc.sql first"
  exit 1
fi

echo -e "${GREEN}✓ date_key_jst3 function exists${NC}"

# Check if date_key column exists in ad_views
COLUMN_EXISTS=$(run_sql "SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'ad_views' AND column_name = 'date_key';" -t | tr -d ' ')

if [ "$COLUMN_EXISTS" -eq "0" ]; then
  echo -e "${RED}Error: date_key column not found in ad_views table${NC}"
  echo "Please run the migration 20251121_add_ad_views_logging_and_gacha_rpc.sql first"
  exit 1
fi

echo -e "${GREEN}✓ date_key column exists in ad_views${NC}"

echo ""
echo -e "${GREEN}Step 2: Analyzing existing data${NC}"
echo "----------------------------------------"

# Count total ad_views
TOTAL_AD_VIEWS=$(run_sql "SELECT COUNT(*) FROM ad_views;" -t | tr -d ' ')
echo "Total ad_views records: $TOTAL_AD_VIEWS"

# Count records without date_key
NULL_DATE_KEYS=$(run_sql "SELECT COUNT(*) FROM ad_views WHERE date_key IS NULL AND viewed_at IS NOT NULL;" -t | tr -d ' ')
echo "Records needing backfill: $NULL_DATE_KEYS"

if [ "$NULL_DATE_KEYS" -eq "0" ]; then
  echo -e "${GREEN}✓ No backfill needed - all records have date_key${NC}"
  
  # Check gacha_attempts
  echo ""
  echo "Checking gacha_attempts table..."
  NULL_GACHA_DATE_KEYS=$(run_sql "SELECT COUNT(*) FROM gacha_attempts WHERE date_key IS NULL;" -t | tr -d ' ')
  echo "gacha_attempts records needing backfill: $NULL_GACHA_DATE_KEYS"
  
  if [ "$NULL_GACHA_DATE_KEYS" -eq "0" ]; then
    echo -e "${GREEN}✓ All done! No backfill needed.${NC}"
    exit 0
  fi
fi

echo ""
echo -e "${YELLOW}Step 3: Performing backfill${NC}"
echo "----------------------------------------"
read -p "Continue with backfill? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Backfill cancelled"
  exit 0
fi

echo "Starting backfill..."

# Backfill ad_views.date_key
echo "Backfilling ad_views.date_key..."
run_sql "UPDATE ad_views SET date_key = public.date_key_jst3(viewed_at) WHERE date_key IS NULL AND viewed_at IS NOT NULL;" > /dev/null

UPDATED_AD_VIEWS=$(run_sql "SELECT COUNT(*) FROM ad_views WHERE date_key IS NOT NULL;" -t | tr -d ' ')
echo -e "${GREEN}✓ Updated ad_views: $UPDATED_AD_VIEWS records now have date_key${NC}"

# Backfill gacha_attempts.date_key
echo "Backfilling gacha_attempts.date_key..."
run_sql "UPDATE gacha_attempts SET date_key = public.date_key_jst3(date::timestamptz) WHERE date_key IS NULL;" > /dev/null

UPDATED_GACHA=$(run_sql "SELECT COUNT(*) FROM gacha_attempts WHERE date_key IS NOT NULL;" -t | tr -d ' ')
echo -e "${GREEN}✓ Updated gacha_attempts: $UPDATED_GACHA records now have date_key${NC}"

echo ""
echo -e "${GREEN}Step 4: Verification${NC}"
echo "----------------------------------------"

# Verify no null date_keys remain (where they should exist)
REMAINING_NULLS=$(run_sql "SELECT COUNT(*) FROM ad_views WHERE date_key IS NULL AND viewed_at IS NOT NULL;" -t | tr -d ' ')

if [ "$REMAINING_NULLS" -eq "0" ]; then
  echo -e "${GREEN}✓ Backfill completed successfully${NC}"
  echo -e "${GREEN}✓ All ad_views records with viewed_at now have date_key${NC}"
else
  echo -e "${RED}⚠ Warning: $REMAINING_NULLS records still have NULL date_key${NC}"
  echo "This may indicate records with NULL viewed_at timestamp"
fi

REMAINING_GACHA_NULLS=$(run_sql "SELECT COUNT(*) FROM gacha_attempts WHERE date_key IS NULL;" -t | tr -d ' ')

if [ "$REMAINING_GACHA_NULLS" -eq "0" ]; then
  echo -e "${GREEN}✓ All gacha_attempts records now have date_key${NC}"
else
  echo -e "${RED}⚠ Warning: $REMAINING_GACHA_NULLS gacha_attempts records still have NULL date_key${NC}"
fi

echo ""
echo -e "${GREEN}Step 5: Testing date_key function${NC}"
echo "----------------------------------------"

echo "Testing JST 3:00 boundary..."

# Test cases for date_key_jst3
TEST1=$(run_sql "SELECT public.date_key_jst3('2025-11-21 02:59:59+09'::timestamptz);" -t | tr -d ' ')
TEST2=$(run_sql "SELECT public.date_key_jst3('2025-11-21 03:00:00+09'::timestamptz);" -t | tr -d ' ')

if [ "$TEST1" == "2025-11-20" ] && [ "$TEST2" == "2025-11-21" ]; then
  echo -e "${GREEN}✓ date_key_jst3 function working correctly${NC}"
  echo "  2025-11-21 02:59:59 JST → $TEST1"
  echo "  2025-11-21 03:00:00 JST → $TEST2"
else
  echo -e "${RED}⚠ Warning: date_key_jst3 function may not be working as expected${NC}"
  echo "  Expected: 2025-11-20, Got: $TEST1"
  echo "  Expected: 2025-11-21, Got: $TEST2"
fi

echo ""
echo -e "${GREEN}=== Backfill Complete ===${NC}"
echo ""
echo "Summary:"
echo "  Total ad_views: $TOTAL_AD_VIEWS"
echo "  Backfilled ad_views: $NULL_DATE_KEYS"
echo "  Backfilled gacha_attempts: $NULL_GACHA_DATE_KEYS"
echo ""
echo "Next steps:"
echo "  1. Verify application behavior with new RPC functions"
echo "  2. Monitor ad view grant limits (3 per day per user)"
echo "  3. Check analytics queries with date_key"
echo ""
