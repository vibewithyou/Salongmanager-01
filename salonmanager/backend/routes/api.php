<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HealthController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\Salon\ProfileController;
use App\Http\Controllers\Salon\BlockController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\Staff\ShiftController;
use App\Http\Controllers\Staff\AbsenceController;
use App\Http\Controllers\ScheduleController;
use App\Http\Controllers\CalendarExportController;
use App\Http\Controllers\Customer\CustomerController;
use App\Http\Controllers\Customer\NoteController;
use App\Http\Controllers\Customer\LoyaltyController;
use App\Http\Controllers\Customer\DiscountController;
use App\Http\Controllers\Pos\SessionController;
use App\Http\Controllers\Pos\InvoiceController;
use App\Http\Controllers\Pos\PaymentController;
use App\Http\Controllers\Pos\RefundController;
use App\Http\Controllers\Pos\ReportController;
use App\Http\Controllers\PosController;
use App\Http\Controllers\PaymentWebhookController;
use App\Http\Controllers\Search\SearchController;
use App\Http\Controllers\Inventory\ProductController;
use App\Http\Controllers\Inventory\StockController;
use App\Http\Controllers\Inventory\SupplierController;
use App\Http\Controllers\Inventory\StockLocationController;
use App\Http\Controllers\Inventory\PurchaseOrderController;
use App\Http\Controllers\Reports\ReportController;
use App\Http\Controllers\Media\UploadController;
use App\Http\Controllers\Notify\{PreferencesController, WebhooksController};
use App\Http\Controllers\ReviewController;
use App\Http\Controllers\GdprController;
use App\Http\Controllers\ConsentController;
use App\Http\Controllers\Rbac\RoleController;
use App\Http\Controllers\Gallery\{GalleryAlbumController, GalleryPhotoController, GalleryConsentController, CustomerGalleryController};
use App\Http\Controllers\BookingFromPhotoController;

Route::prefix('v1')->group(function () {
    Route::get('/health', [HealthController::class, 'index']);

    Route::prefix('auth')->group(function () {
        // SPA flow
        Route::get('/csrf', [AuthController::class, 'csrf']); // CSRF cookie helper
        Route::post('/login', [AuthController::class, 'login']); // Sanctum cookie session
        Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
        Route::get('/me', [AuthController::class, 'me'])->middleware('auth:sanctum');

        // Mobile/PAT flow
        Route::post('/token', [AuthController::class, 'token']);

        // 2FA endpoints
        Route::middleware(['auth:sanctum', 'role:owner,platform_admin,salon_owner'])->group(function () {
            Route::post('/2fa/enable', [AuthController::class, 'enable2FA']);
            Route::post('/2fa/confirm', [AuthController::class, 'confirm2FA']);
            Route::post('/2fa/disable', [AuthController::class, 'disable2FA']);
        });
    });

    // Salon profile and content blocks
    // public read with response caching
    Route::get('/salon/profile', [ProfileController::class, 'show'])
        ->middleware(['tenant.required', 'cache.response:120']);
    Route::get('/salon/blocks',  [BlockController::class, 'index'])
        ->middleware(['tenant.required', 'cache.response:120']);

    // protected write
    Route::middleware(['auth:sanctum','tenant.required','role:salon_owner,salon_manager'])->group(function () {
        Route::put('/salon/profile',  [ProfileController::class, 'update']);
        Route::post('/salon/blocks',  [BlockController::class, 'store']);
        Route::get('/salon/blocks/{block}', [BlockController::class, 'show']);
        Route::put('/salon/blocks/{block}', [BlockController::class, 'update']);
        Route::delete('/salon/blocks/{block}', [BlockController::class, 'destroy']);
    });

    // Booking routes with scoped rate limiting
    Route::middleware(['auth:sanctum', 'tenant.required', 'throttle.scope:90,1'])->prefix('booking')->group(function () {
        Route::get('/', [BookingController::class, 'index']);
        Route::post('/', [BookingController::class, 'store'])->middleware('role:customer');
        Route::post('/{booking}/confirm', [BookingController::class, 'confirm'])->middleware('role:stylist,salon_owner,salon_manager');
        Route::post('/{booking}/decline', [BookingController::class, 'decline'])->middleware('role:stylist,salon_owner,salon_manager');
        Route::post('/{booking}/cancel', [BookingController::class, 'cancel'])->middleware('role:customer,salon_owner,salon_manager');
    });

    // New booking routes with scoped rate limiting
    Route::prefix('v1/bookings')->middleware(['auth:sanctum','tenant.required','throttle.scope:90,1'])->group(function(){
        Route::post('/', [BookingController::class,'store']); // customer creates
        Route::post('/{booking}/status', [BookingController::class,'updateStatus']); // confirm/decline/cancel
        Route::post('/{booking}/media', [BookingController::class,'attachMedia'])->middleware('role:salon_owner,salon_manager,stylist');
    });

    // Services and Stylists routes (for booking wizard) with response caching
    Route::middleware(['auth:sanctum', 'tenant.required'])->group(function () {
        Route::get('/services', [BookingController::class, 'services'])
            ->middleware('cache.response:60');
        Route::get('/stylists', [BookingController::class, 'stylists'])
            ->middleware('cache.response:60');
    });

    // Staff scheduling routes
    Route::prefix('staff')->middleware(['auth:sanctum', 'tenant.required'])->group(function () {
        // Shifts
        Route::get('/shifts', [ShiftController::class, 'index'])->middleware('role:salon_owner,salon_manager,stylist');
        Route::post('/shifts', [ShiftController::class, 'store'])->middleware('role:salon_owner,salon_manager');
        Route::put('/shifts/{shift}', [ShiftController::class, 'update'])->middleware('role:salon_owner,salon_manager,stylist');
        Route::delete('/shifts/{shift}', [ShiftController::class, 'destroy'])->middleware('role:salon_owner,salon_manager');

        // Drag/Resize helpers
        Route::post('/shifts/{shift}/move', [ShiftController::class, 'move'])->middleware('role:salon_owner,salon_manager,stylist');
        Route::post('/shifts/{shift}/resize', [ShiftController::class, 'resize'])->middleware('role:salon_owner,salon_manager,stylist');

        // Absences
        Route::get('/absences', [AbsenceController::class, 'index'])->middleware('role:salon_owner,salon_manager,stylist');
        Route::post('/absences', [AbsenceController::class, 'store'])->middleware('role:salon_owner,salon_manager,stylist');
        Route::put('/absences/{absence}', [AbsenceController::class, 'update'])->middleware('role:salon_owner,salon_manager,stylist');
        Route::delete('/absences/{absence}', [AbsenceController::class, 'destroy'])->middleware('role:salon_owner,salon_manager');
        Route::post('/absences/{absence}/approve', [AbsenceController::class, 'approve'])->middleware('role:salon_owner,salon_manager');
    });

    // Enhanced schedule routes
    Route::prefix('v1/schedule')->middleware(['auth:sanctum', 'tenant.required'])->group(function () {
        // Shifts
        Route::get('/shifts', [ScheduleController::class, 'listShifts']); // ?from=&to=&user_id=
        Route::post('/shifts', [ScheduleController::class, 'upsertShift'])->middleware('role:salon_owner,salon_manager');
        Route::put('/shifts/{shift}', [ScheduleController::class, 'upsertShift'])->middleware('role:salon_owner,salon_manager');
        Route::delete('/shifts/{shift}', [ScheduleController::class, 'deleteShift'])->middleware('role:salon_owner,salon_manager');

        // Absences
        Route::get('/absences', [ScheduleController::class, 'listAbsences']); // ?from=&to=&user_id=
        Route::post('/absences', [ScheduleController::class, 'requestAbsence']); // stylist self or managers
        Route::post('/absences/{absence}/decision', [ScheduleController::class, 'decideAbsence'])->middleware('role:salon_owner,salon_manager');

        // Work Rules
        Route::get('/work-rules', [ScheduleController::class, 'getWorkRules']);
        Route::put('/work-rules', [ScheduleController::class, 'updateWorkRules'])->middleware('role:salon_owner,salon_manager');

        // Calendar Export
        Route::get('/ics', [CalendarExportController::class, 'ics']);
    });

    // Customer management routes
    Route::middleware(['tenant.required'])->group(function () {
        // public view of active discounts (optional)
        Route::get('/discounts', [DiscountController::class, 'index']);

        Route::middleware(['auth:sanctum'])->group(function () {
            // Customer directory (staff)
            Route::get('/customers', [CustomerController::class, 'index'])
                ->middleware('role:salon_owner,salon_manager,stylist');
            Route::get('/customers/{customer}', [CustomerController::class, 'show'])
                ->middleware('role:salon_owner,salon_manager,stylist,customer');
            Route::put('/customers/{customer}', [CustomerController::class, 'update'])
                ->middleware('role:salon_owner,salon_manager,customer');

            // DSGVO requests
            Route::post('/customers/{customer}/request-export', [CustomerController::class, 'requestExport'])
                ->middleware('role:salon_owner,salon_manager,customer');
            Route::post('/customers/{customer}/request-deletion', [CustomerController::class, 'requestDeletion'])
                ->middleware('role:salon_owner,salon_manager,customer');

            // Notes
            Route::get('/customers/{customer}/notes', [NoteController::class, 'index'])
                ->middleware('role:salon_owner,salon_manager,stylist');
            Route::post('/customers/notes', [NoteController::class, 'store'])
                ->middleware('role:salon_owner,salon_manager,stylist');
            Route::put('/customers/notes/{note}', [NoteController::class, 'update'])
                ->middleware('role:salon_owner,salon_manager,stylist');
            Route::delete('/customers/notes/{note}', [NoteController::class, 'destroy'])
                ->middleware('role:salon_owner,salon_manager,stylist');

            // Loyalty
            Route::get('/customers/{customer}/loyalty', [LoyaltyController::class, 'show'])
                ->middleware('role:salon_owner,salon_manager,stylist,customer');
            Route::post('/customers/{customer}/loyalty/adjust', [LoyaltyController::class, 'adjust'])
                ->middleware('role:salon_owner,salon_manager,stylist');
        });
    });

    // POS & Billing routes with stricter rate limiting
    Route::prefix('pos')->middleware(['auth:sanctum', 'tenant.required', 'throttle.scope:45,1'])->group(function () {
        // Sessions
        Route::post('/sessions/open', [SessionController::class, 'open'])
            ->middleware('role:salon_owner,salon_manager,stylist');
        Route::post('/sessions/{session}/close', [SessionController::class, 'close'])
            ->middleware('role:salon_owner,salon_manager');

        // Invoices
        Route::post('/invoices', [InvoiceController::class, 'store'])
            ->middleware('role:salon_owner,salon_manager,stylist');
        Route::get('/invoices/{invoice}', [InvoiceController::class, 'show'])
            ->middleware('role:salon_owner,salon_manager,stylist');

        // Payments & Refunds
        Route::post('/invoices/{invoice}/pay', [PaymentController::class, 'pay'])
            ->middleware('role:salon_owner,salon_manager,stylist');
        Route::post('/invoices/{invoice}/refund', [RefundController::class, 'refund'])
            ->middleware('role:salon_owner,salon_manager');

        // Enhanced Payment Operations
        Route::post('/invoices/{invoice}/charge', [PosController::class, 'charge'])
            ->middleware('role:salon_owner,salon_manager,stylist');
        Route::post('/invoices/{invoice}/refund-payment', [PosController::class, 'refund'])
            ->middleware('role:salon_owner,salon_manager');
        Route::get('/invoices/{invoice}/payment-status', [PosController::class, 'status'])
            ->middleware('role:salon_owner,salon_manager,stylist');
        Route::get('/invoices/open', [PosController::class, 'openInvoices'])
            ->middleware('role:salon_owner,salon_manager,stylist');

        // Reports & Export
        Route::get('/reports/z', [ReportController::class, 'zReport'])
            ->middleware('role:salon_owner,salon_manager');
        Route::get('/exports/datev.csv', [ReportController::class, 'datevCsv'])
            ->middleware('role:salon_owner,salon_manager');
    });

    // Inventory routes
    Route::prefix('inventory')->middleware(['auth:sanctum','tenant.required'])->group(function () {
        // Products
        Route::get('/products', [ProductController::class, 'index']);
        Route::post('/products', [ProductController::class, 'store']);
        Route::put('/products/{product}', [ProductController::class, 'update']);

        // Stock management
        Route::get('/stock', [StockController::class, 'overview']);
        Route::get('/stock/low', [StockController::class, 'lowStock']);
        Route::post('/stock/in', [StockController::class, 'inbound']);
        Route::post('/stock/out', [StockController::class, 'outbound']);
        Route::post('/stock/transfer', [StockController::class, 'transfer']);
        Route::get('/stock/movements', [StockController::class, 'movements']);

        // Suppliers
        Route::get('/suppliers', [SupplierController::class, 'index']);
        Route::post('/suppliers', [SupplierController::class, 'store']);
        Route::put('/suppliers/{supplier}', [SupplierController::class, 'update']);

        // Stock locations
        Route::get('/locations', [StockLocationController::class, 'index']);
        Route::post('/locations', [StockLocationController::class, 'store']);
        Route::put('/locations/{location}', [StockLocationController::class, 'update']);

        // Purchase orders
        Route::get('/po', [PurchaseOrderController::class, 'index']);
        Route::post('/po', [PurchaseOrderController::class, 'store']);
        Route::post('/po/{purchase_order}/receive', [PurchaseOrderController::class, 'receive']);
    });

    // Reports & Analytics routes
    Route::middleware(['auth:sanctum', 'tenant.required'])->prefix('reports')->group(function () {
        Route::get('/revenue', [ReportController::class, 'revenue'])
            ->middleware('role:salon_owner,salon_manager');
        Route::get('/top-services', [ReportController::class, 'topServices'])
            ->middleware('role:salon_owner,salon_manager');
        Route::get('/top-stylists', [ReportController::class, 'topStylists'])
            ->middleware('role:salon_owner,salon_manager');
        Route::get('/occupancy', [ReportController::class, 'occupancy'])
            ->middleware('role:salon_owner,salon_manager');
        Route::get('/export', [ReportController::class, 'exportCsv'])
            ->middleware('role:salon_owner,salon_manager');
    });

    // Media upload routes
    Route::prefix('media')->middleware(['tenant.required'])->group(function () {
        Route::post('/uploads/initiate', [UploadController::class, 'initiate'])->middleware('auth:sanctum');
        Route::post('/uploads/finalize', [UploadController::class, 'finalize'])->middleware('auth:sanctum');

        Route::get('/files/{file}', [UploadController::class, 'show']);
        Route::delete('/files/{file}', [UploadController::class, 'destroy'])->middleware(['auth:sanctum', 'role:salon_owner,salon_manager']);
    });

    // Notification routes
    Route::prefix('notify')->middleware(['auth:sanctum','tenant.required'])->group(function(){
      Route::get('/prefs', [PreferencesController::class,'index']);
      Route::post('/prefs', [PreferencesController::class,'update']);

      Route::get('/webhooks', [WebhooksController::class,'index'])->middleware('role:salon_owner,salon_manager');
      Route::post('/webhooks', [WebhooksController::class,'store'])->middleware('role:salon_owner,salon_manager');
      Route::put('/webhooks/{webhook}', [WebhooksController::class,'update'])->middleware('role:salon_owner,salon_manager');
      Route::delete('/webhooks/{webhook}', [WebhooksController::class,'destroy'])->middleware('role:salon_owner,salon_manager');
    });

    // Public search routes (no auth, no tenant binding) with response caching
    Route::prefix('search')->group(function () {
        Route::get('/salons', [SearchController::class, 'salons'])
            ->middleware(['cache.response:300', 'throttle.scope:120,1']);
        Route::get('/availability', [SearchController::class, 'availability'])
            ->middleware(['cache.response:60', 'throttle.scope:120,1']);
    });

    // Review routes
    Route::prefix('reviews')->middleware(['tenant.required'])->group(function () {
        // Public endpoints (no auth required) with response caching
        Route::get('/', [ReviewController::class, 'index'])
            ->middleware('cache.response:60');
        
        // Authenticated endpoints
        Route::middleware(['auth:sanctum'])->group(function () {
            // Customer endpoints
            Route::get('/my-review', [ReviewController::class, 'myReview']);
            Route::middleware(['role:customer'])->group(function () {
                Route::post('/', [ReviewController::class, 'store']);
                Route::put('/{review}', [ReviewController::class, 'update']);
            });
            Route::delete('/{review}', [ReviewController::class, 'destroy']);
            
            // Moderation endpoints (salon owners/managers)
            Route::middleware(['role:salon_owner,salon_manager'])->group(function () {
                Route::get('/moderation', [ReviewController::class, 'moderation']);
                Route::post('/{review}/toggle-approval', [ReviewController::class, 'toggleApproval']);
            });
        });
    });

    // GDPR routes
    Route::prefix('gdpr')->middleware(['auth:sanctum','tenant.required'])->group(function () {
        Route::post('/export', [GdprController::class,'requestExport']);                    // self
        Route::get('/exports/{gdpr}', [GdprController::class,'show']);                      // self or admin
        Route::get('/exports/{gdpr}/download', [GdprController::class,'download']);         // self or admin
        Route::post('/delete', [GdprController::class,'requestDelete']);                    // self
        Route::post('/delete/{gdpr}/confirm', [GdprController::class,'confirmDelete'])      // admin only
            ->middleware('role:owner,platform_admin,salon_owner');
    });

    // RBAC routes
    Route::prefix('rbac')->middleware(['auth:sanctum','tenant.required'])->group(function () {
        Route::get('/me/roles', [RoleController::class,'myRoles']);
        Route::post('/grant', [RoleController::class,'grant'])->middleware('role:owner,platform_admin,salon_owner,salon_manager');
        Route::post('/revoke', [RoleController::class,'revoke'])->middleware('role:owner,platform_admin,salon_owner,salon_manager');
    });

    // Payment webhooks with specific rate limiting (no auth required)
    Route::post('/payments/webhook', [PaymentWebhookController::class, 'handle'])
        ->middleware(['throttle.scope:30,1']);

    // Refund routes
    Route::post('/refunds', [RefundController::class, 'create'])
        ->middleware(['auth:sanctum', 'tenant.required', 'throttle.scope:10,1']);

    // Consent routes
    Route::post('/consents', [ConsentController::class, 'store'])
        ->middleware(['auth:sanctum', 'tenant.required']);

    // Gallery routes
    Route::prefix('gallery')->middleware(['tenant.required'])->group(function () {
        // Albums
        Route::get('/albums', [GalleryAlbumController::class, 'index']);
        Route::post('/albums', [GalleryAlbumController::class, 'store'])
            ->middleware(['auth:sanctum', 'role:salon_owner,salon_manager']);
        Route::get('/albums/{album}', [GalleryAlbumController::class, 'show']);
        Route::put('/albums/{album}', [GalleryAlbumController::class, 'update'])
            ->middleware(['auth:sanctum']);
        Route::delete('/albums/{album}', [GalleryAlbumController::class, 'destroy'])
            ->middleware(['auth:sanctum']);

        // Photos
        Route::get('/photos', [GalleryPhotoController::class, 'index']);
        Route::post('/photos', [GalleryPhotoController::class, 'store'])
            ->middleware(['auth:sanctum', 'role:stylist,salon_manager,salon_owner']);
        Route::get('/photos/{photo}', [GalleryPhotoController::class, 'show']);
        Route::post('/photos/{photo}/moderate', [GalleryPhotoController::class, 'moderate'])
            ->middleware(['auth:sanctum', 'role:salon_owner,salon_manager']);
        Route::delete('/photos/{photo}', [GalleryPhotoController::class, 'destroy'])
            ->middleware(['auth:sanctum']);

        // Photo interactions (likes, favorites, stats)
        Route::post('/photos/{photo}/like', [GalleryPhotoController::class, 'like'])
            ->middleware(['auth:sanctum', 'throttle.scope:60,1']);
        Route::post('/photos/{photo}/favorite', [GalleryPhotoController::class, 'favorite'])
            ->middleware(['auth:sanctum', 'throttle.scope:60,1']);
        Route::get('/photos/{photo}/stats', [GalleryPhotoController::class, 'stats']);
        Route::get('/photos/{photo}/suggested-services', [GalleryPhotoController::class, 'suggestedServices']);

        // Consents
        Route::post('/consents', [GalleryConsentController::class, 'store'])
            ->middleware(['auth:sanctum']);
        Route::put('/consents/{consent}', [GalleryConsentController::class, 'update'])
            ->middleware(['auth:sanctum']);
        Route::delete('/consents/{consent}', [GalleryConsentController::class, 'destroy'])
            ->middleware(['auth:sanctum']);
    });

    // Customer gallery routes
    Route::prefix('customers')->middleware(['auth:sanctum', 'tenant.required'])->group(function () {
        Route::get('/{customer}/gallery', [CustomerGalleryController::class, 'index'])
            ->middleware('role:salon_owner,salon_manager,stylist,customer');
    });

    // Booking from photo routes
    Route::prefix('bookings')->middleware(['auth:sanctum', 'tenant.required', 'throttle.scope:45,1'])->group(function () {
        Route::get('/from-photo/{photo}/suggested-services', [BookingFromPhotoController::class, 'suggestedServices']);
        Route::post('/from-photo/{photo}', [BookingFromPhotoController::class, 'createBooking'])
            ->middleware('role:customer');
    });
});