#!/usr/bin/env bash
# stdin→stdout。メール/電話/カードっぽい連番を置換
# Usage: cat file.txt | scripts/utils/redact.sh

sed -E \
  -e 's/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/<redacted-email>/g' \
  -e 's/\b(\+?\d{1,3}[-. ]?)?(\d{2,4}[-. ]?){2,4}\d{3,4}\b/<redacted-phone>/g' \
  -e 's/\b[0-9]{12,19}\b/<redacted-pan-like>/g'


# stdin→stdout。メール/電話/カードっぽい連番を置換
# Usage: cat file.txt | scripts/utils/redact.sh

sed -E \
  -e 's/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/<redacted-email>/g' \
  -e 's/\b(\+?\d{1,3}[-. ]?)?(\d{2,4}[-. ]?){2,4}\d{3,4}\b/<redacted-phone>/g' \
  -e 's/\b[0-9]{12,19}\b/<redacted-pan-like>/g'


