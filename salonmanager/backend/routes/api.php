<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HealthController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\Salon\ProfileController;
use App\Http\Controllers\Salon\BlockController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\Staff\ShiftController;
use App\Http\Controllers\Staff\AbsenceController;
use App\Http\Controllers\Customer\CustomerController;
use App\Http\Controllers\Customer\NoteController;
use App\Http\Controllers\Customer\LoyaltyController;
use App\Http\Controllers\Customer\DiscountController;
use App\Http\Controllers\Pos\SessionController;
use App\Http\Controllers\Pos\InvoiceController;
use App\Http\Controllers\Pos\PaymentController;
use App\Http\Controllers\Pos\RefundController;
use App\Http\Controllers\Pos\ReportController;
use App\Http\Controllers\Search\SearchController;
use App\Http\Controllers\Inventory\ProductController;
use App\Http\Controllers\Inventory\StockController;
use App\Http\Controllers\Inventory\SupplierController;
use App\Http\Controllers\Inventory\StockLocationController;
use App\Http\Controllers\Inventory\PurchaseOrderController;
use App\Http\Controllers\Reports\ReportController;

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
    });

    // Salon profile and content blocks
    // public read
    Route::get('/salon/profile', [ProfileController::class, 'show'])->middleware('tenant.required');
    Route::get('/salon/blocks',  [BlockController::class, 'index'])->middleware('tenant.required');

    // protected write
    Route::middleware(['auth:sanctum','tenant.required','role:salon_owner,salon_manager'])->group(function () {
        Route::put('/salon/profile',  [ProfileController::class, 'update']);
        Route::post('/salon/blocks',  [BlockController::class, 'store']);
        Route::get('/salon/blocks/{block}', [BlockController::class, 'show']);
        Route::put('/salon/blocks/{block}', [BlockController::class, 'update']);
        Route::delete('/salon/blocks/{block}', [BlockController::class, 'destroy']);
    });

    // Booking routes
    Route::middleware(['auth:sanctum', 'tenant.required'])->prefix('booking')->group(function () {
        Route::get('/', [BookingController::class, 'index']);
        Route::post('/', [BookingController::class, 'store'])->middleware('role:customer');
        Route::post('/{booking}/confirm', [BookingController::class, 'confirm'])->middleware('role:stylist,salon_owner,salon_manager');
        Route::post('/{booking}/decline', [BookingController::class, 'decline'])->middleware('role:stylist,salon_owner,salon_manager');
        Route::post('/{booking}/cancel', [BookingController::class, 'cancel'])->middleware('role:customer,salon_owner,salon_manager');
    });

    // Services and Stylists routes (for booking wizard)
    Route::middleware(['auth:sanctum', 'tenant.required'])->group(function () {
        Route::get('/services', [BookingController::class, 'services']);
        Route::get('/stylists', [BookingController::class, 'stylists']);
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

    // POS & Billing routes
    Route::prefix('pos')->middleware(['auth:sanctum', 'tenant.required'])->group(function () {
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

    // Public search routes (no auth, no tenant binding)
    Route::prefix('search')->group(function () {
        Route::get('/salons', [SearchController::class, 'salons']);
        Route::get('/availability', [SearchController::class, 'availability']);
    });
});