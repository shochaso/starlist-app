# STARLIST Feature Matrix

## 1. Account & Authentication
| Stage | Feature | Description |
| --- | --- | --- |
| MVP | Email/password account creation | Users register with email, password, and verify via email; password reset flows reuse same credential store. |
| MVP | SNS login (Google/Apple/Twitter) | Fans/stars can log in via supported SNS providers; accounts that share identical email addresses are unified into a single user record. |
| MVP | Passwordless magic link | Email-based magic link flow allowed for quick authentication without storing a password. |
| Post-MVP | Two-factor authentication (2FA) | Optional TOTP or device-based second factor prioritized for stars or operations accounts with revenue. |
| Not in scope | KYC within login | Identity verification lives in the withdrawal/high-value payment domain and is decoupled from authentication. |

## 2. My Page
| Stage | Feature | Description |
| --- | --- | --- |
| MVP | Profile editor | Fans/stars edit display name, biography, and external links from the My Page settings form. |
| MVP | Profile avatar upload | Users upload/change their profile icon image, with preview and crop controls. |
| Post-MVP | Cover image management | Set a hero visual for the top of My Page to personalize the layout. |
| Post-MVP | "Watch later" bookmarks | Curated list of bookmarked content accessible from My Page. |
| Not in scope | Post list management | Publishing/editing posts is handled under Star Management rather than My Page. |
| Not in scope | Fan/star switch UI | Access control from the star review process, not manual UI toggles within My Page. |
| Not in scope | Notification center inside My Page | Notifications are consolidated in a global notification screen. |
| Not in scope | Settings tabs for privacy/theme | Dedicated settings screens outside of My Page handle those preferences. |

## 3. Star Management
| Stage | Feature | Description |
| --- | --- | --- |
| MVP | Post management | Stars see chronological list of their published posts with status, can edit content, toggle visibility, and view engagement stats. |
| MVP | Data ingestion management | Dashboard for YouTube history, receipt, and other imports including success/failure indicators and retry controls. |
| MVP | Announcement distribution | Stars publish announcements targeted to fans, with scheduling controls and channel selectors. |
| MVP | DM / message inbox | Operations-exclusive direct messaging channel for star support. |
| Post-MVP | Star analytics dashboard | Visualize follower counts, revenue, and views per post with interactive filters. |
| Post-MVP | Follower segmentation analysis | Breakdowns by activity, payment tier, and geography for planning content. |
| Post-MVP | Popular post insights | Highlight posts trending by view/purchase velocity. |
| Post-MVP | Monthly trend reporting | Category-based month-over-month summaries for star performance. |

## 4. AI & Automation (Post-MVP)
| Stage | Feature | Description |
| --- | --- | --- |
| Post-MVP | AI tagging | Automatically suggest categories and tags for new posts using content analysis. |
| Post-MVP | Fan recommendation | AI-powered suggestions surface posts tailored to each fan. |
| Post-MVP | AI viewing-log analysis | Surface anomalies or high-interest segments from ingest logs. |
| Post-MVP | AI OCR assistance | Help parse receipts or screenshots to populate structured metadata. |
| Not in scope | AI-generated post body | Generating promotional text conflicts with the commitment to selling authentic raw records. |

## 5. Operations & Governance
| Stage | Feature | Description |
| --- | --- | --- |
| MVP | Operations dashboard | Central console showing key metrics, alerts, and ongoing workflows. |
| MVP | Star approval workflow | Intake → review → approve/decline process with state tracking and notifications. |
| MVP | Inquiry/ticket management | Routing and SLA tracking for inquiries originating from stars or fans. |
| MVP | Violation reports & moderation | Queue for reports with action tracking and evidence logging. |
| MVP | Terms & privacy display/agreement | Present latest Terms of Service and Privacy Policy with consent capture. |
| MVP | Audit logging & backup | Immutable log of critical operations plus scheduled backups. |
| MVP | Notification delivery | Send Slack, email, and push notifications for key events. |
| MVP | In-app banner management | Create/target banner slots within the app for campaigns. |
| Post-MVP | Ops analytics dashboard | KPI-focused screen surfaces ARPU, LTV, CPI, and anomaly flags. |

## 6. Pricing & Subscription Model
| Stage | Feature | Description |
| --- | --- | --- |
| MVP | Membership tiers | Four tiers (Free/Light/Standard/Premium) determine data access, comment visibility, and posting privileges. |
| MVP | Tier-based permissions | Light+ for paid data access; Standard/Premium unlock comment viewing/posting. |
| MVP | Recommended pricing hints | UI displays suggested price per tier: minors Light 100¥, Standard 200¥, Premium 500¥; adults Light 980-50,000¥, Standard 1,980-10,000¥, Premium 2,980-500,000¥, preventing entries outside those ranges. |
| MVP | Minor spend limits | Enforce aggregate spending caps (e.g., <3,000¥ over defined window) per minor star, not per payment. |
| MVP | Stripe subscription backend | Use Stripe for JPY payments with plan_price stored as integer; handle auto-renewal, retries on failures, and cancellation that only stops auto-renewal until period end (immediate cancellations are exception flows). |
| MVP | Monthly subscription cadence | Base offering is monthly billing with architecture ready for future annual discount offerings. |
| MVP | Refund policy | No refunds except when legally required or explicitly approved; log refund actor, timestamp, amount, reason, and type in audit trail. |
| Post-MVP | Annual plan option | Outline plan for discounted annual bundles as an optional purchase. |

## 7. Tipping / One-off Payments
| Stage | Feature | Description |
| --- | --- | --- |
| Post-MVP | Super tip feature | Optional one-off tipping flow labeled as "Coming Soon" in MVP, with amount selection and confirmation. |
| Post-MVP | Super tip revenue split | Preliminary split of 80% to star, 20% to operations; fan bears payment fees and consumption tax. |

## 8. Monetization & Revenue Sharing
| Stage | Feature | Description |
| --- | --- | --- |
| MVP | Subscription payout share | Split recurring revenue 80% to stars, 20% to operations; show stars net receipts after fees and tax since fans cover those costs. |
| MVP | Advertising policy | Display ads only inside the app (not on marketing LP/HP) and retain ad revenue for operations. |
| Post-MVP | Affiliate integrations | Associate ingestion receipts/products with affiliate links to external e-commerce pages, exposing those links in posts. |
| Post-MVP | Data licensing/API | Explore anonymized statistical exports for partners, subject to privacy and legal clearance. |
| Post-MVP | Partner sponsorship channels | Offer sponsor/brand placement slots for curated partner campaigns. |

## 9. Pricing Audit Logs & Dashboard
| Stage | Feature | Description |
| --- | --- | --- |
| MVP | Price change logs | Track who/when/old→new price for every tier change and log it immutably. |
| MVP | Subscription KPIs | Dashboard widgets for MRR, plan-specific revenue, churn, and price change impact. |
| MVP | Minor cap auditing | Alerts and reports on spending near/over minor aggregate limits. |
| MVP | Payment error log | Capture failure reasons per payment attempt for anomaly detection. |
| MVP | Refund history | Log refund reason and operator per charge along with amount. |
| Post-MVP | Governance dashboard | Add KPI views for trends, error rates, and unusual pricing movements tied to governance operations. |
