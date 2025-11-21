---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---















# DKIM/DMARC DNS Validation Runbook

## Overview

This runbook describes the DKIM/DMARC DNS validation process for STARLIST email domains.

## Purpose

- Validate DKIM records for Google Workspace email authentication
- Validate DMARC records for email security policy enforcement
- Ensure DNS records are correctly configured before production email sending

## Prerequisites

- Node.js >= 20
- DNS access to the target domain
- Domain administrator access for DNS record management

## Usage

### Manual Check

```bash
npm run check:mail:dns
```

Or directly:

```bash
node scripts/check_mail_dns.mjs starlist.jp
```

### CI Integration

The script exits with code 0 on success, 1 on failure, making it suitable for CI pipelines.

## DKIM Validation

### What is DKIM?

DKIM (DomainKeys Identified Mail) is an email authentication method that allows the recipient to verify that an email was sent by an authorized sender for the domain.

### Google Workspace DKIM

For Google Workspace, DKIM records are typically:
- **Selector**: `google._domainkey`
- **Record Type**: TXT or CNAME
- **Target**: Must resolve to `googlehosted.com`

### Validation Process

1. Resolve `google._domainkey.<domain>` TXT record
2. Check if record contains `googlehosted.com`
3. Optionally resolve CNAME record (if present)
4. Verify CNAME target includes `googlehosted.com`

### Example DKIM Record

```
google._domainkey.starlist.jp TXT "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3..."
```

Or CNAME:

```
google._domainkey.starlist.jp CNAME ghs.googlehosted.com.
```

## DMARC Validation

### What is DMARC?

DMARC (Domain-based Message Authentication, Reporting & Conformance) is an email authentication protocol that builds on SPF and DKIM to prevent email spoofing.

### DMARC Record Format

DMARC records are TXT records at `_dmarc.<domain>` with the following tags:

- **p=**: Policy (none, quarantine, reject)
- **rua=**: Reporting URI for aggregate reports
- **ruf=**: Reporting URI for forensic reports (optional)
- **sp=**: Subdomain policy (optional)
- **pct=**: Percentage of messages to apply policy (optional)

### Validation Process

1. Resolve `_dmarc.<domain>` TXT record
2. Extract `p=` (policy) tag
3. Extract `rua=` (reporting URI) tag
4. Validate policy is one of: `none`, `quarantine`, `reject`

### Example DMARC Record

```
_dmarc.starlist.jp TXT "v=DMARC1; p=quarantine; rua=mailto:dmarc@starlist.jp; pct=100"
```

## Troubleshooting

### DKIM Failures

**Issue**: No TXT records found
- **Solution**: Create DKIM record in Google Workspace Admin Console
- **Steps**:
  1. Go to Google Workspace Admin Console
  2. Navigate to Apps > Google Workspace > Gmail
  3. Click "Authenticate email"
  4. Follow instructions to add DNS record

**Issue**: CNAME does not resolve to googlehosted.com
- **Solution**: Verify CNAME target is correct
- **Check**: Ensure Cloudflare DNS has "Proxy" disabled (gray cloud) for DKIM records

### DMARC Failures

**Issue**: Missing `p=` tag
- **Solution**: Add `p=` tag to DMARC record
- **Example**: `v=DMARC1; p=quarantine; rua=mailto:dmarc@starlist.jp`

**Issue**: Invalid policy value
- **Solution**: Use one of: `none`, `quarantine`, `reject`
- **Recommendation**: Start with `p=quarantine` for testing, then move to `p=reject` in production

## Cloudflare DNS Configuration

### Important Notes

- **DKIM records must have "Proxy" disabled** (gray cloud icon)
- **DMARC records must have "Proxy" disabled** (gray cloud icon)
- DNS changes may take up to 48 hours to propagate globally

### Steps to Disable Proxy

1. Log in to Cloudflare Dashboard
2. Select domain (e.g., `starlist.jp`)
3. Go to DNS > Records
4. Find DKIM/DMARC records
5. Click "Edit" (pencil icon)
6. Toggle "Proxy status" to "DNS only" (gray cloud)
7. Save changes

## Production Checklist

- [ ] DKIM record exists and validates
- [ ] DMARC record exists and validates
- [ ] Cloudflare proxy is disabled for DKIM/DMARC records
- [ ] DNS propagation verified (use `dig` or online tools)
- [ ] Test email sent and verified
- [ ] DMARC reports being received (check `rua=` email address)

## References

- [Google Workspace DKIM Setup](https://support.google.com/a/answer/174124)
- [DMARC Record Format](https://dmarc.org/wiki/FAQ)
- [Cloudflare DNS Documentation](https://developers.cloudflare.com/dns/)

---

**Last Updated**: 2025-11-08
**Maintainer**: SRE Team


## Overview

This runbook describes the DKIM/DMARC DNS validation process for STARLIST email domains.

## Purpose

- Validate DKIM records for Google Workspace email authentication
- Validate DMARC records for email security policy enforcement
- Ensure DNS records are correctly configured before production email sending

## Prerequisites

- Node.js >= 20
- DNS access to the target domain
- Domain administrator access for DNS record management

## Usage

### Manual Check

```bash
npm run check:mail:dns
```

Or directly:

```bash
node scripts/check_mail_dns.mjs starlist.jp
```

### CI Integration

The script exits with code 0 on success, 1 on failure, making it suitable for CI pipelines.

## DKIM Validation

### What is DKIM?

DKIM (DomainKeys Identified Mail) is an email authentication method that allows the recipient to verify that an email was sent by an authorized sender for the domain.

### Google Workspace DKIM

For Google Workspace, DKIM records are typically:
- **Selector**: `google._domainkey`
- **Record Type**: TXT or CNAME
- **Target**: Must resolve to `googlehosted.com`

### Validation Process

1. Resolve `google._domainkey.<domain>` TXT record
2. Check if record contains `googlehosted.com`
3. Optionally resolve CNAME record (if present)
4. Verify CNAME target includes `googlehosted.com`

### Example DKIM Record

```
google._domainkey.starlist.jp TXT "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3..."
```

Or CNAME:

```
google._domainkey.starlist.jp CNAME ghs.googlehosted.com.
```

## DMARC Validation

### What is DMARC?

DMARC (Domain-based Message Authentication, Reporting & Conformance) is an email authentication protocol that builds on SPF and DKIM to prevent email spoofing.

### DMARC Record Format

DMARC records are TXT records at `_dmarc.<domain>` with the following tags:

- **p=**: Policy (none, quarantine, reject)
- **rua=**: Reporting URI for aggregate reports
- **ruf=**: Reporting URI for forensic reports (optional)
- **sp=**: Subdomain policy (optional)
- **pct=**: Percentage of messages to apply policy (optional)

### Validation Process

1. Resolve `_dmarc.<domain>` TXT record
2. Extract `p=` (policy) tag
3. Extract `rua=` (reporting URI) tag
4. Validate policy is one of: `none`, `quarantine`, `reject`

### Example DMARC Record

```
_dmarc.starlist.jp TXT "v=DMARC1; p=quarantine; rua=mailto:dmarc@starlist.jp; pct=100"
```

## Troubleshooting

### DKIM Failures

**Issue**: No TXT records found
- **Solution**: Create DKIM record in Google Workspace Admin Console
- **Steps**:
  1. Go to Google Workspace Admin Console
  2. Navigate to Apps > Google Workspace > Gmail
  3. Click "Authenticate email"
  4. Follow instructions to add DNS record

**Issue**: CNAME does not resolve to googlehosted.com
- **Solution**: Verify CNAME target is correct
- **Check**: Ensure Cloudflare DNS has "Proxy" disabled (gray cloud) for DKIM records

### DMARC Failures

**Issue**: Missing `p=` tag
- **Solution**: Add `p=` tag to DMARC record
- **Example**: `v=DMARC1; p=quarantine; rua=mailto:dmarc@starlist.jp`

**Issue**: Invalid policy value
- **Solution**: Use one of: `none`, `quarantine`, `reject`
- **Recommendation**: Start with `p=quarantine` for testing, then move to `p=reject` in production

## Cloudflare DNS Configuration

### Important Notes

- **DKIM records must have "Proxy" disabled** (gray cloud icon)
- **DMARC records must have "Proxy" disabled** (gray cloud icon)
- DNS changes may take up to 48 hours to propagate globally

### Steps to Disable Proxy

1. Log in to Cloudflare Dashboard
2. Select domain (e.g., `starlist.jp`)
3. Go to DNS > Records
4. Find DKIM/DMARC records
5. Click "Edit" (pencil icon)
6. Toggle "Proxy status" to "DNS only" (gray cloud)
7. Save changes

## Production Checklist

- [ ] DKIM record exists and validates
- [ ] DMARC record exists and validates
- [ ] Cloudflare proxy is disabled for DKIM/DMARC records
- [ ] DNS propagation verified (use `dig` or online tools)
- [ ] Test email sent and verified
- [ ] DMARC reports being received (check `rua=` email address)

## References

- [Google Workspace DKIM Setup](https://support.google.com/a/answer/174124)
- [DMARC Record Format](https://dmarc.org/wiki/FAQ)
- [Cloudflare DNS Documentation](https://developers.cloudflare.com/dns/)

---

**Last Updated**: 2025-11-08
**Maintainer**: SRE Team

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
