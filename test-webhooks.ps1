# Webhook Testing Script
# Tests payment webhook endpoints

Write-Host "🔗 Testing Payment Webhooks..." -ForegroundColor Yellow

# Test webhook endpoint without signature (should return 400)
Write-Host "Testing webhook without signature (should return 400)..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost/api/v1/payments/webhook" -Method POST -UseBasicParsing
    Write-Host "Response Status: $($response.StatusCode)" -ForegroundColor Yellow
    Write-Host "Response Body: $($response.Content)" -ForegroundColor Yellow
} catch {
    if ($_.Exception.Response.StatusCode -eq 400) {
        Write-Host "✅ Webhook correctly returns 400 without signature" -ForegroundColor Green
    } else {
        Write-Host "❌ Unexpected response: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

# Test webhook endpoint with invalid signature
Write-Host "`nTesting webhook with invalid signature..." -ForegroundColor Cyan
try {
    $headers = @{
        'Stripe-Signature' = 'invalid_signature'
        'Content-Type' = 'application/json'
    }
    $response = Invoke-WebRequest -Uri "http://localhost/api/v1/payments/webhook" -Method POST -Headers $headers -Body '{"test": "data"}' -UseBasicParsing
    Write-Host "Response Status: $($response.StatusCode)" -ForegroundColor Yellow
} catch {
    if ($_.Exception.Response.StatusCode -eq 400) {
        Write-Host "✅ Webhook correctly returns 400 with invalid signature" -ForegroundColor Green
    } else {
        Write-Host "❌ Unexpected response: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

Write-Host "`n✅ Webhook testing completed!" -ForegroundColor Green
