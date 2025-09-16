# RBAC Core

- Rollen: owner, platform_admin (global), salon_owner, salon_manager, stylist, customer (salon).
- Pivot: user_roles (salon_id nullable).
- Helper: User::hasRole(name, salonId?), hasAnyRole([...]).
- Middleware: role:salon_owner,stylist
- Default: bei Registrierung -> customer im aktiven Salon.
- Grant/Revoke: POST /api/v1/rbac/grant|revoke (owner/manager only).