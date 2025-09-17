# Production Readiness TODO List

## 🔴 Critical (Must Fix Before Production)

### CI/CD & Deploy
- [ ] GitHub Actions for Backend/Frontend Build
- [ ] Docker Stack (app, web, proxy, queue, scheduler, redis)
- [ ] Zero-Downtime Rollout Pipeline
- [ ] Secrets Management (APP_KEY, STRIPE, MOLLIE, MAIL)

### Security & Compliance
- [ ] CSP/HSTS/Referrer-Policy Middleware (system-wide)
- [ ] PII Redaction in Logs
- [ ] Webhook Signature Verification (Stripe/Mollie)
- [ ] Idempotency Keys for Payments
- [ ] Rate Limits per Scope/Role
- [ ] Tenant Enforcement (global Guard + DB-Index salon_id)
- [ ] GDPR: Delete Anonymization (not invoice deletion)
- [ ] Consent/Cookie Banner + Legal Pages (Impressum, Datenschutz)

### Multi-Tenant Cleanliness
- [ ] All tables have salon_id + Index
- [ ] Global Scope/Middleware tenant.required on ALL APIs
- [ ] RBAC live in Policies/Routes

## 🟡 Important (Should Fix Soon)

### Core Functions
- [ ] POS/Invoices: GoBD Numbers, VAT Rounding, Refund Numbers, Z-Report
- [ ] Payments: Deposits/Partial Payment, Webhook Event Matrix, Refund Policy
- [ ] Inventory: Receiving/PO, Low Stock Alerts, Cost vs Retail Price, Transfers
- [ ] Booking: Opening Hours Model, Absence Collision Detection
- [ ] Staff Scheduling: RRULE Edge Cases, Vacation Approval Workflow
- [ ] Reviews: Google Import (legal), Internal Reviews (Moderation, Abuse)
- [ ] Gallery/AI: Consent Flows + Moderation (NSFW/Policy)
- [ ] Reports: Revenue/Customer/Channels + DATEV CSV

### Frontend/UX
- [ ] Design System: System-wide Usage, A11y (48px Targets), RTL, Contrast
- [ ] PWA: Icons/Manifest/SW, Offline & Update Flow
- [ ] Error and Empty States (consistent)
- [ ] Global Snackbar/Toasts
- [ ] Mobile: iOS/Android Permissions & App Icons/Splash

## 🟢 Quality/Tests
- [ ] API Contract Versioning (/api/v1)
- [ ] OpenAPI/Postman Collection
- [ ] E2E Happy-Path Tests (Auth → Booking → POS → Refund → GDPR)
- [ ] Performance/Indexes (N+1, salon_id, FK pairs, created_at)
- [ ] Caching (config/route/view/event)

## 🔵 Nice to Have
- [ ] Advanced Analytics Dashboard
- [ ] Multi-language Support
- [ ] Advanced Reporting Features
- [ ] Mobile App Store Optimization
