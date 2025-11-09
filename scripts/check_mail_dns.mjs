#!/usr/bin/env node
// DKIM/DMARC DNS validation script
// Usage: node scripts/check_mail_dns.mjs <domain>
// Exit code: 0 on success, 1 on failure

import { promises as dns } from "node:dns";
import process from "node:process";
import { promisify } from "node:util";

const resolveTxt = promisify(dns.resolveTxt);
const resolveCname = promisify(dns.resolveCname);

/**
 * Validate DKIM record for Google Workspace
 * @param {string} domain - Domain name (e.g., "starlist.jp")
 * @returns {Promise<{valid: boolean, record?: string, error?: string}>}
 */
async function validateDKIM(domain) {
  try {
    const dkimSelector = "google._domainkey";
    const dkimDomain = `${dkimSelector}.${domain}`;

    console.log(`[DKIM] Checking ${dkimDomain}...`);

    const records = await resolveTxt(dkimDomain);
    if (!records || records.length === 0) {
      return { valid: false, error: `No TXT records found for ${dkimDomain}` };
    }

    // Flatten TXT records (they come as arrays)
    const txtRecords = records.map((r) => r.join("")).join(" ");

    // Check if record contains googlehosted.com
    if (!txtRecords.includes("googlehosted.com")) {
      return {
        valid: false,
        record: txtRecords.substring(0, 100),
        error: "DKIM record does not contain googlehosted.com",
      };
    }

    // Extract CNAME target
    try {
      const cnameRecords = await resolveCname(dkimDomain);
      if (cnameRecords && cnameRecords.length > 0) {
        const cnameTarget = cnameRecords[0];
        if (!cnameTarget.includes("googlehosted.com")) {
          return {
            valid: false,
            record: cnameTarget,
            error: `CNAME does not resolve to googlehosted.com: ${cnameTarget}`,
          };
        }
        return { valid: true, record: cnameTarget };
      }
    } catch (_cnameError) {
      // CNAME resolution may fail if TXT is used instead, which is OK
      console.log(`[DKIM] CNAME resolution skipped (TXT record present)`);
    }

    return { valid: true, record: txtRecords.substring(0, 100) };
  } catch (error) {
    return { valid: false, error: error.message };
  }
}

/**
 * Validate DMARC record
 * @param {string} domain - Domain name (e.g., "starlist.jp")
 * @returns {Promise<{valid: boolean, policy?: string, rua?: string, error?: string}>}
 */
async function validateDMARC(domain) {
  try {
    const dmarcDomain = `_dmarc.${domain}`;

    console.log(`[DMARC] Checking ${dmarcDomain}...`);

    const records = await resolveTxt(dmarcDomain);
    if (!records || records.length === 0) {
      return { valid: false, error: `No TXT records found for ${dmarcDomain}` };
    }

    // Flatten TXT records
    const txtRecord = records.map((r) => r.join("")).join(" ");

    // Parse DMARC record
    const policyMatch = txtRecord.match(/p=([^;]+)/i);
    const ruaMatch = txtRecord.match(/rua=([^;]+)/i);

    const policy = policyMatch ? policyMatch[1].trim() : null;
    const rua = ruaMatch ? ruaMatch[1].trim() : null;

    if (!policy) {
      return { valid: false, error: "DMARC record missing p= (policy) tag" };
    }

    // Validate policy values
    const validPolicies = ["none", "quarantine", "reject"];
    if (!validPolicies.includes(policy.toLowerCase())) {
      return {
        valid: false,
        error: `Invalid DMARC policy: ${policy} (must be one of: ${
          validPolicies.join(", ")
        })`,
      };
    }

    return { valid: true, policy, rua: rua || "N/A" };
  } catch (error) {
    return { valid: false, error: error.message };
  }
}

/**
 * Main validation function
 */
async function main() {
  const domain = process.argv[2];

  if (!domain) {
    console.error("Usage: node scripts/check_mail_dns.mjs <domain>");
    process.exit(1);
  }

  console.log(`\n=== DNS Mail Validation for ${domain} ===\n`);

  const results = {
    domain,
    dkim: await validateDKIM(domain),
    dmarc: await validateDMARC(domain),
  };

  // Print results in table format
  console.log("\n--- Results ---\n");
  console.log("| Check | Status | Details |");
  console.log("|-------|--------|---------|");

  const dkimStatus = results.dkim.valid ? "✅ PASS" : "❌ FAIL";
  const dkimDetails = results.dkim.valid
    ? (results.dkim.record?.substring(0, 50) || "OK")
    : results.dkim.error || "Unknown error";
  console.log(`| DKIM  | ${dkimStatus} | ${dkimDetails} |`);

  const dmarcStatus = results.dmarc.valid ? "✅ PASS" : "❌ FAIL";
  const dmarcDetails = results.dmarc.valid
    ? `p=${results.dmarc.policy}, rua=${results.dmarc.rua}`
    : results.dmarc.error || "Unknown error";
  console.log(`| DMARC | ${dmarcStatus} | ${dmarcDetails} |`);

  console.log("");

  // Exit with error code if any check failed
  if (!results.dkim.valid || !results.dmarc.valid) {
    console.error("\n❌ DNS validation failed. Please fix the issues above.");
    process.exit(1);
  }

  console.log("✅ All DNS checks passed.");
  process.exit(0);
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
<<<<<<< HEAD

// DKIM/DMARC DNS validation script
// Usage: node scripts/check_mail_dns.mjs <domain>
// Exit code: 0 on success, 1 on failure

import { promises as dns } from 'node:dns';
import { promisify } from 'node:util';

const resolveTxt = promisify(dns.resolveTxt);
const resolveCname = promisify(dns.resolveCname);

/**
 * Validate DKIM record for Google Workspace
 * @param {string} domain - Domain name (e.g., "starlist.jp")
 * @returns {Promise<{valid: boolean, record?: string, error?: string}>}
 */
async function validateDKIM(domain) {
  try {
    const dkimSelector = 'google._domainkey';
    const dkimDomain = `${dkimSelector}.${domain}`;
    
    console.log(`[DKIM] Checking ${dkimDomain}...`);
    
    const records = await resolveTxt(dkimDomain);
    if (!records || records.length === 0) {
      return { valid: false, error: `No TXT records found for ${dkimDomain}` };
    }
    
    // Flatten TXT records (they come as arrays)
    const txtRecords = records.map(r => r.join('')).join(' ');
    
    // Check if record contains googlehosted.com
    if (!txtRecords.includes('googlehosted.com')) {
      return { 
        valid: false, 
        record: txtRecords.substring(0, 100),
        error: 'DKIM record does not contain googlehosted.com' 
      };
    }
    
    // Extract CNAME target
    try {
      const cnameRecords = await resolveCname(dkimDomain);
      if (cnameRecords && cnameRecords.length > 0) {
        const cnameTarget = cnameRecords[0];
        if (!cnameTarget.includes('googlehosted.com')) {
          return { 
            valid: false, 
            record: cnameTarget,
            error: `CNAME does not resolve to googlehosted.com: ${cnameTarget}` 
          };
        }
        return { valid: true, record: cnameTarget };
      }
    } catch (cnameError) {
      // CNAME resolution may fail if TXT is used instead, which is OK
      console.log(`[DKIM] CNAME resolution skipped (TXT record present)`);
    }
    
    return { valid: true, record: txtRecords.substring(0, 100) };
  } catch (error) {
    return { valid: false, error: error.message };
  }
}

/**
 * Validate DMARC record
 * @param {string} domain - Domain name (e.g., "starlist.jp")
 * @returns {Promise<{valid: boolean, policy?: string, rua?: string, error?: string}>}
 */
async function validateDMARC(domain) {
  try {
    const dmarcDomain = `_dmarc.${domain}`;
    
    console.log(`[DMARC] Checking ${dmarcDomain}...`);
    
    const records = await resolveTxt(dmarcDomain);
    if (!records || records.length === 0) {
      return { valid: false, error: `No TXT records found for ${dmarcDomain}` };
    }
    
    // Flatten TXT records
    const txtRecord = records.map(r => r.join('')).join(' ');
    
    // Parse DMARC record
    const policyMatch = txtRecord.match(/p=([^;]+)/i);
    const ruaMatch = txtRecord.match(/rua=([^;]+)/i);
    
    const policy = policyMatch ? policyMatch[1].trim() : null;
    const rua = ruaMatch ? ruaMatch[1].trim() : null;
    
    if (!policy) {
      return { valid: false, error: 'DMARC record missing p= (policy) tag' };
    }
    
    // Validate policy values
    const validPolicies = ['none', 'quarantine', 'reject'];
    if (!validPolicies.includes(policy.toLowerCase())) {
      return { valid: false, error: `Invalid DMARC policy: ${policy} (must be one of: ${validPolicies.join(', ')})` };
    }
    
    return { valid: true, policy, rua: rua || 'N/A' };
  } catch (error) {
    return { valid: false, error: error.message };
  }
}

/**
 * Main validation function
 */
async function main() {
  const domain = process.argv[2];
  
  if (!domain) {
    console.error('Usage: node scripts/check_mail_dns.mjs <domain>');
    process.exit(1);
  }
  
  console.log(`\n=== DNS Mail Validation for ${domain} ===\n`);
  
  const results = {
    domain,
    dkim: await validateDKIM(domain),
    dmarc: await validateDMARC(domain),
  };
  
  // Print results in table format
  console.log('\n--- Results ---\n');
  console.log('| Check | Status | Details |');
  console.log('|-------|--------|---------|');
  
  const dkimStatus = results.dkim.valid ? '✅ PASS' : '❌ FAIL';
  const dkimDetails = results.dkim.valid 
    ? (results.dkim.record?.substring(0, 50) || 'OK')
    : results.dkim.error || 'Unknown error';
  console.log(`| DKIM  | ${dkimStatus} | ${dkimDetails} |`);
  
  const dmarcStatus = results.dmarc.valid ? '✅ PASS' : '❌ FAIL';
  const dmarcDetails = results.dmarc.valid
    ? `p=${results.dmarc.policy}, rua=${results.dmarc.rua}`
    : results.dmarc.error || 'Unknown error';
  console.log(`| DMARC | ${dmarcStatus} | ${dmarcDetails} |`);
  
  console.log('');
  
  // Exit with error code if any check failed
  if (!results.dkim.valid || !results.dmarc.valid) {
    console.error('\n❌ DNS validation failed. Please fix the issues above.');
    process.exit(1);
  }
  
  console.log('✅ All DNS checks passed.');
  process.exit(0);
}

main().catch((error) => {
  console.error('Fatal error:', error);
  process.exit(1);
});

=======
>>>>>>> 8abb626 (feat(ops): add ultra pack enhancements — Makefile, audit bundle, risk register, RACI matrix)
