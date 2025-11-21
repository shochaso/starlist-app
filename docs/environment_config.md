---
source_of_truth: true
version: 0.1.0
updated_date: 2025-11-15
owner: STARLIST Docs Automation Team
---



Status:: planned
Source-of-Truth:: (TBD)
Spec-State:: 
Last-Updated:: 


# Environment Configuration

Flutter builds consume the following variables via `--dart-define`. When
running locally, the defaults in `EnvironmentConfig` are used, but production
deployments **must** supply explicit values.

| Key | Description |
| --- | --- |
| `SUPABASE_URL` | Supabase project URL (`https://xxx.supabase.co`) |
| `SUPABASE_ANON_KEY` | Supabase anon service key |
| `ASSETS_CDN_ORIGIN` | Cloudflare CDN origin used for icons and transformed images (`https://cdn.starlist.jp`) |
| `BUCKET_PUBLIC_ICONS` | Public bucket containing brand icons (`public/icons`) |
| `BUCKET_PUBLIC_DERIVED` | CDN-friendly bucket for transformed assets (`public/derived`) |
| `BUCKET_PRIVATE_ORIGINALS` | Private storage bucket for originals that require signed URLs (`private/originals`) |
| `SIGNED_URL_TTL_SECONDS` | TTL (seconds) for generated Supabase signed URLs |

### Local development

```
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=ASSETS_CDN_ORIGIN=https://cdn.starlist.jp
```

Empty values fallback to the baked-in development defaults. Avoid committing
sensitive production keys to source control.

### Debug toggles

`DebugFlags` reads from query parameters (`?debugIcons=true`) or environment
defines (`DEBUG_ICONS=true`). The current toggles are:

| Flag | Query | Purpose |
| ---- | ----- | ------- |
| `DEBUG_ICONS` | `debugIcons=true` | Enables IconDiag HUD and CDN metrics overlay |
| `DEBUG_IMAGES` | `debugImages=true` | Logs `ImageUrlBuilder` output + CDN analytics |

Enable these flags in staging environments to inspect icon/image pipelines
without modifying source code.

## DoD (Definition of Done)
- [ ] 文書の目的と完了基準を明記しました。
