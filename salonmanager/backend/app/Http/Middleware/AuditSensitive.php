<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use App\Support\Audit\Audit;

class AuditSensitive
{
    public function handle(Request $request, Closure $next, string $action): Response
    {
        $res = $next($request);
        // Erfolgspfad loggen (4xx nicht)
        if ($res->getStatusCode() < 400) {
            // Entity-Infos optional per Route-Parameter 'id'
            $id = $request->route('id') ?? $request->route('invoice') ?? $request->route('booking') ?? null;
            Audit::write($action, null, is_numeric($id)? (int)$id : null, []);
        }
        return $res;
    }
}