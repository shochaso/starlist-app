# OPS Summary Email Execution Logs

This file contains execution logs for the OPS Summary Email workflow.

---

## Log Format

Each entry includes:
- **Mode**: DryRun or Production
- **Status**: ✅ Success or ❌ Failure
- **Timestamp**: ISO 8601 UTC timestamp
- **Additional fields**: Provider, Message ID, To Count, Report Week, Error (if applicable)

---

<<<<<<< HEAD

This file contains execution logs for the OPS Summary Email workflow.

---

## Log Format

Each entry includes:
- **Mode**: DryRun or Production
- **Status**: ✅ Success or ❌ Failure
- **Timestamp**: ISO 8601 UTC timestamp
- **Additional fields**: Provider, Message ID, To Count, Report Week, Error (if applicable)

---
=======
### セキュリティ実行サマリ（20251109-121054）
- deno fmt: FAIL
- deno lint: OK
- deno test: OK
- semgrep: OK
- trivy: FAIL
- playwright: FAIL

<details><summary><code>deno_fmt.log</code>（先頭20行）</summary>

```txt

[0m[1mfrom[0m /Users/shochaso/Downloads/starlist-app/supabase/functions/exchange/index.ts:
  1[0m[38;5;245m |[0m [0m[1m[31m-[0m[0m[31mimport {[0m[0m[37m[41m[0m
  2[0m[38;5;245m |[0m [0m[1m[31m-[0m[0m[37m[41m [0m[0m[31m createRemoteJWKSet,[0m[0m[37m[41m[0m
  3[0m[38;5;245m |[0m [0m[1m[31m-[0m[0m[37m[41m [0m[0m[31m jwtVerify,[0m[0m[37m[41m[0m
  4[0m[38;5;245m |[0m [0m[1m[31m-[0m[0m[37m[41m [0m[0m[31m SignJWT[0m[0m[37m[41m,[0m
  5[0m[38;5;245m |[0m [0m[1m[31m-[0m[0m[37m[41m[0m[0m[31m} from "jose";[0m
  1[0m[38;5;245m |[0m [0m[1m[32m+[0m[0m[32mimport {[0m[0m[32m createRemoteJWKSet,[0m[0m[32m jwtVerify,[0m[0m[32m SignJWT[0m[0m[30m[42m [0m[0m[32m} from "jose";[0m


[0m[1mfrom[0m /Users/shochaso/Downloads/starlist-app/supabase/functions/shared.ts:
  2[0m[38;5;245m |[0m [0m[1m[31m-[0m[0m[31mimport type {[0m[0m[37m[41m[0m
  3[0m[38;5;245m |[0m [0m[1m[31m-[0m[0m[37m[41m [0m[0m[31m SupabaseClient,[0m[0m[37m[41m[0m
  4[0m[38;5;245m |[0m [0m[1m[31m-[0m[0m[37m[41m [0m[0m[31m User[0m[0m[37m[41m,[0m
  5[0m[38;5;245m |[0m [0m[1m[31m-[0m[0m[37m[41m[0m[0m[31m} from "supabase-js";[0m
  2[0m[38;5;245m |[0m [0m[1m[32m+[0m[0m[32mimport type {[0m[0m[32m SupabaseClient,[0m[0m[32m User[0m[0m[30m[42m [0m[0m[32m} from "supabase-js";[0m

[0m[1m[31merror[0m: Found 2 not formatted files in 25 files
```
</details>


<details><summary><code>deno_lint.log</code>（先頭20行）</summary>

```txt
Checked 22 files
```
</details>


<details><summary><code>deno_test.log</code>（先頭20行）</summary>

```txt
[0m[32mCheck[0m file:///Users/shochaso/Downloads/starlist-app/supabase/functions/_tests/csp-report.test.ts
Listening on http://0.0.0.0:8000/ (http://localhost:8000/)
[0m[38;5;245mrunning 1 test from ./supabase/functions/_tests/csp-report.test.ts[0m
masks sensitive fields ... [0m[32mok[0m [0m[38;5;245m(0ms)[0m

[0m[32mok[0m | 1 passed | 0 failed [0m[38;5;245m(7ms)[0m

```
</details>


<details><summary><code>semgrep.log</code>（先頭20行）</summary>

```txt
               
               
┌─────────────┐
│ Scan Status │
└─────────────┘
  Scanning 1279 files tracked by git with 2 Code rules:
                                                                                                                        
  Language      Rules   Files          Origin   Rules                                                                   
 ─────────────────────────────        ────────────────                                                                  
  <multilang>       1    1279          Custom       2                                                                   
  ts                1      43                                                                                           
  js                1       5                                                                                           
                                                                                                                        
                
                
┌──────────────┐
│ Scan Summary │
└──────────────┘
✅ Scan completed successfully.
 • Findings: 0 (0 blocking)
```
</details>


<details><summary><code>trivy.log</code>（先頭20行）</summary>

```txt
2025-11-09T12:11:04+09:00	INFO	[vulndb] Need to update DB
2025-11-09T12:11:04+09:00	INFO	[vulndb] Downloading vulnerability DB...
2025-11-09T12:11:04+09:00	INFO	[vulndb] Downloading artifact...	repo="ghcr.io/aquasecurity/trivy-db:2"
2025-11-09T12:11:04+09:00	FATAL	Fatal error	run error: init error: DB error: failed to download vulnerability DB: OCI artifact error: failed to download vulnerability DB: failed to download artifact from ghcr.io/aquasecurity/trivy-db:2: OCI repository error: 1 error occurred:
	* error getting credentials - err: exec: "docker-credential-desktop": executable file not found in $PATH, out: ``


```
</details>


<details><summary><code>playwright.log</code>（先頭20行）</summary>

```txt

Running 1 test using 1 worker

  ✘  1 tests/e2e/csp.spec.ts:3:5 › CSP report endpoint receives payload (31.9s)


  1) tests/e2e/csp.spec.ts:3:5 › CSP report endpoint receives payload ──────────────────────────────

    [31mTest timeout of 30000ms exceeded.[39m

    Error: page.waitForRequest: Test timeout of 30000ms exceeded.

      3 | test("CSP report endpoint receives payload", async ({ page }) => {
      4 |   const [request] = await Promise.all([
    > 5 |     page.waitForRequest((req) =>
        |          ^
      6 |       req.url().includes("/functions/v1/csp-report")
      7 |     ),
      8 |     page.goto("http://localhost:8080"),
        at /Users/shochaso/Downloads/starlist-app/tests/e2e/csp.spec.ts:5:10
```
</details>


### セキュリティ実行サマリ（20251109-121650）
- deno fmt: OK
- deno lint: FAIL
- deno test: OK
- semgrep: OK
- trivy: FAIL
- playwright: OK

<details><summary><code>deno_fmt.log</code>（先頭20行）</summary>

```txt
Checked 25 files
```
</details>


<details><summary><code>deno_lint.log</code>（先頭20行）</summary>

```txt
[0m[1m[31merror[no-process-global][0m: [0m[1mNodeJS process global is discouraged in Deno[0m
 [0m[38;5;12m-->[0m [0m[36m/Users/shochaso/Downloads/starlist-app/tests/e2e/csp.spec.ts[0m[0m[33m:3:17[0m
 [0m[38;5;12m | [0m
[0m[38;5;12m3 | [0mconst baseUrl = process.env.BASE_URL ?? "http://localhost:8080";
 [0m[38;5;12m | [0m                [0m[1m[31m^^^^^^^[0m
  [0m[38;5;12m=[0m [0m[1mhint[0m: Add `import process from "node:process";`

  [0m[38;5;12mdocs[0m: https://docs.deno.com/lint/rules/no-process-global


[0m[1m[31merror[no-process-global][0m: [0m[1mNodeJS process global is discouraged in Deno[0m
 [0m[38;5;12m-->[0m [0m[36m/Users/shochaso/Downloads/starlist-app/tests/e2e/csp.spec.ts[0m[0m[33m:4:20[0m
 [0m[38;5;12m | [0m
[0m[38;5;12m4 | [0mconst reportPath = process.env.CSP_REPORT_PATH ?? "/functions/v1/csp-report";
 [0m[38;5;12m | [0m                   [0m[1m[31m^^^^^^^[0m
  [0m[38;5;12m=[0m [0m[1mhint[0m: Add `import process from "node:process";`

  [0m[38;5;12mdocs[0m: https://docs.deno.com/lint/rules/no-process-global


```
</details>


<details><summary><code>deno_test.log</code>（先頭20行）</summary>

```txt
[0m[32mCheck[0m file:///Users/shochaso/Downloads/starlist-app/supabase/functions/_tests/csp-report.test.ts
Listening on http://0.0.0.0:8000/ (http://localhost:8000/)
[0m[38;5;245mrunning 1 test from ./supabase/functions/_tests/csp-report.test.ts[0m
masks sensitive fields ... [0m[32mok[0m [0m[38;5;245m(4ms)[0m

[0m[32mok[0m | 1 passed | 0 failed [0m[38;5;245m(13ms)[0m

```
</details>


<details><summary><code>semgrep.log</code>（先頭20行）</summary>

```txt
               
               
┌─────────────┐
│ Scan Status │
└─────────────┘
  Scanning 1278 files tracked by git with 2 Code rules:
                                                                                                                        
  Language      Rules   Files          Origin   Rules                                                                   
 ─────────────────────────────        ────────────────                                                                  
  <multilang>       1    1278          Custom       2                                                                   
  ts                1      43                                                                                           
  js                1       5                                                                                           
                                                                                                                        
                
                
┌──────────────┐
│ Scan Summary │
└──────────────┘
✅ Scan completed successfully.
 • Findings: 0 (0 blocking)
```
</details>


<details><summary><code>trivy.log</code>（先頭20行）</summary>

```txt
2025-11-09T12:17:10+09:00	INFO	[vulndb] Need to update DB
2025-11-09T12:17:10+09:00	INFO	[vulndb] Downloading vulnerability DB...
2025-11-09T12:17:10+09:00	INFO	[vulndb] Downloading artifact...	repo="ghcr.io/aquasecurity/trivy-db:2"
2.54 MiB / 74.40 MiB [-->____________________________________________________________] 3.41% ? p/s ?6.32 MiB / 74.40 MiB [----->_________________________________________________________] 8.49% ? p/s ?6.32 MiB / 74.40 MiB [----->_________________________________________________________] 8.49% ? p/s ?8.21 MiB / 74.40 MiB [----->____________________________________________] 11.03% 9.45 MiB p/s ETA 7s8.21 MiB / 74.40 MiB [----->____________________________________________] 11.03% 9.45 MiB p/s ETA 7s8.21 MiB / 74.40 MiB [----->____________________________________________] 11.03% 9.45 MiB p/s ETA 7s10.45 MiB / 74.40 MiB [------>__________________________________________] 14.05% 9.08 MiB p/s ETA 7s10.80 MiB / 74.40 MiB [------->_________________________________________] 14.51% 9.08 MiB p/s ETA 7s15.41 MiB / 74.40 MiB [---------->______________________________________] 20.71% 9.08 MiB p/s ETA 6s16.24 MiB / 74.40 MiB [---------->______________________________________] 21.83% 9.12 MiB p/s ETA 6s19.11 MiB / 74.40 MiB [------------>____________________________________] 25.69% 9.12 MiB p/s ETA 6s23.06 MiB / 74.40 MiB [--------------->_________________________________] 30.99% 9.12 MiB p/s ETA 5s24.46 MiB / 74.40 MiB [---------------->________________________________] 32.87% 9.41 MiB p/s ETA 5s28.46 MiB / 74.40 MiB [------------------>______________________________] 38.26% 9.41 MiB p/s ETA 4s31.39 MiB / 74.40 MiB [-------------------->____________________________] 42.20% 9.41 MiB p/s ETA 4s31.39 MiB / 74.40 MiB [-------------------->____________________________] 42.20% 9.55 MiB p/s ETA 4s33.09 MiB / 74.40 MiB [--------------------->___________________________] 44.47% 9.55 MiB p/s ETA 4s33.81 MiB / 74.40 MiB [---------------------->__________________________] 45.45% 9.55 MiB p/s ETA 4s33.81 MiB / 74.40 MiB [---------------------->__________________________] 45.45% 9.20 MiB p/s ETA 4s34.94 MiB / 74.40 MiB [----------------------->_________________________] 46.97% 9.20 MiB p/s ETA 4s34.94 MiB / 74.40 MiB [----------------------->_________________________] 46.97% 9.20 MiB p/s ETA 4s34.97 MiB / 74.40 MiB [----------------------->_________________________] 47.01% 8.73 MiB p/s ETA 4s36.66 MiB / 74.40 MiB [------------------------>________________________] 49.28% 8.73 MiB p/s ETA 4s38.03 MiB / 74.40 MiB [------------------------->_______________________] 51.11% 8.73 MiB p/s ETA 4s39.61 MiB / 74.40 MiB [-------------------------->______________________] 53.23% 8.66 MiB p/s ETA 4s39.61 MiB / 74.40 MiB [-------------------------->______________________] 53.23% 8.66 MiB p/s ETA 4s40.86 MiB / 74.40 MiB [-------------------------->______________________] 54.92% 8.66 MiB p/s ETA 3s42.60 MiB / 74.40 MiB [---------------------------->____________________] 57.26% 8.43 MiB p/s ETA 3s43.12 MiB / 74.40 MiB [---------------------------->____________________] 57.96% 8.43 MiB p/s ETA 3s45.60 MiB / 74.40 MiB [------------------------------>__________________] 61.30% 8.43 MiB p/s ETA 3s45.89 MiB / 74.40 MiB [------------------------------>__________________] 61.68% 8.24 MiB p/s ETA 3s46.54 MiB / 74.40 MiB [------------------------------>__________________] 62.56% 8.24 MiB p/s ETA 3s48.88 MiB / 74.40 MiB [-------------------------------->________________] 65.70% 8.24 MiB p/s ETA 3s49.56 MiB / 74.40 MiB [-------------------------------->________________] 66.62% 8.10 MiB p/s ETA 3s51.72 MiB / 74.40 MiB [---------------------------------->______________] 69.52% 8.10 MiB p/s ETA 2s53.26 MiB / 74.40 MiB [----------------------------------->_____________] 71.59% 8.10 MiB p/s ETA 2s54.54 MiB / 74.40 MiB [----------------------------------->_____________] 73.31% 8.11 MiB p/s ETA 2s56.29 MiB / 74.40 MiB [------------------------------------->___________] 75.66% 8.11 MiB p/s ETA 2s59.01 MiB / 74.40 MiB [-------------------------------------->__________] 79.31% 8.11 MiB p/s ETA 1s60.39 MiB / 74.40 MiB [--------------------------------------->_________] 81.17% 8.22 MiB p/s ETA 1s62.76 MiB / 74.40 MiB [----------------------------------------->_______] 84.35% 8.22 MiB p/s ETA 1s64.87 MiB / 74.40 MiB [------------------------------------------>______] 87.20% 8.22 MiB p/s ETA 1s67.73 MiB / 74.40 MiB [-------------------------------------------->____] 91.04% 8.48 MiB p/s ETA 0s70.00 MiB / 74.40 MiB [---------------------------------------------->__] 94.09% 8.48 MiB p/s ETA 0s70.00 MiB / 74.40 MiB [---------------------------------------------->__] 94.09% 8.48 MiB p/s ETA 0s70.73 MiB / 74.40 MiB [---------------------------------------------->__] 95.07% 8.25 MiB p/s ETA 0s70.73 MiB / 74.40 MiB [---------------------------------------------->__] 95.07% 8.25 MiB p/s ETA 0s70.73 MiB / 74.40 MiB [---------------------------------------------->__] 95.07% 8.25 MiB p/s ETA 0s71.82 MiB / 74.40 MiB [----------------------------------------------->_] 96.54% 7.84 MiB p/s ETA 0s72.42 MiB / 74.40 MiB [----------------------------------------------->_] 97.34% 7.84 MiB p/s ETA 0s74.23 MiB / 74.40 MiB [------------------------------------------------>] 99.77% 7.84 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 7.61 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 7.61 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 7.61 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 7.12 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 7.12 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 7.12 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 6.66 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 6.66 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 6.66 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 6.23 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 6.23 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 6.23 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 5.83 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 5.83 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 5.83 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 5.45 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 5.45 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 5.45 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 5.10 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 5.10 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 5.10 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 4.77 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 4.77 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 4.77 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 4.46 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 4.46 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 4.46 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 4.17 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 4.17 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 4.17 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 3.91 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 3.91 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 3.91 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 3.65 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 3.65 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 3.65 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 3.42 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 3.42 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 3.42 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 3.20 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 3.20 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 3.20 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 2.99 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 2.99 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [----------------------------------------------->] 100.00% 2.99 MiB p/s ETA 0s74.40 MiB / 74.40 MiB [---------------------------------------------------] 100.00% 3.90 MiB p/s 19s2025-11-09T12:17:31+09:00	INFO	[vulndb] Artifact successfully downloaded	repo="ghcr.io/aquasecurity/trivy-db:2"
2025-11-09T12:17:31+09:00	INFO	[vuln] Vulnerability scanning is enabled
2025-11-09T12:17:31+09:00	INFO	[secret] Secret scanning is enabled
2025-11-09T12:17:31+09:00	INFO	[secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2025-11-09T12:17:31+09:00	INFO	[secret] Please see https://trivy.dev/v0.67/docs/scanner/secret#recommendation for faster secret detection
2025-11-09T12:17:37+09:00	WARN	[secret] The size of the scanned file is too large. It is recommended to use `--skip-files` for this file to avoid high memory consumption.	file_path="apps/flutter/bin/cache/dart-sdk/bin/resources/devtools/assets/packages/perfetto_ui_compiled/dist/v34.0-16f63abe3/frontend_bundle.js" size (MB)=14
2025-11-09T12:17:49+09:00	WARN	[secret] The size of the scanned file is too large. It is recommended to use `--skip-files` for this file to avoid high memory consumption.	file_path="apps/flutter/bin/cache/flutter_web_sdk/kernel/amd-canvaskit/dart_sdk.js" size (MB)=14
2025-11-09T12:17:49+09:00	WARN	[secret] The size of the scanned file is too large. It is recommended to use `--skip-files` for this file to avoid high memory consumption.	file_path="apps/flutter/bin/cache/flutter_web_sdk/kernel/ddcLibraryBundle-canvaskit/dart_sdk.js" size (MB)=15
2025-11-09T12:18:07+09:00	INFO	Suppressing dependencies for development and testing. To display them, try the '--include-dev-deps' flag.
2025-11-09T12:18:07+09:00	INFO	Number of language-specific files	num=37
2025-11-09T12:18:07+09:00	INFO	[cocoapods] Detecting vulnerabilities...
2025-11-09T12:18:07+09:00	INFO	[gradle] Detecting vulnerabilities...
2025-11-09T12:18:07+09:00	INFO	[npm] Detecting vulnerabilities...
2025-11-09T12:18:07+09:00	INFO	[pub] Detecting vulnerabilities...

Report Summary

```
</details>


<details><summary><code>playwright.log</code>（先頭20行）</summary>

```txt

Running 1 test using 1 worker

  ✓  1 tests/e2e/csp.spec.ts:6:5 › CSP report endpoint receives payload (916ms)

  1 passed (44.6s)
```
</details>


### セキュリティ実行サマリ（20251109-121946）
- deno fmt: OK
- deno lint: OK
- deno test: OK
- semgrep: OK
- trivy: FAIL
- playwright: OK

<details><summary><code>deno_fmt.log</code>（先頭20行）</summary>

```txt
Checked 25 files
```
</details>


<details><summary><code>deno_lint.log</code>（先頭20行）</summary>

```txt
Checked 22 files
```
</details>


<details><summary><code>deno_test.log</code>（先頭20行）</summary>

```txt
[0m[32mCheck[0m file:///Users/shochaso/Downloads/starlist-app/supabase/functions/_tests/csp-report.test.ts
Listening on http://0.0.0.0:8000/ (http://localhost:8000/)
[0m[38;5;245mrunning 1 test from ./supabase/functions/_tests/csp-report.test.ts[0m
masks sensitive fields ... [0m[32mok[0m [0m[38;5;245m(0ms)[0m

[0m[32mok[0m | 1 passed | 0 failed [0m[38;5;245m(5ms)[0m

```
</details>


<details><summary><code>semgrep.log</code>（先頭20行）</summary>

```txt
               
               
┌─────────────┐
│ Scan Status │
└─────────────┘
  Scanning 1278 files tracked by git with 2 Code rules:
                                                                                                                        
  Language      Rules   Files          Origin   Rules                                                                   
 ─────────────────────────────        ────────────────                                                                  
  <multilang>       1    1278          Custom       2                                                                   
  ts                1      43                                                                                           
  js                1       5                                                                                           
                                                                                                                        
                
                
┌──────────────┐
│ Scan Summary │
└──────────────┘
✅ Scan completed successfully.
 • Findings: 0 (0 blocking)
```
</details>


<details><summary><code>trivy.log</code>（先頭20行）</summary>

```txt
2025-11-09T12:19:52+09:00	INFO	[vuln] Vulnerability scanning is enabled
2025-11-09T12:19:52+09:00	INFO	[secret] Secret scanning is enabled
2025-11-09T12:19:52+09:00	INFO	[secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2025-11-09T12:19:52+09:00	INFO	[secret] Please see https://trivy.dev/v0.67/docs/scanner/secret#recommendation for faster secret detection
2025-11-09T12:19:58+09:00	WARN	[secret] The size of the scanned file is too large. It is recommended to use `--skip-files` for this file to avoid high memory consumption.	file_path="apps/flutter/bin/cache/dart-sdk/bin/resources/devtools/assets/packages/perfetto_ui_compiled/dist/v34.0-16f63abe3/frontend_bundle.js" size (MB)=14
2025-11-09T12:20:06+09:00	WARN	[secret] The size of the scanned file is too large. It is recommended to use `--skip-files` for this file to avoid high memory consumption.	file_path="apps/flutter/bin/cache/flutter_web_sdk/kernel/amd-canvaskit/dart_sdk.js" size (MB)=14
2025-11-09T12:20:06+09:00	WARN	[secret] The size of the scanned file is too large. It is recommended to use `--skip-files` for this file to avoid high memory consumption.	file_path="apps/flutter/bin/cache/flutter_web_sdk/kernel/ddcLibraryBundle-canvaskit/dart_sdk.js" size (MB)=15
2025-11-09T12:20:21+09:00	INFO	Suppressing dependencies for development and testing. To display them, try the '--include-dev-deps' flag.
2025-11-09T12:20:21+09:00	INFO	Number of language-specific files	num=37
2025-11-09T12:20:21+09:00	INFO	[cocoapods] Detecting vulnerabilities...
2025-11-09T12:20:21+09:00	INFO	[gradle] Detecting vulnerabilities...
2025-11-09T12:20:21+09:00	INFO	[npm] Detecting vulnerabilities...
2025-11-09T12:20:21+09:00	INFO	[pub] Detecting vulnerabilities...
2025-11-09T12:20:22+09:00	INFO	Some vulnerabilities have been ignored/suppressed. Use the "--show-suppressed" flag to display them.

Report Summary

┌──────────────────────────────────────────────────────────────────────────────────┬───────────┬─────────────────┬─────────┐
│                                      Target                                      │   Type    │ Vulnerabilities │ Secrets │
├──────────────────────────────────────────────────────────────────────────────────┼───────────┼─────────────────┼─────────┤
```
</details>


<details><summary><code>playwright.log</code>（先頭20行）</summary>

```txt

Running 1 test using 1 worker

  ✓  1 tests/e2e/csp.spec.ts:7:5 › CSP report endpoint receives payload (666ms)

  1 passed (47.0s)
```
</details>


### セキュリティ実行サマリ（20251109-122150）
- deno fmt: OK
- deno lint: OK
- deno test: OK
- semgrep: OK
- trivy: FAIL
- playwright: OK

<details><summary><code>deno_fmt.log</code>（先頭20行）</summary>

```txt
Checked 25 files
```
</details>


<details><summary><code>deno_lint.log</code>（先頭20行）</summary>

```txt
Checked 22 files
```
</details>


<details><summary><code>deno_test.log</code>（先頭20行）</summary>

```txt
[0m[32mCheck[0m file:///Users/shochaso/Downloads/starlist-app/supabase/functions/_tests/csp-report.test.ts
Listening on http://0.0.0.0:8000/ (http://localhost:8000/)
[0m[38;5;245mrunning 1 test from ./supabase/functions/_tests/csp-report.test.ts[0m
masks sensitive fields ... [0m[32mok[0m [0m[38;5;245m(0ms)[0m

[0m[32mok[0m | 1 passed | 0 failed [0m[38;5;245m(9ms)[0m

```
</details>


<details><summary><code>semgrep.log</code>（先頭20行）</summary>

```txt
               
               
┌─────────────┐
│ Scan Status │
└─────────────┘
  Scanning 1278 files tracked by git with 2 Code rules:
                                                                                                                        
  Language      Rules   Files          Origin   Rules                                                                   
 ─────────────────────────────        ────────────────                                                                  
  <multilang>       1    1278          Custom       2                                                                   
  ts                1      43                                                                                           
  js                1       5                                                                                           
                                                                                                                        
                
                
┌──────────────┐
│ Scan Summary │
└──────────────┘
✅ Scan completed successfully.
 • Findings: 0 (0 blocking)
```
</details>


<details><summary><code>trivy.log</code>（先頭20行）</summary>

```txt
2025-11-09T12:22:09+09:00	INFO	[vuln] Vulnerability scanning is enabled
2025-11-09T12:22:09+09:00	INFO	[secret] Secret scanning is enabled
2025-11-09T12:22:09+09:00	INFO	[secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2025-11-09T12:22:09+09:00	INFO	[secret] Please see https://trivy.dev/v0.67/docs/scanner/secret#recommendation for faster secret detection
2025-11-09T12:22:19+09:00	WARN	[secret] The size of the scanned file is too large. It is recommended to use `--skip-files` for this file to avoid high memory consumption.	file_path="apps/flutter/bin/cache/dart-sdk/bin/resources/devtools/assets/packages/perfetto_ui_compiled/dist/v34.0-16f63abe3/frontend_bundle.js" size (MB)=14
2025-11-09T12:22:29+09:00	WARN	[secret] The size of the scanned file is too large. It is recommended to use `--skip-files` for this file to avoid high memory consumption.	file_path="apps/flutter/bin/cache/flutter_web_sdk/kernel/amd-canvaskit/dart_sdk.js" size (MB)=14
2025-11-09T12:22:29+09:00	WARN	[secret] The size of the scanned file is too large. It is recommended to use `--skip-files` for this file to avoid high memory consumption.	file_path="apps/flutter/bin/cache/flutter_web_sdk/kernel/ddcLibraryBundle-canvaskit/dart_sdk.js" size (MB)=15
2025-11-09T12:22:51+09:00	INFO	Suppressing dependencies for development and testing. To display them, try the '--include-dev-deps' flag.
2025-11-09T12:22:51+09:00	INFO	Number of language-specific files	num=37
2025-11-09T12:22:51+09:00	INFO	[cocoapods] Detecting vulnerabilities...
2025-11-09T12:22:51+09:00	INFO	[gradle] Detecting vulnerabilities...
2025-11-09T12:22:51+09:00	INFO	[npm] Detecting vulnerabilities...
2025-11-09T12:22:51+09:00	INFO	[pub] Detecting vulnerabilities...
2025-11-09T12:22:51+09:00	INFO	Some vulnerabilities have been ignored/suppressed. Use the "--show-suppressed" flag to display them.

Report Summary

┌──────────────────────────────────────────────────────────────────────────────────┬───────────┬─────────────────┬─────────┐
│                                      Target                                      │   Type    │ Vulnerabilities │ Secrets │
├──────────────────────────────────────────────────────────────────────────────────┼───────────┼─────────────────┼─────────┤
```
</details>


<details><summary><code>playwright.log</code>（先頭20行）</summary>

```txt

Running 1 test using 1 worker

  ✓  1 tests/e2e/csp.spec.ts:7:5 › CSP report endpoint receives payload (550ms)

  1 passed (28.6s)
```
</details>


### セキュリティ実行サマリ（20251109-122418）
- deno fmt: OK
- deno lint: OK
- deno test: OK
- semgrep: OK
- trivy: OK
- playwright: OK
- logs: `logs/security_20251109-122418`

<details><summary><code>deno_fmt.log</code>（先頭20行）</summary>

```txt
Checked 25 files
```
</details>


<details><summary><code>deno_lint.log</code>（先頭20行）</summary>

```txt
Checked 22 files
```
</details>


<details><summary><code>deno_test.log</code>（先頭20行）</summary>

```txt
[0m[32mCheck[0m file:///Users/shochaso/Downloads/starlist-app/supabase/functions/_tests/csp-report.test.ts
Listening on http://0.0.0.0:8000/ (http://localhost:8000/)
[0m[38;5;245mrunning 1 test from ./supabase/functions/_tests/csp-report.test.ts[0m
masks sensitive fields ... [0m[32mok[0m [0m[38;5;245m(2ms)[0m

[0m[32mok[0m | 1 passed | 0 failed [0m[38;5;245m(8ms)[0m

```
</details>


<details><summary><code>semgrep.log</code>（先頭20行）</summary>

```txt
               
               
┌─────────────┐
│ Scan Status │
└─────────────┘
  Scanning 1278 files tracked by git with 2 Code rules:
                                                                                                                        
  Language      Rules   Files          Origin   Rules                                                                   
 ─────────────────────────────        ────────────────                                                                  
  <multilang>       1    1278          Custom       2                                                                   
  ts                1      43                                                                                           
  js                1       5                                                                                           
                                                                                                                        
                
                
┌──────────────┐
│ Scan Summary │
└──────────────┘
✅ Scan completed successfully.
 • Findings: 0 (0 blocking)
```
</details>


<details><summary><code>trivy.log</code>（先頭20行）</summary>

```txt
2025-11-09T12:24:34+09:00	INFO	[vuln] Vulnerability scanning is enabled
2025-11-09T12:24:34+09:00	INFO	[secret] Secret scanning is enabled
2025-11-09T12:24:34+09:00	INFO	[secret] If your scanning is slow, please try '--scanners vuln' to disable secret scanning
2025-11-09T12:24:34+09:00	INFO	[secret] Please see https://trivy.dev/v0.67/docs/scanner/secret#recommendation for faster secret detection
2025-11-09T12:24:40+09:00	INFO	Suppressing dependencies for development and testing. To display them, try the '--include-dev-deps' flag.
2025-11-09T12:24:40+09:00	INFO	Number of language-specific files	num=6
2025-11-09T12:24:40+09:00	INFO	[cocoapods] Detecting vulnerabilities...
2025-11-09T12:24:40+09:00	INFO	[npm] Detecting vulnerabilities...
2025-11-09T12:24:40+09:00	INFO	[pub] Detecting vulnerabilities...

Report Summary

┌──────────────────────────────────────┬───────────┬─────────────────┬─────────┐
│                Target                │   Type    │ Vulnerabilities │ Secrets │
├──────────────────────────────────────┼───────────┼─────────────────┼─────────┤
│ cloudrun/ocr-proxy/package-lock.json │    npm    │        0        │    -    │
├──────────────────────────────────────┼───────────┼─────────────────┼─────────┤
│ ios/Podfile.lock                     │ cocoapods │        0        │    -    │
├──────────────────────────────────────┼───────────┼─────────────────┼─────────┤
│ macos/Podfile.lock                   │ cocoapods │        0        │    -    │
```
</details>


<details><summary><code>playwright.log</code>（先頭20行）</summary>

```txt

Running 1 test using 1 worker

  ✓  1 tests/e2e/csp.spec.ts:7:5 › CSP report endpoint receives payload (628ms)

  1 passed (30.2s)
```
</details>
>>>>>>> 8abb626 (feat(ops): add ultra pack enhancements — Makefile, audit bundle, risk register, RACI matrix)

