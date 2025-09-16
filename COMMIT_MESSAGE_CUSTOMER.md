feat(customer): profiles + notes + loyalty (api + policies + flutter ui: list/detail with tabs), discounts public list, gdpr stubs

## Backend (Laravel 12)
- ✅ Database migrations for customer_profiles, customer_notes, customer_media, loyalty_cards, loyalty_transactions, discounts
- ✅ Eloquent models with SalonOwned trait and relationships
- ✅ API controllers with RBAC policies (salon_owner/manager full, stylist restricted, customer self-only)
- ✅ Form request validation for customer operations
- ✅ API endpoints: /api/v1/customers/*, /notes, /loyalty, /discounts
- ✅ GDPR stubs: export & deletion request endpoints (TODO: queue jobs)
- ✅ Test stubs created for comprehensive coverage

## Frontend (Flutter)
- ✅ Customer list page with search and infinite scroll
- ✅ Customer detail page with tabbed interface (Profile, Notes, Loyalty)
- ✅ Riverpod state management with repositories
- ✅ Model classes for all customer data structures
- ✅ Routing integration with GoRouter

## Key Features
- 🔐 RBAC: Role-based access control for all operations
- 📝 Notes: Staff can add/edit notes (stylists only own notes)
- 🎯 Loyalty: Point earning/redeeming with transaction history
- 💰 Discounts: Public discount code listing with conditions
- 🔍 Search: Customer directory with name/email search
- 📱 UI: Modern Flutter UI with Material Design

## TODO Items
- [ ] File upload implementation for customer media
- [ ] GDPR export/deletion job queues
- [ ] Profile editing forms
- [ ] Image gallery component
- [ ] Comprehensive test coverage

## Documentation
- ✅ API documentation for customers, loyalty, and discounts
- ✅ Business rules and integration examples
- ✅ Error handling and security considerations

Self-Check:
- ✅ Tables created for Profile/Notes/Media/Loyalty/Discounts
- ✅ RBAC & Policies implemented (staff vs customer access)
- ✅ API endpoints functional with proper middleware
- ✅ Flutter: Customer list, detail with tabs, loyalty adjustments
- ✅ Uploads marked as TODO (separate media slice)
- ✅ GDPR stubs present (export/deletion request endpoints)